//
//  ViewController.swift
//  RestaurantSearcher2
//
//  Created by 渡邊 翔矢 on 2024/03/29.
//

import UIKit
import CoreLocation
import MapKit


class ViewController: UIViewController {
    let deligate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let dataRequest = Datarequest()
    @IBOutlet var mapView: MKMapView!
    var locationManager: CLLocationManager!
    @IBOutlet var UserLocationButton: UIButton!
    @IBOutlet var searchButton: UIButton!
    @IBOutlet var SearchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        //        精度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        更新頻度(メートル)
        locationManager.distanceFilter = 100
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        //        距離の倍率
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        //        mapView.userLocation.coordinateで現在地が取得可能
        let resion = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.region = resion
        mapView.userTrackingMode = MKUserTrackingMode.follow
        mapView?.showsUserLocation = true
        //      ボタン種
        UserLocationButton.layer.cornerRadius = 20.0
        UserLocationButton.layer.shadowOpacity = 0.8
        UserLocationButton.layer.shadowRadius = 20.0
        UserLocationButton.layer.shadowColor = UIColor.black.cgColor
        UserLocationButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        UserLocationButton.layer.shadowPath = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: 18, height: 18), transform: nil)
        searchButton.layer.cornerRadius = 15
        //      保存されているURLを削除
        UserDefaults.standard.removeObject(forKey: "url")
    }
    
    //    検索ボタン
    @IBAction func SearchButton(_ sender: Any)  {
        guard SearchTextField.text!.count > 0 else {
            SearchTextField.resignFirstResponder()
            let alertController = UIAlertController(title: nil, message: "文字を入力して下さい。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        deligate.userSearchKeyword = SearchTextField.text!
        SearchTextField.text = ""
        SearchTextField.resignFirstResponder()
        
        dataRequest.request { (name, lat, lng) in
            // 検索結果が0だったら
            if (name.isEmpty && lat.isEmpty && lng.isEmpty) {
                let alertController = UIAlertController(title: nil, message: "検索出来ませんでした。", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            // 検索結果があれば、pinを立てる
            self.annotationPin()
        }
    }
    
    func annotationPin() {
        for (index, pintitle) in self.deligate.resultName.enumerated() {
            let pin = MKPointAnnotation()
            pin.title = pintitle
            print("(index)番目の(deligate.resultName[index])をピンの名前にしました。")
            let pinlocations = CLLocationCoordinate2DMake(self.deligate.resultLat[index], self.deligate.resultLng[index])
            pin.coordinate = pinlocations
            print("(index)番目の(pinlocations[index])の位置にピンを指定しました。")
            self.mapView.addAnnotation(pin)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 現在地が取得出来たら
        guard let gps = manager.location?.coordinate else {
            let alertController = UIAlertController(title: nil, message: "現在地が取得できませんでした。", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        print("現在地を取得しました。")
        // 現在地の緯度・経度を取得
        deligate.userLat = Float(gps.latitude)
        deligate.userLng = Float(gps.longitude)
    }
    
    //  ボタンで現在地
    @IBAction func userLocationTap(_ sender: Any) {
        revaseGeocoding()
    }
    
    
    
    func revaseGeocoding() {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: span)
        mapView.region = region
        mapView.userTrackingMode = MKUserTrackingMode.follow
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SearchTextField.resignFirstResponder()
    }
}

//    許可を求めるためのdegateメソッド
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
            //            許可されていない場合
        case .notDetermined:
            //            許可を求める
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            //            何もしない
            break
        case .authorizedAlways, .authorizedWhenInUse:
            //            現在地の取得を開始
            manager.stopUpdatingLocation()
        default:
            break
        }
    }
}


