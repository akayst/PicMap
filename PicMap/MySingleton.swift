//
//  MySingleton.swift
//  PicMap
//
//  Created by 송준기 on 2021/11/14.
//

class MySingleton {
    static let shared = MySingleton()
    var MyPics:[PicData] = []
    private init(){
        
    }
}
