//
//  RegisterFlow.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/02/09.
//

import UIKit
import RxFlow
import Then

class RegisterFlow: Flow {
    
    private let rootViewController = UINavigationController().then {
        $0.modalPresentationStyle = .overFullScreen
        $0.navigationBar.tintColor = UIColor.black
    }
    private let services: AppServices
    
    var root: Presentable {
        return self.rootViewController
    }
    
    init(services: AppServices) {
        self.services = services
    }
     
    func navigate(to step: Step) -> FlowContributors {
        guard let step = step as? AppStep else { return .none }
        
        switch step {
            
        case .registerIsRequired:
            return navigateToIdInputView()
            
        case .idInputIsCompleted:
            return navigateToPasswordInputView()
            
        case .passwordInputIsCompleted:
            return navigateToNicknameInputView()
      
        case .nicknameInputIsCompleted:
            return navigateToEmailInputView()
       
        case .emailInputIsCompleted:
            return presentCongratulateUserView()
            
        case .mainIsRequired:
            return navigateToMainHomeScreen()
            
        case .termsAndConditionIsRequired:
            return presentTermsAndConditionsView()
            
        case .privacyTermsIsRequired:
            return presentPrivacyTermsView()
            
        case .loginIsRequired:
            return navigateBackToLoginFlow()
            
        default:
            return .none
        }
    }
    
}

extension RegisterFlow {
    
    private func navigateToIdInputView() -> FlowContributors {
        
        let reactor = IDInputViewReactor(userService: services.userService)
        let vc = IDInputViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToPasswordInputView() -> FlowContributors {
        
        let reactor = PasswordInputViewReactor()
        let vc = PasswordInputViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToNicknameInputView() -> FlowContributors {
        
        let reactor = NickNameInputViewReactor(userService: services.userService)
        let vc = NickNameInputViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToEmailInputView() -> FlowContributors {
        
        let reactor = EmailForLostPasswordViewReactor(userService: services.userService)
        let vc = EmailForLostPasswordViewController(reactor: reactor)
        
        self.rootViewController.pushViewController(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func presentCongratulateUserView() -> FlowContributors {
        
        let reactor = CongratulateUserViewReactor(userService: services.userService)
        let vc = CongratulateUserViewController(reactor: reactor)
        vc.modalPresentationStyle = .fullScreen
        
        self.rootViewController.present(vc, animated: true)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: vc,
            withNextStepper: reactor)
        )
    }
    
    private func navigateToMainHomeScreen() -> FlowContributors {
        
        let homeFlow = HomeFlow(services: services)
        
        Flows.use(homeFlow, when: .created) { rootVC in
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(rootVC)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: homeFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.mainIsRequired))
        )
    }
    
    // CongratulateVC에서 최종적으로 로그인을 하는 도중에 에러 발생 시 로그인 화면으로 전환을 위함
    private func navigateBackToLoginFlow() -> FlowContributors {
        
        let loginFlow = LoginFlow(services: services)
        
        Flows.use(loginFlow, when: .created) { rootVC in
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(rootVC)
        }
        
        return .one(flowContributor: .contribute(
            withNextPresentable: loginFlow,
            withNextStepper: OneStepper(withSingleStep: AppStep.loginIsRequired))
        )
    }
    
    private func presentTermsAndConditionsView() -> FlowContributors {
        let url = URL(string: K.URL.termsAndConditionNotionURL)!
        self.rootViewController.presentSafariView(with: url)
        
        return .none
    }
    
    private func presentPrivacyTermsView() -> FlowContributors {
        let url = URL(string: K.URL.privacyInfoConditionNotionURL)!
        self.rootViewController.presentSafariView(with: url)
        
        return .none
    }
}
