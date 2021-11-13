
# platform :ios, '9.0'

target 'PicMap' do
  use_frameworks!

  # Pods for PicMap
  pod'Firebase/Auth'
  pod'Firebase/Firestore'
  pod'NMapsMap'
  pod'MaterialComponents/BottomSheet'
  pod'Alamofire'
  pod'SwiftyJSON'
  pod'BSImagePicker'
  pod'lottie-ios'
  pod'Firebase/Storage'

  post_install do |pi|
     pi.pods_project.targets.each do |t|
         t.build_configurations.each do |bc|
            bc.build_settings['ARCHS[sdk=iphonesimulator*]'] =  `uname -m`
         end
     end
  end
end
