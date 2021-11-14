import UIKit

struct UIHelper {
    
    static func createMainTabBarController() -> UITabBarController {
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = UIColor(named: K.Color.appColor) ?? .systemPink
        tabBarController.tabBar.barTintColor = .white
     
        
        let itemListSB = UIStoryboard(name: StoryboardName.ItemList, bundle: nil)
        guard let itemListVC = itemListSB.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { fatalError() }
        
        itemListVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: K.Images.homeSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
        let nav1 = UINavigationController(rootViewController: itemListVC)
        nav1.navigationBar.tintColor = .black
        
        
  
        let chatListVC = ChatListViewController(
            viewModel: ChatListViewModel(chatManager: ChatManager(), itemManager: ItemManager())
        )
        
        chatListVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate).withTintColor(UIColor(named: K.Color.appColor) ?? .systemPink), tag: 0)
        let nav2 = UINavigationController(rootViewController: chatListVC)
        nav2.tabBarItem.image = UIImage(named: K.Images.chatUnselected)?.withRenderingMode(.alwaysTemplate)
        nav2.tabBarItem.selectedImage = UIImage(named: K.Images.chatSelected)?.withRenderingMode(.alwaysTemplate)
        nav2.navigationBar.tintColor = UIColor.black
        
        
        
        let myPageVC = MyPageViewController(userManager: UserManager())
        myPageVC.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(weight: .heavy)), tag: 0)
        let nav3 = UINavigationController(rootViewController: myPageVC)
        
        nav3.tabBarItem.image = UIImage(named: K.Images.myPageUnselected)?.withRenderingMode(.alwaysTemplate)
        nav3.tabBarItem.selectedImage = UIImage(named: K.Images.myPageSelected)?.withRenderingMode(.alwaysTemplate)
        nav3.navigationBar.tintColor = .black
        
     

    
    
        #warning("Badge Color도 지정")
        
        tabBarController.setViewControllers([nav1, nav2, nav3], animated: true)
        
        
        
        return tabBarController
    }
    
    
    
    
    
    
    
    static func addNavigationBarWithDismissButton(in view: UIView, title: String = "") {
        
        var statusBarHeight: CGFloat = 0
        statusBarHeight = UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0

        let naviBar = UINavigationBar(frame: .init(
            x: 0,
            y: statusBarHeight,
            width: view.frame.width,
            height: statusBarHeight)
        )
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        naviBar.standardAppearance = appearance
        naviBar.scrollEdgeAppearance = appearance
    
        let naviItem = UINavigationItem(title: title)
        
        // X 버튼
        let stopBarButtonItem =  UIBarButtonItem(
            barButtonSystemItem: .stop,
            target: self,
            action: #selector(UIViewController.dismissVC)
        )
        stopBarButtonItem.tintColor = .black
    
        naviItem.rightBarButtonItem = stopBarButtonItem
        naviBar.items = [naviItem]
        view.addSubview(naviBar)
    }
    
    // ActionSheet 만들기
    static func createActionSheet(with actions: [UIAlertAction], title: String?) -> UIAlertController {
        
        let actionSheet = UIAlertController(
            title: title,
            message: nil,
            preferredStyle: .actionSheet
        )
        actionSheet.view.tintColor = .black
        
        actions.forEach { actionSheet.addAction($0) }
        
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil
        )
        actionSheet.addAction(cancelAction)
        
        return actionSheet
    }
}
