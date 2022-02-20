import UIKit
import SwiftKeychainWrapper

class User {

    //MARK: - Singleton
    static let shared: User = User()
        
    //MARK: - Properties
    
    var userUID: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.userUID) ?? "userUID 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.userUID)
        }
    }
    
    var userID: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.username) ?? "아이디 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.username)
        }
    }
    
    var nickname: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.displayName) ?? "닉네임 표시 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.displayName)
        }
    }
    
    var fcmToken: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.fcmToken) ?? "fcmToken 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.fcmToken)
        }
    }
    
    var email: String = ""
    
    var emailForPasswordLoss: String {
        get {
            return UserDefaults.standard.string(forKey:UserDefaults.Keys.emailForPasswordLoss) ?? "-"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.emailForPasswordLoss)
        }
    }
    
    var isLoggedIn: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.Keys.isLoggedIn)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.isLoggedIn)
        }
    }
    
    var hasAllowedForNotification: Bool {
        get {
            return UserDefaults.standard.bool(forKey: UserDefaults.Keys.hasAllowedForNotification)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.hasAllowedForNotification)
        }
        
    }
    
    
    //MARK: - Access Token Related Properties
    
    var accessToken: String {
        
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.accessToken) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.accessToken)
        }
        

    }
    
    var refreshToken: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.refreshToken) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.refreshToken)
        }
    }
        
    var savedAccessToken: Bool = false
    var savedRefreshToken: Bool = false
    
    //MARK: - User Profile Image Related Properties
    
    var profileImage: UIImage? {
        didSet {
            guard let imageData = profileImage?.jpegData(compressionQuality: 1.0) else {
                profileImageCache.removeAllObjects()
                return
            }
            self.profileImageData = imageData
        }
    }
    var profileImageData: Data?
    
    var profileImageUID: String {
        get {
            return UserDefaults.standard.string(forKey: UserDefaults.Keys.profileImageUID) ?? "표시 에러"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.profileImageUID)
        }
    }
    
    
    // 내가 참여하고 있는 채팅방 PID 배열
    // PID == Post ID (각 공구글에 해당하는 고유 Id값)
    var joinedChatRoomPIDs: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.joinedChatRoomPIDs) ?? [String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.joinedChatRoomPIDs)
           
        }
    }

    
    var chatNotificationList: [String] {
        get {
            let list = UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.notificationList) ?? [String]()
            return list
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.notificationList)
            print("✅ chatNotificationList: \(newValue)")
        }
    }
    
    var bannedPostUploaders: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.bannedPostUploaders) ?? [String]()
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.bannedPostUploaders)
        }
    }
    
    var bannedChatMembers: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: UserDefaults.Keys.bannedChatUsers) ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.bannedChatUsers)
        }
    }
    
    //MARK: - 팝업 관련
    
    var userSetPopupBlockDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: UserDefaults.Keys.userSetPopupBlockDate) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaults.Keys.userSetPopupBlockDate)
        }
    }

    //MARK: - User Settings
    
    var postFilterOption: PostFilterOptions {
        get {
            guard let filterOption = UserDefaults.standard.object(
                forKey: UserDefaults.Keys.postFilterOptions
            ) as? String else { return .showByRecentDate }
            
            return PostFilterOptions(rawValue: filterOption) ?? .showByRecentDate
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaults.Keys.postFilterOptions)
        }
    }
}

//MARK: - Methods

extension User {

    func resetAllUserInfo() {
        
        UIApplication.shared.unregisterForRemoteNotifications()

        nickname = ""
        email = ""
        profileImage = nil
        profileImageData = nil
        profileImageUID = ""
        
        
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.username)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.displayName)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.profileImageUID)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.isLoggedIn)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.userUID)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.emailForPasswordLoss)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.fcmToken)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.hasAllowedForNotification)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.bannedPostUploaders)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.bannedChatUsers)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.notificationList)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.isNotFirstAppLaunch)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.postFilterOptions)
        UserDefaults.standard.removeObject(forKey: UserDefaults.Keys.userSetPopupBlockDate)
    
        
        ChatNotifications.list.removeAll()

        let _: Bool = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.accessToken)
        let _: Bool = KeychainWrapper.standard.removeObject(forKey: K.KeyChainKey.refreshToken)

        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        profileImageCache.removeAllObjects()
        
        print("✏️ resetAllUserInfo successful")
    }
    
}
