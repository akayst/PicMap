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

final class imgCollectionCell : UICollectionViewCell {
    @IBOutlet var imgtest: UIImageView!
}


final class bottomsheetViewController: UIViewController {
    
    let singleton = MySingleton.shared
    var picData: PicData?
    
    @IBOutlet private weak var delBtn: UIButton!
    @IBOutlet private weak var memoLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    
    @IBAction private func onDel(_ sender: UIButton) {
        let alert = UIAlertController(title: "마커 삭제", message: "정말로 삭제하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "네", style: .default, handler: { action in
            ApiModel().delMarker(self.picData?.markerId) { isSuccess in
                if isSuccess {
                    for i in 0..<self.singleton.MyPics.count {
                        if self.singleton.MyPics[i].markerId == self.picData?.markerId {
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
        self.memoLabel.text = "\(self.picData?.memo ?? "")"
        self.delBtn.setTitle("", for: .normal)
        self.delBtn.isHidden = self.picData?.isMine ?? false
        self.addressLabel.text = self.picData?.address
    }
}

extension bottomsheetViewController: UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picData?.imgPath.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imgcell", for: indexPath) as? imgCollectionCell else{
            return UICollectionViewCell()
        }
        let cache = ImageCache.default
        cache.retrieveImage(forKey: self.picData?.imgPath[indexPath.row] ?? "", options: nil) { result in
            switch result{
            case .success(let value):
                if let image = value.image{
                    print("caching memory")
                    cell.imgtest?.image = image
                }
                else{
                    guard let url = URL(string: self.picData?.imgPath[indexPath.row] ?? "") else { return }
                    let resource = ImageResource(downloadURL: url, cacheKey: self.picData?.imgPath[indexPath.row] ?? "")
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
