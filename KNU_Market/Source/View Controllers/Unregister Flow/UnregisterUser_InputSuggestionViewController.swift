import UIKit
import TextFieldEffects
import Alamofire

class UnregisterUser_InputSuggestionViewController: UIViewController {

    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var detailLineLabel: UILabel!
    @IBOutlet weak var emailHelpLabel: UILabel!
    @IBOutlet weak var userInputTextView: UITextView!
    
    private let emailHelpLabelText = "웹메일 인증과 관련된 문의는 카카오채널을\n통해 실시간으로 도와드리겠습니다."
    private let textViewPlaceholder = "✏️ 개발팀에게 전하고 싶은 말을 자유롭게 작성해주세요."
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        dismissProgressBar()
    }
    
    @IBAction func pressedKakaoLinkButton(_ sender: UIButton) {
        
        let url = URL(string: K.URL.kakaoHelpChannel)!
        UIApplication.shared.open(url, options: [:])
    }
    
    @IBAction func pressedDoneButton(_ sender: UIBarButtonItem) {
        
        userInputTextView.resignFirstResponder()
        
        guard var feedback = userInputTextView.text else { return }
        guard feedback != textViewPlaceholder else {
            presentKMAlertOnMainThread(title: "회원 탈퇴 사유 입력",
                                       message: "회원 탈퇴 사유를 입력해 주세요. 짧게라도 작성해주시면 감사하겠습니다 :)",
                                       buttonTitle: "확인")
            return
        }
        
        showProgressBar()
        feedback = "회원 탈퇴 사유: \(feedback)"
        
        let group = DispatchGroup()
        group.enter()
        UserManager.shared.sendFeedback(content: feedback) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            case .success: break
            case .failure(_):
                self.showSimpleBottomAlert(with: "피드백 보내기에 실패하였습니다. 잠시 후 다시 시도해주세요.")
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            UserManager.shared.unregisterUser { [weak self] result in
                
                dismissProgressBar()
                
                guard let self = self else { return }
                
                switch result {
                case .success:
                    self.popToInitialViewController()
                case .failure(let error):
                    
                    self.presentKMAlertOnMainThread(title: "회원 탈퇴 실패",
                                                    message: error.errorDescription,
                                                    buttonTitle: "확인")
                }
            }
        }
    }
}

//MARK: - UI Configuration & Initialization

extension UnregisterUser_InputSuggestionViewController {
    
    func initialize() {
        
        initializeLabels()
        initializeTextView()
    }
    
    func initializeLabels() {
        
        firstLineLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        firstLineLabel.textColor = .darkGray

        firstLineLabel.text = "크누마켓팀이 개선했으면\n하는 점을 알려주세요."
        firstLineLabel.changeTextAttributeColor(fullText: firstLineLabel.text!, changeText: "크누마켓")
        
        detailLineLabel.text = "피드백을 반영하여 적극적으로 개선하겠습니다."
        detailLineLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        detailLineLabel.textColor = .lightGray
        
        emailHelpLabel.text = emailHelpLabelText
        emailHelpLabel.font = .systemFont(ofSize: 16, weight: .medium)
        emailHelpLabel.textColor = .darkGray
        emailHelpLabel.changeTextAttributeColor(fullText: emailHelpLabelText, changeText: "웹메일 인증과 관련된 문의")
    }
    
    func initializeTextView() {
        
        userInputTextView.delegate = self
        userInputTextView.layer.borderWidth = 1.0
        userInputTextView.layer.cornerRadius = 10.0
        userInputTextView.layer.borderColor = UIColor.lightGray.cgColor
        userInputTextView.clipsToBounds = true
        userInputTextView.font = UIFont.systemFont(ofSize: 15)
        userInputTextView.text = textViewPlaceholder
        userInputTextView.textColor = UIColor.lightGray
    }
}

//MARK: - UITextViewDelegate

extension UnregisterUser_InputSuggestionViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = textViewPlaceholder
            textView.textColor = UIColor.lightGray
            return
        }
    }
}