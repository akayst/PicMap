//
//  bottomsheetViewController.swift
//  PicMap
//
//  Created by akay on 2021/11/05.
//

import UIKit
import Firebase
import NMapsMap
import Kingfisher
class imgCollectionCell : UICollectionViewCell{
    
    @IBOutlet var imgtest: UIImageView!
    
}


class bottomsheetViewController: UIViewController{
    
    let singleton = MySingleton.shared
    var pic:PicData?
    var paths:[String] = []
    var memo:String?
    var markerId:Int?
    var isHide:Bool?
    var address:String?
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var memoLabel: UILabel!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBAction func onDel(_ sender: UIButton) {
        let alert = UIAlertController(title: "마커 삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "네", style: .default, handler: { action in
            ApiModel().delMarker(self.markerId!) { isSuccess in
                if isSuccess {
                    for i in 0..<self.singleton.MyPics.count {
                        if self.singleton.MyPics[i].markerId == self.markerId {
                            self.singleton.MyPics[i].latitude = 0.0
                            self.singleton.MyPics[i].longitude = 0.0
                            self.singleton.MyPics.remove(at: i)
                            break
                        }
                    }
                    self.dismiss(animated: true)
                } else {
                    print("삭제 실패")
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "괜찮아요", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memoLabel.text = "\(self.memo!)"
        self.delBtn.setTitle("", for: .normal)
        self.delBtn.isHidden = self.isHide!
        self.addressLabel.text = self.address
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
