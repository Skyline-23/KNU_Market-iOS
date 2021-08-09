import Foundation
import SwiftyJSON

enum NetworkError: String, Error {
    
    // invalid account error
    case E101 = "E101"
    case E102 = "E102"
    case E103 = "E103"
    case E104 = "E104"
    case E105 = "E105"
    case E106 = "E106"
    case E107 = "E107"
    case E108 = "E108"
    case E109 = "E109"
    
    // invalid request
    case E201 = "E201"
    
    // invalid grant
    case E301 = "E301"
    case E302 = "E302"
    case E303 = "E303"
    
    // invalid form
    case E401 = "E401"
    case E402 = "E402"
    
    // invalid file
    case E501 = "E501"
    
    // invalid post
    case E601 = "E601"
    
    // network error
    case E000 = "E000"
    
    var errorDescription: String {
        
        switch self {
        
        case .E000:
            return "일시적인 서비스 오류입니다 😢 잠시 후 다시 시도해주세요."
        case .E101:
            return "아이디 또는 비밀번호가 일치하지 않습니다."
        case .E102:
            return "이미 존재하는 계정입니다.🧐"
        case .E103:
            return "잘못된 아이디 형식입니다."
        case .E104:
            return "잘못된 비밀번호 형식입니다."
        case .E105:
            return "잘못된 이메일 형식입니다."
        case .E106:
            return "인증 코드가 일치하지 않습니다. 다시 입력해주세요."
        case .E107:
            return "이메일 인증이 필요합니다.🧐"
        case .E108:
            return "이미 참여하고 있는 공구입니다."
        case .E109:
            return "권한이 없습니다."
   
        case .E201:
            return "refresh_token 누락"
            
        case .E301:
            return "로그인 세션이 만료되었습니다.🧐" // refreshToken 만료
        case .E302:
            return "로그인 세션이 만료되었습니다.🧐" // accessToken 만료
        case .E303:
            return "중복 데이터가 존재합니다."
            
        case .E401:
            return "잘못된 요청입니다.🤔"
        case .E402:
            return "잘못되거나 만료된 요청입니다."
            
        case .E501:
            return "존재하지 않는 파일입니다."
            
        case .E601:
            return "존재하지 않는 글입니다.🧐"
        }
    }
    
    
    static func returnError(json: Data) -> NetworkError {
        
        do {
            let json = try JSON(data: json)
            print("❗️ NetworkError - error JSON: \(json)")
            let errorCode = json["errorCode"].stringValue
            let errorDescription = json["errorDescription"].stringValue
            print("❗️ NetworkError - errorDescription: \(errorDescription)")
            print("❗️ NetworkError - errorCode: \(String(describing: NetworkError(rawValue: errorCode)))")
        
            if errorCode == "E109" {
                
                print("✏️ NotificationCenter POST- presentVerifyEmailVC ACTIVATED")
                NotificationCenter.default.post(name: Notification.Name.presentVerifyEmailVC, object: nil)
            }
            
    
            return NetworkError(rawValue: errorCode) ?? .E000
        } catch {
            print("❗️ NetworkError - catch has been ACTIVATED")
            return .E000
        }
    }
    
}
