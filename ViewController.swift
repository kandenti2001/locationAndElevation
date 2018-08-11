//
//  ViewController.swift
//  locationAndElevation
//
//  Created by tyx on 2018/08/11.
//  Copyright © 2018年 tyx. All rights reserved.
//
/*
 memo
 http://blog.koogawa.com/entry/2016/04/30/080000
 https://qiita.com/ftsan/items/b3a04d30cd91c11aeea1
 https://qiita.com/bellx2/items/fc1de7197f583001ca59
 1 各textFieldを接続
 Linked Framework and LibrariesにCoreMotion.frameworkを追加
 plistに追加　Privacy - Motion Usage Description
 
 バックグラウンド処理
 精度
*/
import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController, CLLocationManagerDelegate {

    //緯度
    @IBOutlet weak var latTextField: UITextField!
    //経度
    @IBOutlet weak var lngTextField: UITextField!
    //位置の精度
    @IBOutlet weak var horizonActField: UITextField!
    //階数
    @IBOutlet weak var floorField: UITextField!
    //標高
    @IBOutlet weak var altTextField: UITextField!
    //標高の精度
    @IBOutlet weak var varticalAccuField: UITextField!
    //日付
    @IBOutlet weak var dateField: UITextField!
    
    //気圧　->iPhone SEでは気圧計がないため使えない
    @IBOutlet weak var pressureTextField: UITextField!
    //標高２　from CoreMotion ->iPhone SEでは気圧計がないため使えない
    @IBOutlet weak var alt2TextField: UITextField!
    
    var locationManager: CLLocationManager!
    
    let altimeter = CMAltimeter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
        startUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if CLLocationManager.locationServicesEnabled() {
            locationManager.stopUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways, .authorizedWhenInUse:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
            CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
                self.latTextField.text = "Error"
                self.lngTextField.text = "Error"
                self.altTextField.text = "Error"
                self.horizonActField.text = "Error"
                self.floorField.text = "Error"
                self.varticalAccuField.text = "Error"
                self.dateField.text = "Error"
                return
        }
        
        self.latTextField.text = "".appendingFormat("%.6f", newLocation.coordinate.latitude)
        self.lngTextField.text = "".appendingFormat("%.6f", newLocation.coordinate.longitude)
        self.altTextField.text = "".appendingFormat("%.2f m", newLocation.altitude)
        self.horizonActField.text = "".appendingFormat("%.2f m", newLocation.horizontalAccuracy)
        self.floorField.text = "\(String(describing: newLocation.floor))"
        self.varticalAccuField.text = "".appendingFormat("%.2f m", newLocation.verticalAccuracy)
        let date = newLocation.timestamp
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        format.timeZone = TimeZone(identifier: "Asia/Tokyo")
        self.dateField.text = format.string(from:date)
    }
    
    func startUpdate() {
        if (CMAltimeter.isRelativeAltitudeAvailable()) {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main, withHandler:
                {data, error in
                    if error == nil {
                        let pressure:Double = Double(truncating: data!.pressure)
                        let altitude:Double = Double(truncating: data!.relativeAltitude)
                        //self.pressureTextField.text = String(pressure*10)
                        self.pressureTextField.text = "".appendingFormat("%.2f hPa", pressure*10)
                        //self.alt2TextField.text = String(altitude)
                        self.alt2TextField.text = "".appendingFormat("%.2f m", altitude)
                    }
            })
        } else{
            print("not use altimeter")
        }
    }
    
    @IBAction func doReset(_ sender: Any) {
        altimeter.stopRelativeAltitudeUpdates()
        startUpdate()
    }
}
