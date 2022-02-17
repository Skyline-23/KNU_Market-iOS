//
//  ReportServiceType.swift
//  KNU_Market
//
//  Created by Kevin Kim on 2021/12/29.
//

import Foundation
import RxSwift

protocol ReportServiceType: AnyObject {
    
    
    func report(with model: ReportRequestDTO) -> Single<NetworkResult>
    
    
    
    
    func reportUser(with model: ReportRequestDTO) -> Single<NetworkResult>
    func writeReport(_ title: String, _ content: String, _ media1: Data?, _ media2: Data?) -> Single<NetworkResult>
    func viewMessage(_ uid: Int) -> Single<NetworkResult>
}
