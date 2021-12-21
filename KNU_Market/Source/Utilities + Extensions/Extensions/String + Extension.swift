import UIKit

extension String {
    
    
    var isValidID: ValidationError.OnRegister {
        guard !self.isEmpty else { return ValidationError.OnRegister.empty }
        
        if self.count < 4 || self.count > 50 {
            return ValidationError.OnRegister.incorrectIdLength
        }
        
        let idRegEx = "^([0-9a-z`~!@#$%^&*()\\-_=+\\[{\\]}\\\\|;:'\",<.>/?]{4,50})$"
        let idCheck = NSPredicate(format:"SELF MATCHES %@", idRegEx).evaluate(with: self)
        return idCheck
        ? ValidationError.OnRegister.correct
        : ValidationError.OnRegister.incorrectIdFormat
    }
    
    
    // 숫자+문자 포함해서 8~20글자 사이의 text 체크하는 정규표현식
    func isValidPassword(alongWith password: String) -> ValidationError.OnRegister {
        guard !self.isEmpty, !password.isEmpty else { return ValidationError.OnRegister.empty }

        guard self.count >= 8, self.count <= 20 else {
            return ValidationError.OnRegister.incorrectPasswordFormat
        }
        
        guard self == password else {
            return ValidationError.OnRegister.passwordDoesNotMatch
        }
        
        let passwordREGEX = ("(?=.*[A-Za-z])(?=.*[0-9]).{8,20}")
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", passwordREGEX).evaluate(with: self)
        
        return passwordCheck
        ? ValidationError.OnRegister.correct
        : ValidationError.OnRegister.incorrectPasswordFormat
    }
    
    var isValidNickname: ValidationError.OnRegister {
        guard !self.isEmpty else { return ValidationError.OnRegister.empty }
        
        if self.hasEmojis, self.hasSpecialCharacters {
            return ValidationError.OnRegister.incorrectNicknameFormat
        }
        
        guard self.count >= 2 && self.count <= 10 else {
            return ValidationError.OnRegister.incorrectNicknameLength
        }
        return ValidationError.OnRegister.correct
    }

}

extension String {
    
    func convertStringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let convertedDate = dateFormatter.date(from: self) else {
            return Date()
        }
        return convertedDate
    }
    
    var hasEmojis: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
                 0x1F300...0x1F5FF, // Misc Symbols and Pictographs
                 0x1F680...0x1F6FF, // Transport and Map
                 0x2600...0x26FF,   // Misc symbols
                 0x2700...0x27BF,   // Dingbats
                 0xFE00...0xFE0F,   // Variation Selectors
                 0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
                 0x1F1E6...0x1F1FF: // Flags
                return true
            default:
                continue
            }
        }
        return false
    }
    
    var hasSpecialCharacters: Bool {

        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .caseInsensitive)
            if let _ = regex.firstMatch (
                in: self,
                options: NSRegularExpression.MatchingOptions.reportCompletion,
                range: NSMakeRange(0, self.count)
            ) {
                return true
            }

        } catch { return false }

        return false
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
    
    var isValidId: Bool {
        let idRegEx = "^([0-9a-z`~!@#$%^&*()\\-_=+\\[{\\]}\\\\|;:'\",<.>/?]{4,50})$"
        let idTest = NSPredicate(format:"SELF MATCHES %@", idRegEx)
        return idTest.evaluate(with: self)
    }
    

    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }
    
    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        return String(self[start...])
    }
    
    func attributedStringWithColor(_ strings: [String], color: UIColor, characterSpacing: UInt? = nil) -> NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: self)
        for string in strings {
            let range = (self as NSString).range(of: string)
            attributedString.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: color,
                range: range
            )
        }

        guard let characterSpacing = characterSpacing else { return attributedString }

        attributedString.addAttribute(
            NSAttributedString.Key.kern,
            value: characterSpacing,
            range: NSRange(location: 0, length: attributedString.length)
        )

        return attributedString
    }

}
