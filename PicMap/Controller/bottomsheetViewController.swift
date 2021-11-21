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
    var latS:String?
    var lngS:String?


    @IBOutlet weak var IdBottom: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let singleton = MySingleton.shared
        let url = URL(string: latS!)
       // Double(latData as! Substring)!
        IdBottom.text = "\(self.userid!)"
        print("test : \(latS!)")
       
        }
    }

extension bottomsheetViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgcell", for: indexPath) as? imgCollectionCell else{
            return UICollectionViewCell()
        }
     /*
        let url = URL(string: latS!)
        DispatchQueue.global().async {
            let data = try? Data(contentsOf: url!)
            DispatchQueue.main.async {
                let img = UIImage(data: data!)
                cell.imgtest?.image = img
            }
        */
        
        let cache = ImageCache.default
        cache.retrieveImage(forKey: latS!, options: nil) { result in
            switch result{
            case .success(let value):
                if let image = value.image{
                    print("caching memory")
                    cell.imgtest?.image = image
                }
                else{
                    guard let url = URL(string: self.latS!) else{return}
                    let resource = ImageResource(downloadURL: url, cacheKey: self.latS!)
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
