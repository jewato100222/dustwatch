//
//  Home.swift
//  Dust Storm
//
//  Created by Jeffrey Tong on 7/21/18.
//  Copyright © 2018 Jeffrey Tong. All rights reserved.
//

import UIKit
import MapKit

import Foundation

import UserNotifications

struct storage {
    static var keys: [String: String] = [:]
    
    static let defKeys = [
        "showTutorial": "yes",
        "lastUpdated": "",
        "version": "0.12.0",
        "webDomain": "https://epiphytetechnologies.herokuapp.com",
        "timezoneOffset": "-4.0", // the offset of the data server relative to UTC
        // "showLoadDefaults": "yes",
        
        "s:Guides>Course_Progress": "0,0,0,0",
        "s:Guides>Shelter_Locations": "Tap here to record locations.",
        "s:Guides>Emergency_Contacts": "Tap here to record contacts.",
        
        "s:Settings>Graph_Type": "0",
        "s:Settings>Default_City": "",
        "s:Settings>Default_State": "",
        "s:Settings>Default_Zipcode": "",
        "s:Settings>Threshold": "0.8",
        "s:Settings>Notifications": "1,1",
        
        "notifAttempts": "0",
        "console": ""
    ]
    
    static func load () {
        print("==============[ BEGIN DATA KEYLOG ]==============")
        for (key, _) in storage.defKeys {
            if let saved = UserDefaults.standard.object(forKey: key) as? String {
                storage.keys[key] = saved
                print("LOAD DEF keys[" + key + "] = \"" + saved + "\"")
            } else {
                storage.keys[key] = storage.defKeys[key]
                print("INIT NEW keys[" + key + "] = \"" + storage.keys[key]! + "\"")
            }
        }
        print("=================================================")
    }
    
    static func set (_ key: String, _ value: String) {
        storage.keys[key] = value
        UserDefaults.standard.set(value, forKey: key)
    }
    
    static var saveButton: UIButton?
    static var savingIndicator: UIActivityIndicatorView?
    
    static func resetSave () {
        savingIndicator!.alpha = 0
        saveButton!.alpha = 1
    }
    
    static func saveKey (_ key: String, _ value: String, _ sb: UIButton, _ si: UIActivityIndicatorView) {
        if sb.alpha == 0.5 { return }
        si.alpha = 1
        sb.alpha = 0
        storage.set("s:" + key, value)
        storage.saveButton = sb
        storage.savingIndicator = si
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(arc4random()) / 0xFFFFFFFF, execute: resetSave)
    }
}

struct utilities {
    static func getData (
        query: String,
        onSearching: @escaping () -> (),
        onReturn: @escaping () -> (),
        onSuccess: @escaping ([[Double]], Int) -> (),
        onError: @escaping (Int) -> ()
    ) {
        print("GET > http://air.csiss.gmu.edu/DSWeb/DS_Service.jsp?" + query)
        let url = URL(string: "http://air.csiss.gmu.edu/DSWeb/DS_Service.jsp?" + query)
        let searchStarted = Date().timeIntervalSince1970
        
        if url != nil {
            onSearching()
            
            let task = URLSession.shared.dataTask(with: url!) {
                (data, response, error) in guard let data = data else { return }
                DispatchQueue.main.async {
                    onReturn()
                    
                    let rawHTML = String(data: data, encoding: .utf8)?.components(separatedBy: "***")
                    if rawHTML!.count == 1 {
                        onError(2)
                    } else {
                        let searchResult = String(data: data, encoding: .utf8)?.components(separatedBy: "***")[1]
                        
                        if searchResult!.count > 0 {
                            onSuccess(
                                Array(
                                    searchResult!
                                    .components(separatedBy: "|")
                                    .map({
                                        $0
                                        .components(separatedBy: ";")
                                        .map({Double($0.trimmingCharacters(in: .whitespaces))!})
                                    })
                                    /*
                                    .dropFirst(Int(searchStarted / 3600 + Double(storage.keys["timezoneOffset"]!)!) % 24)
                                    */
                                    // we commented this out because the database now syncs to the current hour
                                ),
                                Int((Date().timeIntervalSince1970 - searchStarted) * 1000)
                            )
                        } else {
                            onError(0)
                        }
                    }
                }
            }
            
            task.resume()
        } else {
            onError(1)
        }
    }
    
    static func sendAlert (_ title: String, _ message: String, _ selfObj: UIViewController, _ actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for i in actions {
            alert.addAction(i);
        }
        selfObj.present(alert, animated: true, completion: nil)
    }
    
    static func zipcodeIsValid () -> Bool {
        let zip = storage.keys["s:Settings>Default_Zipcode"]!
        return Int(zip) != nil && zip.count == 5
    }
    
    static func hazardScale (_ value: Double, _ alpha: Double = 1.0) -> UIColor {
        let intervals = [
            [ 0.0, 1.0, 0.0 ],
            [ 1.0, 1.0, 0.0 ],
            [ 1.0, 0.5, 0.0 ],
            [ 1.0, 0.0, 0.0 ],
            [ 1.0, 0.0, 1.0 ]
        ], intNum = Int(value * 4), intShift = value * 4 - Double(intNum)
        // int for interval
        var colors: [CGFloat] = []
        for i in 0 ... 2 {
            colors.append(CGFloat(value == 1 ? intervals[4][i] : intervals[intNum][i] * (1.0 - intShift) + intervals[intNum + 1][i] * intShift))
        }
        return UIColor(red: colors[0], green: colors[1], blue: colors[2], alpha: CGFloat(alpha))
    }
    
    static let units = [[" μg/m³", 0.0, 75.0], [" μg/m³", 0.0, 50.0], [" km", 0.0, 10.0], [" mph", 0.0, 90.0]]
}

// pm 2.5, visibility, wind speed, dust cnctr.

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

var conditionsPage = 0

let locManager = CLLocationManager()

class Home: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var conditions0: UIView!
    @IBOutlet weak var conditions1: UIView!
    
    @IBOutlet weak var cond1rect: UIView!
    @IBOutlet weak var cond1text: UILabel!
    @IBOutlet weak var cond2rect: UIView!
    @IBOutlet weak var cond2text: UILabel!
    @IBOutlet weak var cond3rect: UIView!
    @IBOutlet weak var cond3text: UILabel!
    @IBOutlet weak var cond4rect: UIView!
    @IBOutlet weak var cond4text: UILabel!
    
    @IBOutlet weak var refreshHighlight: UIButton!
    
    @IBOutlet weak var updatedLabel: UILabel!
    
    /*
    func sendAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alert, animated: true, completion: nil)
    }
    */
    
    func updateTime() {
        let date = Date()
        let cal = Calendar.current
        
        let components: [Calendar.Component] = [ .year, .month, .day, .hour, .minute, .second ]
        var timePieces: [String] = []
        for i in 0 ... 5 {
            let val = cal.component(components[i], from: date)
            timePieces.append((val < 10 ? "0" : "") + String(val))
        }
        
        storage.set("lastUpdated", "Weather conditions last updated on \(timePieces[2]).\(timePieces[1]).\(timePieces[0]) at \(timePieces[3]):\(timePieces[4]):\(timePieces[5])")
    }
    
    @IBAction func helpButton(_ sender: Any) {
        utilities.sendAlert("Help Message", "PM 2.5 is used to describe the concentration of particles in the air. Find more information on how to use the PM 2.5 in Course #3 from the Guides tab.", self)
    }
    
    func refreshData(_ automatic: Bool) {
        if utilities.zipcodeIsValid() {
            conditions0.alpha = 0
            updateTime()
            
            utilities.getData(
                query: "zip=" + storage.keys["s:Settings>Default_Zipcode"]!,
                onSearching: {
                    () in
                    self.conditions1.alpha = 0
                },
                onReturn: {
                    () in
                    self.conditions1.alpha = 1
                },
                onSuccess: {
                    (results, arg2) in
                    let rects = [ self.cond1rect, self.cond2rect, self.cond3rect, self.cond4rect ]
                    let texts = [ self.cond1text, self.cond2text, self.cond3text, self.cond4text ]
                    
                    for i in 0 ... 3 {
                        rects[i]!.frame.origin.x = CGFloat(97 + min(results[0][i] * 240 / (utilities.units[i][2] as! Double), 240))
                        texts[i]!.text = String(Double(round(1000 * results[0][i]) / 1000)) + "\(utilities.units[i][0])"
                    }
                    self.updatedLabel.text = storage.keys["lastUpdated"]!
                    self.refreshHighlight.setImage(UIImage(named: "refreshButton.png"), for: .normal)
                },
                onError: {
                    (arg1) in
                    if !automatic {
                        utilities.sendAlert("Error", "Either no data was found for the ZIP Code provided, or the Web Service is down.", self)
                    }
                }
            )
        } else {
            if !automatic {
                utilities.sendAlert("Invalid Location", "The ZIP Code provided was invalid.", self)
                refreshHighlight.setImage(UIImage(named: "refreshButtonRed.png"), for: .normal)
            }
        }
    }
    
    @IBAction func refreshButton (_ sender: Any) {
        refreshData(false)
    }
    @IBAction func infoButton (_ sender: Any) {
        utilities.sendAlert("Info Message", "The weather conditions are selected atmospheric measurements retrieved from Epiphyte's weather systems in various locations across the world and updated on an hourly basis. More information on the conditions and how to interpret them is provided in Course #3 on the Guides tab.", self)
    }
    
    /*
    @IBAction func switchButton(_ sender: Any) {
        conditionsPage = 3 - conditionsPage
        conditions1.alpha = CGFloat(2 - conditionsPage)
        conditions2.alpha = CGFloat(conditionsPage - 1)
        
        updatedLabel.text = storage.keys["lastUpdated"]!
    }
    */
    
    //IBAction func aboutBack(segue: UIStoryboardSegue) {
        
    //}

    func backgroundFetch () {
        print("ran bF")
        utilities.getData(
            query: "zip=" + storage.keys["s:Settings>Default_Zipcode"]!,
            onSearching: {
                () in
            },
            onReturn: {
                () in
            },
            onSuccess: {
                (results, arg2) in
                
                let threshold = Double(storage.keys["s:Settings>Threshold"]!)!,  exceededThreshold = results[0][0] / (utilities.units[0][2] as! Double) > threshold || results[0][1] / (utilities.units[1][2] as! Double) < 1 - threshold || results[0][2] / (utilities.units[2][2] as! Double) > threshold || results[0][3] / (utilities.units[3][2] as! Double) > threshold
                if exceededThreshold && threshold < 1.0 {
                    var resultStr = ""
                    for i in 0 ... 3 {
                        resultStr += [ "PM 2.5", "Visibility", "Wind Speed", "Dust Concentration" ][i] + String(results[0][i]) + "\(utilities.units[i][0])\n"
                    }
                    
                    let content = UNMutableNotificationContent()
                    content.title = "Emergency Weather Alert"
                    content.body = "One or more weather conditions has been forecasted to exceed the hazard sensitivity threshold:\n" + resultStr + "\nTo disable these notifications, visit the Settings tab of DustWatch and set the Hazard Threshold to its maximum value."
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                    let request = UNNotificationRequest(identifier: "weather", content: content, trigger: trigger)
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                }
            },
            onError: {
                (arg1) in
                
                print("Background Fetch failed: " + String(arg1))
            }
        )
        /*
        let content = UNMutableNotificationContent()
        content.title = "Emergency Weather Alert"
        content.body = "There's a tornado omg run !!"
        content.sound = UNNotificationSound.default()
        `
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "weather", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        storage.load()
    }

    @IBAction func unwindToVC (segue: UIStoryboardSegue) {
        viewDidLoad()
    }
    // -> 9 502
    // Buttons: 352, 506; 352, 527; 352, 548; 56, 506
    // AQI (now PM2.5) [...] Label: 9, 502
    // qBars: 106, 506; 106, 506; 106, 506; (+21 x 2)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        // Ask for Authorisation from the User.
        locManager.requestAlwaysAuthorization()
        
        // For use in foreground
        locManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locManager.startUpdatingLocation()
        }
        
        func loadConditions () {
            guard conditions0 != nil else { return }
            if storage.keys["showTutorial"] == "yes" {
                utilities.sendAlert("Welcome!", "If you are using DustWatch for the first time, it is recommended that you read the App Tutorial (found in the Settings tab).", self, [
                    UIAlertAction(title: "Do not show again", style: .default, handler: {
                        action in
                        
                        storage.set("showTutorial", "no")
                    }),
                    UIAlertAction(title: "OK", style: .default)
                ])
            }
            if utilities.zipcodeIsValid() {
                conditionsPage = 1
                conditions1.alpha = 1
                mapView.showsUserLocation = true
                updatedLabel.text = storage.keys["lastUpdated"]!
                refreshData(true)
            } else {
                refreshHighlight.setImage(UIImage(named: "refreshButtonBlue.png"), for: .normal)
                conditions0.alpha = 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01, execute: loadConditions)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

