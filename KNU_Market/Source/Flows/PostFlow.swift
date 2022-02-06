//
//  PostFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/06.
//

import Foundation
import Then
import RxFlow
import UIKit
import RxSwift

class PostFlow: Flow {

    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    private let rootViewController = UINavigationController()
    
    init(services: AppServices) {
        self.services = services
    }
    
    func adapt(step: Step) -> Single<Step> {
        guard let step = step as? AppStep else { return .just(step) }
        
        switch step {
        case .uploadPostIsRequired:
            
            let isUserVerified: Bool = UserDefaultsGenericService.shared.get(key: UserDefaults.Keys.hasVerifiedEmail) ?? false
   
            return isUserVerified ? .just(step) : .just(AppStep.unauthorized)
            
        default:
            return .just(step)
        }
    }
    
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
        case .postListIsRequired:
            return navigateToPostList()
            
        case .postIsRequired(let postUid, let isFromChatVC):
            return navigateToPostDetail(postUid: postUid, isFromChatVC: isFromChatVC)
            
        case .uploadPostIsRequired:
            return navigateToUploadPostVC()
            
        case .unauthorized:
            return showUnauthorizedAlert()
            
            
        default:
            return .none
        }
    }
}

extension PostFlow {
    
    private func navigateToPostList() -> FlowContributors {
        
        let postListReactor = PostListViewReactor(
            postService: services.postService,
            chatListService: services.chatListService,
            userService: services.userService,
            popupService: services.popupService,
            bannerService: services.bannerService,
            userDefaultsGenericService: services.userDefaultsGenericService,
            userNotificationService: services.userNotificationService
        )
        let postListVC = PostListViewController(reactor: postListReactor)
        
        self.rootViewController.pushViewController(postListVC, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: postListVC,
            withNextStepper: postListReactor)
        )
    }
    
    private func navigateToPostDetail(postUid: String, isFromChatVC: Bool) -> FlowContributors {
        
        let reactor = PostViewReactor(
            pageId: postUid,
            isFromChatVC: isFromChatVC,
            postService: services.postService,
            chatService: services.chatService,
            sharingService: services.sharingService,
            userDefaultsService: services.userDefaultsGenericService
        )
        
        let postVC = PostViewController(reactor: reactor)
        self.rootViewController.pushViewController(postVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: postVC, withNextStepper: reactor))
    }
    
    private func navigateToUploadPostVC() -> FlowContributors {
        
        let reactor = UploadPostReactor(
            postService: services.postService,
            mediaService: services.mediaService
        )
        
        let uploadVC = UploadPostViewController(reactor: reactor)
        self.rootViewController.pushViewController(uploadVC, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: uploadVC, withNextStepper: reactor))
    }

}

//MARK: - Alert Methods

extension PostFlow {
    
    private func showUnauthorizedAlert() -> FlowContributors {

        self.rootViewController.showSimpleBottomAlertWithAction(message: "학생 인증을 마치셔야 사용이 가능해요.👀", buttonTitle: "인증하러 가기") {
            let vc = VerifyOptionViewController()
            vc.hidesBottomBarWhenPushed = true
            self.rootViewController.pushViewController(vc, animated: true)
        }
        return .none
    }
}
