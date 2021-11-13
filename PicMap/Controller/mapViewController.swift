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
import Alamofire
import SwiftyJSON
import Photos
import BSImagePicker
import FirebaseStorage

protocol Sequense{
    
}

var paramSender1 = UIApplication.shared.delegate as? AppDelegate// 딕셔너리형 데이터에서 콜렉션네임의 값을 불러옴
class mapViewController: UIViewController,Sequence{

    @IBOutlet weak var mapView: NMFMapView!
    let db = Firestore.firestore()
    let infoWindow = NMFInfoWindow()
    let dataSource = NMFInfoWindowDefaultTextSource.data()
    
    @IBOutlet weak var searchBar: UITextField!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view.
       
        postData.userId = (UserDefaults.standard.string(forKey: "userEmail"))!
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
        loadMapping()
    }
    
    func loadMapping(){
        //기존에 있던 더미메시지를 지우기 초기화
        
        getResponse()
        
        /*
        for pic in paramSender1!.MyPics {
            editMarker(Double(pic.latitude!), Double(pic.longitude!), pic.memo!)
        }
 */
        
    }
    func cameraPosition(_ latitude:Double,_ longitude:Double){
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: latitude, lng: longitude))
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 3
        mapView.moveCamera(cameraUpdate)
    }
    
    func editMarker(_ latitude:Double,_ longitude:Double,_ title:String){
        let sdkBundle = Bundle.naverMapFramework()
        let marker = NMFMarker()
        
        marker.position = NMGLatLng(lat: latitude, lng: longitude)
        marker.iconImage = NMF_MARKER_IMAGE_RED
        marker.mapView = mapView
        cameraPosition(latitude, longitude)
        //dataSource.title = title
        //infoWindow.dataSource = dataSource
        
        
        // 2021.11.09 마커 터치핸들러 이동시 -> 카메라 시점 변환 주기 -> cameraPosition()함수 제작
        marker.touchHandler = {(overlay) in
            if let marker1 = overlay as? NMFMarker{
                if marker1.iconImage.reuseIdentifier == "\(sdkBundle.bundleIdentifier ?? "").mSNormal"{
                    self.cameraPosition(latitude, longitude)
                    marker1.iconImage = NMFOverlayImage(name:"mSNormalNight", in: Bundle.naverMapFramework())
                    let paramLat1 = UIApplication.shared.delegate as? AppDelegate
                    let paramLon1 = UIApplication.shared.delegate as? AppDelegate
                    postData.latitude = latitude
                    postData.longitude = longitude
                    print(">>>test \(paramLat1!)")
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "bottomsheetViewController") as! UIViewController
                    // MDC 바텀 시트로 실행

                    let bottomSheet: MDCBottomSheetController = MDCBottomSheetController(contentViewController: vc)
                    
                    bottomSheet.scrimColor = UIColor.systemGray.withAlphaComponent(0.3)
                    // 보여주기
                    self.present(bottomSheet, animated: true, completion: nil)
                    self.dataSource.title = title
                    self.infoWindow.dataSource = self.dataSource
                    self.infoWindow.open(with: marker)
                }else{
                    marker1.iconImage = NMFOverlayImage(name: "mSNormal", in: Bundle.naverMapFramework())
                    self.infoWindow.close()
                }
            }
            return true
        }
        marker.mapView = mapView
            }
    
    @IBAction func showImagePicker(_ sender: UIBarButtonItem) {
        let allAssets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        var evenAssets = [PHAsset]()
/*
        allAssets.enumerateObjects({ (asset, idx, stop) -> Void in
            if idx % 2 == 0 {
                evenAssets.append(asset)
            }
        })
*/
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
            
            var images = [UIImage]()
            images = self.getAssetThumbnail(assets: assets)
            var data = [Data]()
            for i in images.count{
                let imageData = images[i].jpegData(compressionQuality: 0.5)
                data.append(imageData!)
                
            }
            let latData = assets.last?.location?.coordinate.latitude
            let lonData = assets.last?.location?.coordinate.longitude
            print("Finished with selections: \(assets) 위도값> \(String(describing: latData))경도값\(String(describing:lonData))")
            self.dismiss(animated: true, completion: nil)
            
            if latData != nil{
            let titleAlert = UIAlertController(title: "부가설정", message: "메모와 친구를 입력하세요.", preferredStyle: .alert)
                titleAlert.addTextField {UITextField in
                    UITextField.placeholder = "메모설정"
                    
                }
                
            titleAlert.addTextField{ UITextField in
                UITextField.placeholder = "보여질 친구의 이메일"
            }
            
            let ok = UIAlertAction(title: "업로드", style: .default) { UIAlertAction in
                
                let title = titleAlert.textFields?[0].text
                let friend = titleAlert.textFields?[1].text
                self.editMarker(latData!, lonData!, title!)
                
                print("title > \(title) 변경후 \(title as! String)")
                postData.memo = title as! String
                self.sendRequest()
            }
            titleAlert.addAction(ok)
            self.present(titleAlert, animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
            postData.latitude = latData!
            postData.longitude = lonData!
            
            }
            else{
                print("위도경도값 존재하지 않습니다.")
            }

        })
    }
    
    func sendRequest(){ //로컬 이미지 선택 후 메모알람창까지 받은 후 api통신 포스트로 보냄
        //포스트 방식
        let paramter : Parameters = [
            "userId":postData.userId, //로그인,회원가입창에서 성공시 -> 데이터를 받아옴
            "longitude": postData.longitude, // 로컬 이미지 선택후  메모 알람창이 뜨기직전에 저장됨
            "latitude": postData.latitude, // 로컬 이미지 선택 후 메모 알람창이 뜨기직전에 저장됨
            "memo":postData.memo, // 메모알람창이 뜬 후 버튼클릭시에 저장됨
            "loadAddress":postData.loadAddress
        ]
        let url : String = "http://3.35.168.181/api/v1/record"
        
        AF.request(url,
                   method: .post,
                    parameters: paramter,
                    encoding: JSONEncoding.default,
                    headers: ["Content-Type":"application/json",
                              "Accept":"application/json"
                    ]
        ).validate(statusCode: 200..<300)
        .responseJSON(completionHandler: {
            (response) in
            print(response)

        })
    }




    func getResponse(){
        let url : String = "http://3.35.168.181/api/v1/record/get-all"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type":"application/json","Accept":"application/json"]
        ).validate(statusCode: 200..<300)
        .responseJSON { (response) in
            
            self.parseJSON(response)

        }
    }

    func parseJSON(_ response: DataResponse<Any,AFError>){ //테스트용 나중에 get할때 사용할 것 swiftyJSON
        switch response.result{
        case .success(_):
            if let json = try? JSON(data: response.data!){
                for (key, subJson):(String, JSON) in json {
                    //let pic = PicData().jsonParse(json: subJson)
                    let latP = subJson["latitude"].doubleValue
                    let lonP = subJson["longitude"].doubleValue
                    let userP = subJson["userId"].stringValue
                    let memoP = subJson["memo"].stringValue
                    
                    print("\(latP)\(lonP)\(userP)\(memoP)")
                    editMarker(latP, lonP, memoP)
                    param.MyPics.append(PicData().jsonParse(json: subJson))
                    
                }
            }
        case .failure(_):
            print("f")
        }
    }
    //이미지를 api상에 업로드하는 함수
    func imgPost(){
        
        let url = ""
        
        //AF.up
        
    }
    //PHAsset->UIImage->데이터배열로 변환하는 함수
    
    func getAssetThumbnail(assets:[PHAsset]) -> [Data]{
        var arrayOfImages = [UIImage]()
        for asset in assets{
            let manager = PHImageManager.default()
            let option = PHImageRequestOptions()
            var image = UIImage()
            option.isSynchronous = true
            manager.requestImage(for: asset,
                                 targetSize: CGSize(width: 100, height: 100),
                                 contentMode: .aspectFit,
                                 options: option,
                                 resultHandler: { (result, info) -> Void in
                                    image = result!
                                    arrayOfImages.append(image)
                                            })
                        }
        var images = [UIImage]()
        images = arrayOfImages
        var data =
        for img in images{
            let imageData = img
        }
        
        
        }
}
