//
//  ViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import NMapsMap
import Firebase
import FirebaseFirestore
import MaterialComponents.MaterialBottomSheet
import Alamofire
import SwiftyJSON
import Photos
import BSImagePicker
import FirebaseStorage


class mapViewController: UIViewController, NMFMapViewCameraDelegate {

    var paramSender1 = UIApplication.shared.delegate as? AppDelegate// 딕셔너리형 데이터에서 콜렉션네임의 값을 불러옴
    @IBOutlet weak var mapView: NMFMapView!
    let db = Firestore.firestore()
    let infoWindow = NMFInfoWindow()
    let dataSource = NMFInfoWindowDefaultTextSource.data()
    let userEmail = UserDefaults.standard.string(forKey: "userEmail")
    var api: ApiModel =  ApiModel()
    
    @IBOutlet weak var searchBar: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        //print(postData.userId)
        mapView.mapType = .navi
        mapView.isIndoorMapEnabled = true
        mapView.isNightModeEnabled = false
        //editMarker(37.22, 126.77,"test")
        
        func mapView1(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            infoWindow.close()
            
        } //지도 탭 했을때 정보창 닫히게 하는 함수
    }

    override func viewWillAppear(_ animated: Bool) { //맵컨트롤러가 리로드 될때마다 맵뷰에서 새로운 앱을 가져옴
        let allJson = api.getAll()
        for (_, subJson): (String, JSON) in allJson {
            paramSender1?.MyPics.append(PicData(json: subJson))
        }
    }
    
    func cameraPosition(_ latitude:Double,_ longitude:Double){
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 3
        mapView.moveCamera(cameraUpdate)
    }
    
    func editMarker(_ pic: PicData, _ isBound: Bool) {
        let sdkBundle = Bundle.naverMapFramework()
        if !isBound {
            pic.marker = nil
            return
        }
        pic.marker! = NMFMarker()
        print("marker")
        print(pic.latitude!)
        print(pic.longitude!)
        pic.marker!.position = NMGLatLng(lat: pic.latitude!, lng: pic.longitude!)
        pic.marker!.iconImage = NMF_MARKER_IMAGE_RED
        pic.marker!.mapView = mapView
        //cameraPosition(latitude, longitude)
        //dataSource.title = title
        //infoWindow.dataSource = dataSource
        
        
        // 2021.11.09 마커 터치핸들러 이동시 -> 카메라 시점 변환 주기 -> cameraPosition()함수 제작
        pic.marker!.touchHandler = {(overlay) in
            if let marker1 = overlay as? NMFMarker{
                if marker1.iconImage.reuseIdentifier == "\(sdkBundle.bundleIdentifier ?? "").mSNormal"{
                    self.cameraPosition(pic.latitude!, pic.longitude!)
                    marker1.iconImage = NMFOverlayImage(name:"mSNormalNight", in: Bundle.naverMapFramework())
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "bottomsheetViewController") as! UIViewController
                    let vc = self.storyboard?.instantiateViewController(identifier: "bottomsheetViewController") as! bottomsheetViewController
                    // MDC 바텀 시트로 실행
                    vc.userid = pic.ownerID
                    vc.latS = String(pic.latitude!)
                    vc.lngS = String(pic.longitude!)
                    
                    
                    let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
                    
                    bottomSheet.scrimColor = UIColor.systemGray.withAlphaComponent(0.3)
                    // 보여주기
                    self.present(bottomSheet, animated: true, completion: nil)
                    self.dataSource.title = pic.memo!
                    self.infoWindow.dataSource = self.dataSource
                    self.infoWindow.open(with: pic.marker!)
                }else{
                    marker1.iconImage = NMFOverlayImage(name: "mSNormal", in: Bundle.naverMapFramework())
                    self.infoWindow.close()
                }
            }
            return true
        }
        
    }
    
    @IBAction func showImagePicker(_ sender: UIBarButtonItem) {
        let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        var evenAssets = [PHAsset]()
        let imagePicker = ImagePickerController(selectedAssets: evenAssets)
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.max = 5 // 이미지 피커의 선택 갯수제한 5장
        self.presentImagePicker(imagePicker, select: { (asset) in
            print("Selected: \(asset)")
            
            print("test7870 >>\((asset.localIdentifier))")
            
        }, deselect: { (asset) in
            print("Deselected: \(asset)")
        }, cancel: { (assets) in
            print("Canceled with sefgvlections: \(assets)")
        }, finish: { (assets) in
            for asset in assets {
                self.dismiss(animated: true, completion: nil)
                let pic = PicData(asset: asset)
                pic.ownerID = UserDefaults.standard.string(forKey: "userEmail")
                self.paramSender1?.MyPics.append(pic)
                
                if let lat = pic.latitude, let lng = pic.longitude {
                    let titleAlert = UIAlertController(title: "부가설정", message: "메모와 친구를 입력하세여.", preferredStyle: .alert)
                    titleAlert.addTextField { UITextField in
                        UITextField.placeholder = "메모설정"
                    }
                    titleAlert.addTextField { UITextField in
                        UITextField.placeholder = "보여질 친구의 이메일"
                    }
                    let ok = UIAlertAction(title: "업로드", style: .default) { UIAlertAction in
                        
                        let title = titleAlert.textFields?[0].text
                        let friend = titleAlert.textFields?[1].text
                        pic.memo = title
                        
                        pic.markerId = self.api.postMarker(pic)
                        print("markerid=\(pic.markerId)")
                        
                        
                        print("title > \(title) 변경후 \(title as! String)")
                        //이미지post 함수 실행
                       
                    }
                    titleAlert.addAction(ok)
                    self.present(titleAlert, animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print("위경도 값이 없습니다")
                }
            }
        })
    }
        
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        var cameraPosition:NMFCameraPosition
        print(cameraPosition)
        let projection = mapView.projection
        let bound = projection.latlngBounds(fromViewBounds: mapView.frame)
        for i in 0..<(self.paramSender1?.MyPics.count)! {
            print("i=\(i)")
            let lat = self.paramSender1?.MyPics[i].latitude
            let lng = self.paramSender1?.MyPics[i].longitude
            editMarker((self.paramSender1?.MyPics[i])!, bound.hasPoint(NMGLatLng(lat: lat!, lng: lng!)))
        }

    }
}
