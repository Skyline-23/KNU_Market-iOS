//
//  ChatListViewController+ChatListViewModelDelegate.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/11/29.
//

import UIKit

extension ChatListViewController: ChatListViewModelDelegate {
    
    func didFetchChatList() {
        chatListTableView.refreshControl?.endRefreshing()

        NotificationCenter.default.post(name: .getBadgeValue, object: nil)
            
        if viewModel.roomList.count == 0 {
            chatListTableView.showEmptyView(
                imageName: K.Images.emptyChatList,
                text: "아직 활성화된 채팅방이 없네요!\n새로운 공구에 참여해보세요 :)"
            )
            chatListTableView.tableFooterView = UIView(frame: .zero)
        }

        chatListTableView.reloadData()
    }
    
    func failedFetchingChatList(with error: NetworkError) {
        
        chatListTableView.refreshControl?.endRefreshing()
        showSimpleBottomAlertWithAction(
            message: "채팅 목록을 불러오지 못했습니다 😥",
            buttonTitle: "재시도"
        ) {
            self.chatListTableView.refreshControl?.beginRefreshing()
            self.viewModel.fetchChatList()
        }
    }
    

    
}
