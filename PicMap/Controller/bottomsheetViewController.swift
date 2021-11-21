//
//  bottomsheetViewController.swift
//  PicMap
//
//  Created by akay on 2021/11/05.
//

import UIKit
import Firebase
import NMapsMap
import FirebaseFirestore
import Kingfisher
class imgCollectionCell : UICollectionViewCell{
    
    @IBOutlet var imgtest: UIImageView!
    
}


class bottomsheetViewController: UIViewController{
    
    let db = Firestore.firestore()
    var pic:PicData?
    var userid:String?
    var paths:[String] = []
    var latS:String?
    var lngS:String?
    
    
    @IBOutlet weak var IdBottom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleton = MySingleton.shared
        //let url = URL(string: latS!)
        // Double(latData as! Substring)!
        IdBottom.text = "\(self.userid!)"
        
    }
}

extension bottomsheetViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return paths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgcell", for: indexPath) as? imgCollectionCell else{
            return UICollectionViewCell()
        }
        let cache = ImageCache.default
        cache.retrieveImage(forKey: self.paths[indexPath.row], options: nil) { result in
            switch result{
            case .success(let value):
                if let image = value.image{
                    print("caching memory")
                    cell.imgtest?.image = image
                }
                else{
                    guard let url = URL(string: self.paths[indexPath.row]) else{return}
                    let resource = ImageResource(downloadURL: url, cacheKey: self.paths[indexPath.row])
                    cell.imgtest?.kf.indicatorType = .activity
                    cell.imgtest?.kf.setImage(with: resource,options: [.transition(.fade(0.6))])
                    
                }
            case .failure(_):
                print(Error.self)
            }
        }
        return cell
    }
}
