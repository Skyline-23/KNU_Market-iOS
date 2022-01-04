//
//  ChatListViewReactor.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2022/01/04.
//

import Foundation
import RxSwift
import ReactorKit

final class ChatListViewReactor: Reactor {
    
    let initialState: State
    let chatListService: ChatListServiceType
    let userDefaultsGenericService: UserDefaultsGenericServiceType
    
    enum Action {
        case getChatList
        case viewDidDisappear
    }
    
    enum Mutation {
        
        case setChatList([Room])
        case setApplicationIconBadgeNumber(Int)
        case removeAllDeliveredNotifications
        case setNeedsToShowEmptyView(Bool)
        case setErrorMessage(String)
        case setFetchingData(Bool)
    }
    
    struct State {
        
        var roomList: [Room] = [] {
            willSet {
                self.roomList.removeAll()       // 한 번에 다 불러오기 때문에 기존값 초기화 먼저 수행
            }
        }
        
        var isFetchingData: Bool = false
        var needsToShowEmptyView: Bool = false
        var errorMessage: String?
    }
    
    init(chatListService: ChatListServiceType, userDefaultsGenericService: UserDefaultsGenericServiceType) {
        self.chatListService = chatListService
        self.userDefaultsGenericService = userDefaultsGenericService
        self.initialState = State()
    }
    
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .getChatList:
        
            NotificationCenter.default.post(name: .getBadgeValue, object: nil)
            
            guard currentState.isFetchingData == false else { return Observable.empty() }
            
            guard let chatNotificationList: [String] = userDefaultsGenericService.get(key: UserDefaults.Keys.notificationList)
            else { return Observable.empty() }
            
            return Observable.concat([
                
                Observable.just(Mutation.setFetchingData(true)),
                Observable.just(Mutation.setApplicationIconBadgeNumber(chatNotificationList.count)),
                Observable.just(Mutation.removeAllDeliveredNotifications),
                
                self.chatListService.fetchJoinedChatList()
                    .asObservable()
                    .map { result in
                        switch result {
                        case .success(let rooms):
                            
                            // 참여하고 있는 공구 리스트 값 User Defaults에 저장
                            self.userDefaultsGenericService.set(
                                key: UserDefaults.Keys.joinedChatRoomPIDs,
                                value: rooms.map { $0.uuid }
                            )
                            return Mutation.setChatList(rooms)
                            
                        case .error(_):
                            return Mutation.setErrorMessage("채팅 목록을 불러오지 못했습니다.😥")
                        }
                    },
                
                Observable.just(Mutation.setFetchingData(false))
            ])
            
        case .viewDidDisappear:
            return Observable.just(Mutation.setFetchingData(false))
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        state.errorMessage = nil
        state.needsToShowEmptyView = false
        
        switch mutation {
            
        case .setChatList(let rooms):
            state.roomList = sortChatListWithPendingNotificationRoomsFirst(rooms)
            
        case .setApplicationIconBadgeNumber(let badgeNumber):
            UIApplication.shared.applicationIconBadgeNumber = badgeNumber
            
        case .removeAllDeliveredNotifications:
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            
        case .setNeedsToShowEmptyView(let needsToShow):
            state.needsToShowEmptyView = needsToShow
            
        case .setErrorMessage(let errorMessage):
            state.errorMessage = errorMessage
            
        case .setFetchingData(let isFetching):
            state.isFetchingData = isFetching
        }
        return state
        
    }

}

extension ChatListViewReactor {
    
    private func sortChatListWithPendingNotificationRoomsFirst(_ rooms: [Room]) -> [Room] {
        
        var sortedChatList: [Room] = []
        
        let chatNotificationList: [String] = userDefaultsGenericService.get(key: UserDefaults.Keys.notificationList) ?? []
        
        rooms.forEach { room in
            chatNotificationList.contains(room.uuid)
            ? sortedChatList.insert(room, at: 0)
            : sortedChatList.append(room)
        }
        return sortedChatList
    }
}
