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
import Floaty


class mapViewController: UIViewController, NMFMapViewCameraDelegate {

    //var paramSender1 = UIApplication.shared.delegate as? AppDelegate// 딕셔너리형 데이터에서 콜렉션네임의 값을 불러옴
    let singleton = MySingleton.shared
    @IBOutlet weak var mapView: NMFMapView!
    let db = Firestore.firestore()
    let infoWindow = NMFInfoWindow()
    let dataSource = NMFInfoWindowDefaultTextSource.data()
    let userEmail = UserDefaults.standard.string(forKey: "userEmail")
    var api: ApiModel = ApiModel()
    let floaty = Floaty()
    
    @IBOutlet weak var searchBar: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = nil
        self.view.addSubview(self.floaty)
        print(userEmail!)
        var allJson:JSON = JSON()
        DispatchQueue.global().async {
            allJson = self.api.getAll()
            for (_, subJson) in allJson {
                self.singleton.MyPics.append(PicData(json: subJson))
            }
            print("PicCount=\(self.singleton.MyPics.count)")
        }
        
        
        mapView.addCameraDelegate(delegate: self)
        mapView.mapType = .navi
        mapView.isIndoorMapEnabled = true
        mapView.isNightModeEnabled = false
        //editMarker(37.22, 126.77,"test")
        
        
        func mapView1(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
            infoWindow.close()
        } //지도 탭 했을때 정보창 닫히게 하는 함수
        
        let uploadItem = FloatyItem()
        uploadItem.icon = UIImage(systemName: "arrow.up")
        uploadItem.handler = { item in
            let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
            var evenAssets = [PHAsset]()
            let imagePicker = ImagePickerController(selectedAssets: evenAssets)
            imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
            imagePicker.settings.selection.max = 5 // 이미지 피커의 선택 갯수제한 5장
            self.presentImagePicker(imagePicker, select: { (asset) in
                print("Selected: \(asset)")
                
            }, deselect: { (asset) in
                print("Deselected: \(asset)")
            }, cancel: { (assets) in
                print("Canceled with sefgvlections: \(assets)")
            }, finish: { (assets) in
                for asset in assets {
                    self.dismiss(animated: true, completion: nil)
                    var pic = PicData(asset: asset)
                    pic.ownerID = UserDefaults.standard.string(forKey: "userEmail")
                    if let lat = pic.latitude, let lng = pic.longitude {
                        let sema = DispatchSemaphore(value: 0)
                        var mkid = 0
                        DispatchQueue.global().async {
                            pic.address = self.api.getAddr(lng: lng, lat: lat)
                            print("pic.address=\(pic.address!)")
                            for myPic in self.singleton.MyPics {
                                if myPic.address! == pic.address! {
                                    print("mkid=\(myPic.markerId!)")
                                    mkid = myPic.markerId!
                                    pic.markerId = mkid
                                    break
                                }
                            }
                            sema.signal()
                        }
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
                            DispatchQueue.global().async {
                                self.api.postMarker(&pic)
                                self.singleton.MyPics.append(pic)
                            }
                        }
                        titleAlert.addAction(ok)
                        DispatchQueue.global().async {
                            sema.wait(timeout: .now() + 5)
                            if mkid == 0 {      // 새로 마커 찍을때만 메모 입력
                                self.present(titleAlert, animated: true, completion: nil)
                            } else {
                                self.api.postImg(&pic)
                                for i in 0..<self.singleton.MyPics.count {
                                    if self.singleton.MyPics[i].markerId != mkid {
                                        continue
                                    }
                                    self.singleton.MyPics[i].imgPath.append(pic.imgPath[0])
                                    break
                                }
                                
                            }
                        }
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        print("위경도 값이 없습니다")
                    }
                }
            })
        }
        self.floaty.addItem(item: uploadItem)
        let accountItem = FloatyItem()
        accountItem.icon = UIImage(systemName: "person.fill")
        accountItem.handler = { item in
            // account handler
            
        }
        self.floaty.addItem(item: accountItem)
        
    }
    
    func cameraPosition(_ latitude:Double,_ longitude:Double){
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 3
        mapView.moveCamera(cameraUpdate)
    }
    
    func editMarker(_ pic: inout PicData, _ isBound: Bool) {
        // 화면 영역에 없을 시 마커를 해제합니다
        if !isBound {
            if let _ = pic.marker {
                pic.marker!.mapView = nil
            }
            return
        }
        if pic.marker == nil {
            pic.marker = NMFMarker()
        }
        let sdkBundle = Bundle.naverMapFramework()
        let mkid = pic.markerId!
        let lat = pic.latitude!
        let lng = pic.longitude!
        let owner = pic.ownerID
        let memo = pic.memo!
        let imgPath = pic.imgPath
        pic.marker!.position = NMGLatLng(lat: pic.latitude!, lng: pic.longitude!)
        pic.marker!.iconImage = NMF_MARKER_IMAGE_RED
        pic.marker!.mapView = mapView
        // 2021.11.09 마커 터치핸들러 이동시 -> 카메라 시점 변환 주기 -> cameraPosition()함수 제작
        pic.marker!.touchHandler = {(overlay) in
            if let marker1 = overlay as? NMFMarker{
                if marker1.iconImage.reuseIdentifier == "\(sdkBundle.bundleIdentifier ?? "").mSNormal"{
                    self.cameraPosition(lat, lng)
                    marker1.iconImage = NMFOverlayImage(name:"mSNormalNight", in: Bundle.naverMapFramework())
                    //let vc = self.storyboard?.instantiateViewController(withIdentifier: "bottomsheetViewController") as! UIViewController
                    let vc = self.storyboard?.instantiateViewController(identifier: "bottomsheetViewController") as! bottomsheetViewController
                    // MDC 바텀 시트로 실행
                    vc.userid = owner
                    vc.paths = imgPath
                    
                    let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
                    bottomSheet.scrimColor = UIColor.systemGray.withAlphaComponent(0.3) //시스템배경색 그레이로 11.21
                    bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 300 // 바텀시트길이
                    // 보여주기
                    self.present(bottomSheet, animated: true, completion: nil)
                    
                    self.dataSource.title = memo
                    self.infoWindow.dataSource = self.dataSource
                    self.infoWindow.open(with: marker1)
                }else{
                    marker1.iconImage = NMFOverlayImage(name: "mSNormal", in: Bundle.naverMapFramework())
                    self.infoWindow.close()
                }
            }
            return true
        }
        
    }
    
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let bound = mapView.contentBounds
        for i in 0..<self.singleton.MyPics.count {
            if let lat = self.singleton.MyPics[i].latitude, let lng = self.singleton.MyPics[i].longitude {
                editMarker(&self.singleton.MyPics[i], bound.hasPoint(NMGLatLng(lat: lat, lng: lng)))
            }
        }
    }
}
