import Foundation
import Alamofire

//MARK: - 회원가입용 Model
/*
 - URI : POST /api/v1/auth
 - Content-Type: multipart/form-data
 
 - Request Body:
 "id" : "string",
 "password" : "string",
 "nickname" : "string",
 "image" : "string"
 
 - Response:
 -> 201 Created
 
 -> 403 Forbidden
 "errorMessage" : "string"
 "errorCode" : "string"
 "errorDescription" : "string"
 */

struct RegisterRequestDTO {
     
    let id: String
    let password: String
    let nickname: String
    let imageData: Data?
    let fcmToken: String
    
    init(id: String, password: String, nickname: String, image: Data?, fcmToken: String) {
        
        self.id = id
        self.password = password
        self.nickname = nickname
        self.fcmToken = fcmToken
        
        if let profileImageData = image {
            self.imageData = profileImageData
        } else { self.imageData = nil }
    }

    let headers: HTTPHeaders = [
        HTTPHeaderKeys.contentType.rawValue: HTTPHeaderValues.multipartFormData.rawValue]
    
}
