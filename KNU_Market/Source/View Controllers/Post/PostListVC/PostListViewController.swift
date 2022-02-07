import UIKit
import SPIndicator
import ViewAnimator
import HGPlaceholders
import SnapKit
import Then
import RxSwift
import RxCocoa
import ReactorKit

class PostListViewController: BaseViewController, View {

    typealias Reactor = PostListViewReactor
    
    //MARK: - Constants
    
    struct Metrics {
        static let addPostButtonSize = 55.f
    }
    
    //MARK: - UI
    
    lazy var navigationTitleView: KMNavigationTitleView = {
        let view =  KMNavigationTitleView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.size.width,
                height: 50)
        )
        return view
    }()
    
    lazy var bannerHeaderView: BannerHeaderView = {
        let headerView = BannerHeaderView(
            controlledBy: self,
            frame: CGRect(
                x: 0,
                y: 0,
                width: view.frame.size.width - 25,
                height: 200
            )
        )
        return headerView
    }()
    
    let postListsTableView = UITableView().then {
        $0.register(
            PostTableViewCell.self,
            forCellReuseIdentifier: PostTableViewCell.cellId
        )
    }
    
    let refreshControl = UIRefreshControl()
    
    let uploadPostButton = UIButton().then {
        $0.backgroundColor = UIColor(named: K.Color.appColor)
        $0.addBounceAnimation()
        let font = UIFont.systemFont(ofSize: 23, weight: .medium)
        let configuration = UIImage.SymbolConfiguration(font: font)
        let buttonImage = UIImage(
            systemName: "plus",
            withConfiguration: configuration
        )
        $0.tintColor = .white
        $0.setImage(buttonImage, for: .normal)
        $0.layer.cornerRadius = Metrics.addPostButtonSize / 2
        $0.backgroundColor = UIColor(named: K.Color.appColor)
    }
    
    //MARK: - Initialization
    
    init(reactor: Reactor) {
        super.init()
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    //MARK: - UI Setup
    
    override func setupLayout() {
        super.setupLayout()
        
        navigationController?.navigationBar.addSubview(navigationTitleView)
        view.addSubview(postListsTableView)
        view.addSubview(uploadPostButton)
        postListsTableView.tableHeaderView = bannerHeaderView
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        navigationTitleView.snp.makeConstraints {
            $0.left.equalToSuperview().inset(30)
            $0.bottom.equalToSuperview()
        }

        postListsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        uploadPostButton.snp.makeConstraints {
            $0.width.height.equalTo(Metrics.addPostButtonSize)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.right.equalToSuperview().offset(-25)
        }
    }
    
    //MARK: - Binding
    
    func bind(reactor: PostListViewReactor) {
        
        // Input
        
        self.rx.viewDidLoad
            .map { _ in Reactor.Action.loadInitialMethods }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        
        self.rx.viewDidAppear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationTitleView.setIsHidden(false, animated: true)
            })
            .disposed(by: disposeBag)
        

        self.rx.viewWillDisappear
            .withUnretained(self)
            .subscribe(onNext: { _ in
                self.navigationTitleView.setIsHidden(true, animated: true)
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { Reactor.Action.refreshTableView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        uploadPostButton.rx.tap
            .map { Reactor.Action.uploadPost }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        postListsTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        
        // Output
        
        reactor.state
            .map { $0.postList }
            .bind(to: postListsTableView.rx.items(
                cellIdentifier: PostTableViewCell.cellId,
                cellType: PostTableViewCell.self)
            ) { indexPath, postList, cell in
                cell.configure(with: postList)
            }
            .disposed(by: disposeBag)
        
        postListsTableView.rx.itemSelected
            .map { Reactor.Action.seePostDetail($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)

        postListsTableView.rx.contentOffset
            .filter { [weak self] offset in
                guard let self = self else { return false }
                guard self.postListsTableView.frame.height > 0 else { return false }
                return offset.y + self.postListsTableView.frame.height >= self.postListsTableView.contentSize.height - 100
            }
            .filter { _ in reactor.currentState.isFetchingData == false }
            .map { _ in Reactor.Action.fetchPostList }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isFetchingData }
            .withUnretained(self)
            .subscribe(onNext: { (_, isFetchingData) in
                self.postListsTableView.tableFooterView = isFetchingData
                ? UIHelper.createSpinnerFooterView(in: self.view)
                : nil
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isRefreshingData }
            .distinctUntilChanged()
            .bind(to: refreshControl.rx.isRefreshing)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.bannerModel }
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, bannerModel) in
                self.bannerHeaderView.configure(with: bannerModel!)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .distinctUntilChanged()
            .filter { $0 != nil }
            .withUnretained(self)
            .subscribe(onNext: { (_, errorMessage) in
                self.showSimpleBottomAlert(with: errorMessage!)
            })
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userNeedsToUpdateAppVersion }
            .distinctUntilChanged()
            .filter { $0 == true }
            .withUnretained(self)
            .subscribe(onNext: { _ in
                
                let vc = CustomAlertViewController_Rx(
                    title: "❗️필수 업데이트가 있습니다!❗️",
                    message: "업데이트를 하지 않으면 기능이 정상적으로 작동하지 않아요. 불편하시더라도 앱스토어에서 꼭 업데이트 부탁드릴게요.🙏🏻",
                    cancelButtonTitle: "취소",
                    actionButtonTitle: "업데이트 하러 가기"
                )
                self.present(vc, animated: true)
                vc.alertObserver
                    .withUnretained(self)
                    .subscribe(onNext: { (_, actionType) in
                        switch actionType {
                        case .ok:
                            UIApplication.shared.open(URL(string: K.URL.appStoreLink)!, options: [:])
                        default: break
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        // Notification Center
        
        NotificationCenterService.updatePostList.addObserver()
            .map { _ in Reactor.Action.refreshTableView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        NotificationCenterService.configureChatTabBadgeCount.addObserver()
            .bind { _ in
                self.configureChatTabBadgeCount()
            }
            .disposed(by: disposeBag)
        
        NotificationCenterService.unexpectedError.addObserver()
            .map { _ in Reactor.Action.unexpectedError }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func configure() {
        postListsTableView.refreshControl = refreshControl
    }
}

