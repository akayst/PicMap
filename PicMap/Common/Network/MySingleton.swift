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

final class Coordinator {
    static let shared = Coordinator()
    var source: UIViewController?
    var destination: UIViewController?
    
    private init() {
        
    }
    
    func push() {
        guard let source = source, let dest = destination else { return }
        
        source.navigationController?.pushViewController(dest, animated: true)
    }
}
