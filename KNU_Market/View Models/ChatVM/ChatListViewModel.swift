import Foundation
import Alamofire

protocol ChatListViewModelDelegate: AnyObject {
    
    func didFetchChatList()
    func failedFetchingChatList(with error: NetworkError)
}

class ChatListViewModel {

    weak var delegate: ChatListViewModelDelegate?
    
    var roomList: [Room] = [Room]()
    
}

//MARK: - API Methods

extension ChatListViewModel {
    
    // 전체 채팅 목록 불러오기
    func fetchChatList() {
        
        self.roomList.removeAll()
        
        ChatManager.shared.getResponseModel(function: .getRoom,
                                       method: .get,
                                       pid: nil,
                                       index: nil,
                                       expectedModel: [Room].self) { [weak self] result in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let chatRoom):
        
                // 빈 배열인지 확인해야 하나?
                
                self.roomList.append(contentsOf: chatRoom)
                self.delegate?.didFetchChatList()
                
            case .failure(let error):
                self.delegate?.failedFetchingChatList(with: error)
            }
        }
    }
    
}

