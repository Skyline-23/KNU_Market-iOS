import UIKit
import SDWebImage

class MyPostsViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    private var selectedIndex: Int?
    
    private var viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
}

//MARK: - HomeViewModelDelegate

extension MyPostsViewController: HomeViewModelDelegate {
    
    func didFetchUserProfileInfo() {
        //
    }
    
    func failedFetchingUserProfileInfo(with error: NetworkError) {
        //
    }
    
    func didFetchUserProfileImage() {
        //
    }
    
    func didFetchItemList() {
        tableView.reloadData()
        refreshControl.endRefreshing()
        tableView.tableFooterView = nil
        tableView.tableFooterView = UIView(frame: .zero)
        
        if viewModel.itemList.count == 0 {
            tableView.showEmptyView(
                imageName: K.Images.emptyChatList,
                text: "아직 작성하신 공구글이 없네요!\n첫 번째 공구글을 올려보세요!"
            )
        }
    }
    
    func failedFetchingItemList(errorMessage: String, error: NetworkError) {
        
        tableView.showEmptyView(
            imageName: K.Images.emptyChatList,
            text: errorMessage
        )
        refreshControl.endRefreshing()
        tableView.reloadData()
        tableView.tableFooterView = nil
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func failedFetchingRoomPIDInfo(with error: NetworkError) {
        //
    }
    
}

//MARK: -  UITableViewDelegate, UITableViewDataSource

extension MyPostsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = K.cellID.itemTableViewCell
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ItemTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModel.itemList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndex = indexPath.row
        
        performSegue(withIdentifier: K.SegueID.goToItemVCFromMyPosts, sender: self)
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let itemVC: ItemViewController = segue.destination as? ItemViewController else { return }
        guard let index = selectedIndex else { return }
        
        itemVC.hidesBottomBarWhenPushed = true
        itemVC.pageID = viewModel.itemList[index].uuid
    }
    
    @objc func refreshTableView() {
    
        UIView.animate(views: self.tableView.visibleCells,
                       animations: Animations.forTableViews,
                       reversed: true,
                       initialAlpha: 1.0,   // 보이다가
                       finalAlpha: 0.0,      // 안 보이게
                       completion: {
                        self.viewModel.resetValues()
                        self.viewModel.fetchItemList(fetchCurrentUsers: true)
                       })
    }
}


//MARK: - UIScrollViewDelegate

extension MyPostsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let position = scrollView.contentOffset.y
   
        if position > (tableView.contentSize.height - 80 - scrollView.frame.size.height) {
        
            if !viewModel.isFetchingData {
                tableView.tableFooterView = createSpinnerFooterView()
                viewModel.fetchItemList(fetchCurrentUsers: true)
            }
        }
    }
}

//MARK: - Initialization & UI Configuration 

extension MyPostsViewController {
    
    func initialize() {
        
        self.title = "내가 올린 공구"
        
        createObserversForPresentingVerificationAlert()
        viewModel.delegate = self
        viewModel.fetchItemList(fetchCurrentUsers: true)
        initializeTableView()
    }
    
    func initializeTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self

        
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView(frame: .zero)
        
        let nibName = UINib(nibName: K.XIB.itemTableViewCell, bundle: nil)
        tableView.register(
            nibName,
            forCellReuseIdentifier: K.cellID.itemTableViewCell
        )
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshTableView),
            for: .valueChanged
        )
    }
}