//
//  PostService.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/14.
//

import Foundation
import RxSwift

protocol PostServiceType: AnyObject {
    
    func fetchPostList(at index: Int, fetchCurrentUsers: Bool, postFilterOption: PostFilterOptions) -> Single<NetworkResultWithValue<[PostListModel]>>
    func uploadNewPost(with model: UploadPostRequestDTO) -> Single<NetworkResult>
    func updatePost(uid: String, with model: UpdatePostRequestDTO) -> Single<NetworkResult>
    func fetchPostDetails(uid: String) -> Single<NetworkResultWithValue<PostDetailModel>>
    func deletePost(uid: String) -> Single<NetworkResult>
    func fetchSearchResults(at index: Int, keyword: String) -> Single<NetworkResultWithValue<[PostListModel]>>
    func markPostDone(uid: String) -> Single<NetworkResult>
}

class PostService: PostServiceType {
    
    let network: Network<PostAPI>
    
    init(network: Network<PostAPI>) {
        self.network = network
    }
    
    #warning("PostListModel 은 원래 [PostListModel] 형태로 가져와야함")
    func fetchPostList(at index: Int, fetchCurrentUsers: Bool, postFilterOption: PostFilterOptions) -> Single<NetworkResultWithValue<[PostListModel]>> {
        
        return network.requestObject(.fetchPostList(index: index, fetchCurrentUsers: fetchCurrentUsers, postFilterOption: postFilterOption), type: PostListModel.self)
            .map { result in
                switch result {
                case .success(let postListModel):
                    return .success([postListModel])
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func uploadNewPost(with model: UploadPostRequestDTO) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.uploadNewPost(model: model))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func updatePost(uid: String, with model: UpdatePostRequestDTO) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.updatePost(uid: uid, model: model))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func fetchPostDetails(uid: String) -> Single<NetworkResultWithValue<PostDetailModel>> {
        
        return network.requestObject(.fetchPostDetails(uid: uid), type: PostDetailModel.self)
            .map { result in
                switch result {
                case .success(let model):
                    return .success(model)
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func deletePost(uid: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.deletePost(uid: uid))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    #warning("PostListModel 은 원래 [PostListModel] 형태로 가져와야함")
    func fetchSearchResults(at index: Int, keyword: String) -> Single<NetworkResultWithValue<[PostListModel]>> {
        
        return network.requestObject(.fetchSearchResults(index: index, keyword: keyword), type: PostListModel.self)
            .map { result in
                switch result {
                case .success(let postListModel):
                    return .success([postListModel])
                case .error(let error):
                    return .error(error)
                }
            }
    }
    
    func markPostDone(uid: String) -> Single<NetworkResult> {
        
        return network.requestWithoutMapping(.markPostDone(uid: uid))
            .map { result in
                switch result {
                case .success:
                    return .success
                case .error(let error):
                    return .error(error)
                }
            }
    }
}
