//
//  MySingleton.swift
//  PicMap
//
//  Created by akay on 2021/11/15.
//

class MySingleton {
    static let shared = MySingleton()
    var MyPics:[PicData] = []
    var imgPics:[String] = []
    private init(){
        
    }
}
