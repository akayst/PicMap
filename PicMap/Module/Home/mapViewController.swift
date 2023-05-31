//
//  ViewController.swift
//  PicMap
//
//  Created by akay on 2021/10/30.
//

import UIKit
import NMapsMap
import Firebase
import MaterialComponents.MaterialBottomSheet
import SwiftyJSON
import Photos
import BSImagePicker
import Floaty
import CoreLocation
import MapKit

final class mapViewController: UIViewController {

    private let viewModel = mapViewModel()
    private let locationManager = CLLocationManager()
    private let floaty = Floaty()
    @IBOutlet private weak var mapView: NMFMapView!
    private let infoWindow = NMFInfoWindow()
    private let dataSource = NMFInfoWindowDefaultTextSource.data()
    @IBOutlet private var locationBtn: UIButton!
	@Inject private var repository: Repository

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupView()
        setupFloty()
    }
    
    private func setupFloty() {
        DispatchQueue.global().async {
            for (_, subJson) in self.viewModel.getAllData() {
                self.repository.myPics.append(PicData(json: subJson))
            }
            print("PicCount=\(self.repository.myPics.count)")
        }
        let logoutItem = FloatyItem()
        logoutItem.icon = UIImage(systemName: "power")
        logoutItem.handler = { item in
            do {
            try Auth.auth().signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
                }
            let pushVC = self.storyboard?.instantiateViewController(withIdentifier: "logoViewController")
            self.navigationController?.pushViewController(pushVC!, animated: true)
            
        }
        self.floaty.addItem(item: logoutItem)
        let uploadItem = FloatyItem()
        uploadItem.icon = UIImage(systemName: "arrow.up")
        uploadItem.handler = { item in
            let imagePicker = ImagePickerController(selectedAssets: [PHAsset]())
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
                            pic.address = self.viewModel.getAddr(lng: lng, lat: lat)
                            print("pic.address=\(pic.address!)")
							for myPic in self.repository.myPics {
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
                            pic.memo = title
                            DispatchQueue.global().async {
                                self.viewModel.postMarker(&pic)
								self.repository.myPics.append(pic)
                            }
                        }
                        titleAlert.addAction(ok)
                        DispatchQueue.global().async {
                            self.viewModel.sema.wait(timeout: .now() + 5)
                            if mkid == 0 {      // 새로 마커 찍을때만 메모 입력
                                DispatchQueue.main.sync {
                                    self.present(titleAlert, animated: true, completion: nil)
                                }
                            } else {
                                self.viewModel.postImage(&pic)
								for i in 0..<self.repository.myPics.count {
									if self.repository.myPics[i].markerId != mkid {
                                        continue
                                    }
									self.repository.myPics[i].imgPath.append(pic.imgPath[0])
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
    
    private func setupView() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.view.addSubview(self.floaty)
        
        mapView.positionMode = .direction
        mapView.positionMode = .compass
        mapView.addCameraDelegate(delegate: self)
        mapView.mapType = .navi
        mapView.isIndoorMapEnabled = true
        mapView.isNightModeEnabled = false
        
        // buttonSetup
        locationBtn.setTitle("", for: UIControl.State.selected)
        locationBtn.addTarget(self, action: #selector(locationTapped), for: .touchUpInside)
    }
    
    
    @objc func locationTapped(_ sender:UIButton) {
        if sender.isSelected == true{
            sender.isSelected = false
            mapView.positionMode = .direction
        }else{
            sender.isSelected = true
            mapView.positionMode = .compass
        }
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
        
        let tempPicData = PicData.init(makerId: pic.markerId,
                                       latitude: pic.latitude,
                                       longitude: pic.longitude,
                                       ownerId: pic.ownerID,
                                       memo: pic.memo,
                                       imgPath: pic.imgPath,
                                       address: pic.address)
        let isMine = tempPicData.isMine
        
        pic.marker!.position = NMGLatLng(lat: pic.latitude!, lng: pic.longitude!)
        pic.marker!.iconImage = isMine ? NMF_MARKER_IMAGE_GREEN : NMF_MARKER_IMAGE_LIGHTBLUE
        pic.marker!.mapView = mapView
        // 2021.11.09 마커 터치핸들러 이동시 -> 카메라 시점 변환 주기 -> cameraPosition()함수 제작
        pic.marker!.touchHandler = {(overlay) in
            if let _ = overlay as? NMFMarker {
                self.cameraPosition(tempPicData.latitude, tempPicData.longitude)
                self.showBottomSheet(picData: tempPicData)
            }else {
                print("마커 핸들러 생성 실패")
            }
            return true
        }
    }
}

extension mapViewController {
    func showBottomSheet(picData: PicData?) {
        guard let picData = picData,
              let vc = self.storyboard?.instantiateViewController(identifier: "bottomsheetViewController") as? bottomsheetViewController else { return }
        vc.picData = picData
        
        let bottomSheet = MDCBottomSheetController(contentViewController: vc)
        bottomSheet.scrimColor = UIColor.systemGray.withAlphaComponent(0.3)
        bottomSheet.mdc_bottomSheetPresentationController?.preferredSheetHeight = 300
        
        self.present(bottomSheet, animated: true) {
            self.cameraPosition(picData.latitude, picData.longitude)
        }
        
    }
}

extension mapViewController: NMFMapViewCameraDelegate {
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let bound = mapView.contentBounds
		for i in 0..<self.repository.myPics.count {
			if let lat = self.repository.myPics[i].latitude, let lng = self.repository.myPics[i].longitude {
				editMarker(&self.repository.myPics[i], bound.hasPoint(NMGLatLng(lat: lat, lng: lng)))
            }
        }
    }
    
    func mapView1(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        infoWindow.close()
    } //지도 탭 했을때 정보창 닫히게 하는 함수
    
    func cameraPosition(_ latitude:Double? ,_ longitude:Double?) {
        guard let latitude = latitude, let longitude = longitude else { return }
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 3
        mapView.moveCamera(cameraUpdate)
    }
}

extension mapViewController: CLLocationManagerDelegate {
    
    private func setupLocationManager() {
        locationManager.delegate = self //델리게이트 위임
        locationManager.desiredAccuracy = kCLLocationAccuracyBest //거리 정확도 설정
        locationManager.requestWhenInUseAuthorization() // 사용자에게 허용받기 alert띄워줌
        
        if CLLocationManager.locationServicesEnabled(){
            print("위치 서비스 on 상태")
            locationManager.startUpdatingLocation() //위치정보 받아오기 시작
            print("현재위치 : \(locationManager.location?.coordinate)")
        }else{
            print("현재 서비스 off 상태")
        }
    }
    
    //위치정보 계속 업데이트 -> 위도경도 받아오기
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        var lastLoc = locations.last?.coordinate
        var lastLat = lastLoc!.latitude
        var lastLon = lastLoc!.longitude
    }
}
