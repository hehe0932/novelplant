//
//  URLConst.swift
//  Moyi
//
//  Created by hehe on 2023/3/9.
//

import Foundation
struct URLConst {
#if DEBUG
    static let baseURL = "http://101.47.131.70:21000/"
    static let baseURL_se = "http://101.47.131.70:21000/"
    static let baseURL_st = "http://101.47.131.70:21000/"
    static let baseH5Url = "https://launch.novelsbd.com/stg/"

#else
    static let baseURL = "https://tempapp1.inovelclub.com/"
    static let baseURL_se = "https://se1.inovelclub.com/"
    static let baseURL_st = "https://st1.inovelclub.com/"
    static let baseH5Url = "https://data.novelsbd.com/"
    

#endif
    
}
