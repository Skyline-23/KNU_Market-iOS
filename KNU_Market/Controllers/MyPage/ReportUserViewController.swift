import UIKit
import SnackBar_swift
import ProgressHUD

class ReportUserViewController: UIViewController {
    
    @IBOutlet var contentTextView: UITextView!
    @IBOutlet var sendButton: UIButton!
    
    var userToReport: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
    
    @IBAction func pressedSendButton(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if !validateUserInput() { return }
        
        showProgressBar()
        
        let model = ReportUserModel(user: userToReport,
                                    content: contentTextView.text!)
        
        print("userToReport: \(userToReport)")
        
        ReportManager.shared.reportUser(with: model) { result in
            
            dismissProgressBar()
            
            switch result {
            
            case .success(_):
                
                SnackBar.make(in: self.view,
                              message: "신고가 정상적으로 접수되었습니다. 감사합니다 😁",
                              duration: .lengthLong).show()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    
                    self.dismiss(animated: true)
                }
                
            case .failure(let error):
                SnackBar.make(in: self.view,
                              message: error.errorDescription,
                              duration: .lengthLong).show()
            }
        }
    }

}


//MARK: - Initialization

extension ReportUserViewController {
    
    func initialize() {
        
        initializeTextView()
        initializeButton()
    }
    
    func initializeTextView() {
        
        contentTextView.delegate = self
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.cornerRadius = 10.0
        contentTextView.layer.borderColor = UIColor.lightGray.cgColor
        contentTextView.clipsToBounds = true
        contentTextView.font = UIFont.systemFont(ofSize: 15)
        contentTextView.text = "신고 내용을 적어주세요 🤔"
        contentTextView.textColor = UIColor.lightGray
    }
    
    func initializeButton() {
        sendButton.layer.cornerRadius = 10
    }
}

//MARK: - Input Validation

extension ReportUserViewController {
    
    func validateUserInput() -> Bool {
        
        guard let content = contentTextView.text else { return false }
        
        if content.count >= 3 { return true }
        else {
            SnackBar.make(in: self.view,
                          message: "신고 내용을 3글자 이상 적어주세요 👀",
                          duration: .lengthLong).show()
            return false
        }
    }
}

//MARK: - UITextViewDelegate

extension ReportUserViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    
        if textView.text.isEmpty {
            textView.text = "신고 내용을 적어주세요 🤔"
            textView.textColor = UIColor.lightGray
            return
        }
    }
}
