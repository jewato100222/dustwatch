//
//  Settings.swift
//  Dust Storm
//
//  Created by Jeffrey Tong on 7/21/18.
//  Copyright © 2018 Jeffrey Tong. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import WebKit

// https://stackoverflow.com/questions/34454532/how-add-separator-to-string-at-every-n-characters-in-swift
extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}

class Settings: UIViewController, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    /*
        (Main)
    */
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var savingIndicator: UIActivityIndicatorView!
    @IBAction func toggleSettingsSave () {
        saveButton.alpha = 1.5 - saveButton.alpha
    }
    
    // @IBOutlet weak var importantButton: UIView!
    @IBOutlet weak var threshold: UISlider!
    @IBAction func thresholdChanged (_ sender: UISlider) {
        sender.minimumTrackTintColor = utilities.hazardScale(Double(sender.value))
        storage.saveKey("Settings>Threshold", String(sender.value), saveButton, savingIndicator)
    }
    @IBOutlet weak var notif1: UISwitch!
    @IBOutlet weak var notif2: UISwitch!
    @IBAction func notifChanged () {
        storage.saveKey("Settings>Notifications", [notif1, notif2].map({$0.isOn ? "1" : "0"}).joined(separator: ","), saveButton, savingIndicator)
    }
    
    @IBOutlet weak var graphType: UISegmentedControl!
    @IBAction func graphTypeChanged () {
        storage.saveKey("Settings>Graph_Type", String(graphType.selectedSegmentIndex), saveButton, savingIndicator)
    }
    
    /*
        App Tutorial
    */
    @IBAction func AppTutorial (_ sender: Any) {
        storage.set("showTutorial", "no")
        self.performSegue(withIdentifier: "AppTutorial", sender: self)
    }
    @IBAction func AppTutorialBack (_ sender: Any) {
        self.performSegue(withIdentifier: "AppTutorialBack", sender: self)
    }
    @IBOutlet weak var AppTutorialNotif: UIImageView!
    // @IBOutlet weak var AppTutorialButton: UIButton!
    
    /*
        App Information
    */
    @IBAction func Legal (_ sender: Any) {
        self.performSegue(withIdentifier: "Legal", sender: self)
    }
    @IBAction func LegalBack (_ sender: Any) {
        self.performSegue(withIdentifier: "LegalBack", sender: self)
    }
    
    /*
        App Information > Credits
    */
    @IBAction func Credits (_ sender: Any) {
        self.performSegue(withIdentifier: "Credits", sender: self)
    }
    @IBAction func CreditsBack (_ sender: Any) {
        self.performSegue(withIdentifier: "CreditsBack", sender: self)
    }
    @IBAction func openLink (_ sender: UIButton) {
        print(sender.title(for: .normal)!)
        if let url = URL(string: sender.title(for: .normal)!), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    /*
        App Information > TermsAndPolicies
    */
    @IBAction func TermsAndPolicies (_ sender: Any) {
        self.performSegue(withIdentifier: "TermsAndPolicies", sender: self)
    }
    @IBAction func TermsAndPoliciesBack (_ sender: Any) {
        self.performSegue(withIdentifier: "TermsAndPoliciesBack", sender: self)
    }
    
    /*
     App Information > TermsAndPolicies
    */
    @IBAction func About (_ sender: Any) {
        self.performSegue(withIdentifier: "About", sender: self)
    }
    @IBAction func AboutBack (_ sender: Any) {
        self.performSegue(withIdentifier: "AboutBack", sender: self)
    }
    @IBAction func openWebsite (_ sender: Any) {
        if let url = URL(string: storage.keys["webDomain"]!), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    /*
        App Information > Changelog
    */
    @IBAction func Changelog (_ sender: Any) {
        self.performSegue(withIdentifier: "Changelog", sender: self)
    }
    @IBAction func ChangelogBack (_ sender: Any) {
        self.performSegue(withIdentifier: "ChangelogBack", sender: self)
    }
    @IBOutlet weak var syncingIcon: UIActivityIndicatorView!
    @IBOutlet weak var fetchMark: UIImageView!
    @IBOutlet weak var fetchResult: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    func fetchSync () {
        let url = URL(string: storage.keys["webDomain"]! + "/DustWatch/versions/latest")
        
        let task = URLSession.shared.dataTask(with: url!) {
            (data, response, error) in guard let data = data else { return }
            DispatchQueue.main.async {
                let rawHTML = String(data: data, encoding: .utf8)?.components(separatedBy: ":::")
                var response = 0
                if rawHTML!.count == 3 {
                    response = storage.keys["version"]! == rawHTML![1] ? 2 : 1
                }
                
                self.syncingIcon.alpha = 0
                self.fetchMark.image = UIImage(named: ["errorMark", "failureMark", "successMark"][response])
                self.fetchMark.alpha = 1
                self.fetchResult.text = ["Search Error", "Copy out-of-date", "Local copy up-to-date"][response]
                if response > 0 {
                    self.versionLabel.text = storage.keys["version"]! + (response == 1 ? " → " + rawHTML![1] : "")
                }
                
            }
        }
        
        task.resume()
    }
    
    @IBOutlet weak var versionPicker: UIPickerView!
    var pickerValues = ["Select a version...", "1.0.0"]
    var notesValues = ["None", "First version of the app to be released to the App Store", "Not yet implemented"]
    func numberOfComponents (in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView (_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerValues.count
    }
    func pickerView (_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerValues[row]
    }
    @IBOutlet weak var searchingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var versionNotes: WKWebView!
    func pickerView (_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // print("Selected row " + String(row))
        
        versionNotes.alpha = 0
        if row > 0 {
            searchingIndicator.alpha = 1
            if let url = URL(string: storage.keys["webDomain"]! + "/DustWatch/versions/raw/" + pickerValues[row]) {
                let request = URLRequest(url: url)
                print(request)
                versionNotes.load(request)
                searchingIndicator.alpha = 0
                versionNotes.alpha = 1
            }
        }
        /*
        versionNotes.text = notesValues[row]
        let maxSize = CGSize(width: 358, height: 374)
        let size = versionNotes.sizeThatFits(maxSize)
        dataBox.frame = CGRect(origin: CGPoint(x: 10, y: 220), size: size)
        */
    }
    
    /*
    private func pickerView (pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("Selected row " + String(row))
        versionNotes.text = notesValues[row]
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }
 */
    
    /*
        Developer
    */
    @IBAction func Developer (_ sender: Any) {
        self.performSegue(withIdentifier: "Developer", sender: self)
    }
    @IBAction func DeveloperBack (_ sender: Any) {
        self.performSegue(withIdentifier: "DeveloperBack", sender: self)
    }
    var resultText = ["Initialized"]
    @IBOutlet weak var command: UITextField!
    @IBOutlet weak var console: UITextView!
    @IBAction func execute (_ sender: Any) {
        let cmd = self.command.text!, cmp = cmd.components(separatedBy: " ")
        var result = "  Command not found"
        
        self.command.text = ""
        view.endEditing(true)
        
        if cmd == "*" {
            result = """
  *: all branches (1)
    > db                 Database
"""
        } else if cmd == "db" {
            result = """
  db: database (3)
    > ls                 List key-value pairs
    > rs [key|"*"]       Reset key <arg1> to default
    > mov [key] [val]    Change the value of key <arg1> to <val>
"""
        } else if cmd == "db ls" {
            result = "  (\(Array(storage.keys.keys).count))\n" + Array(storage.keys.keys).map{ "  " + $0 + String(repeating: " ", count: 31 - $0.count) + storage.keys[$0]! }.joined(separator: "\n")
        } else if cmd.hasPrefix("db rs ") {
            if cmd.dropFirst(6) == "*" {
                for (key, _) in storage.keys {
                    storage.set(key, storage.defKeys[key]!)
                }
                result = "  Restored defaults"
            } else if storage.keys[String(cmd.dropFirst(6))] != nil {
                storage.set(String(cmd.dropFirst(6)), storage.defKeys[String(cmd.dropFirst(6))]!)
                result = "  Restored key"
            } else {
                result = "  Invalid <arg1> passed"
            }
        } else if cmd.hasPrefix("db mov ") {
            if cmp.count >= 4 {
                if storage.keys[cmp[2]] != nil {
                    storage.set(cmp[2], cmp.dropFirst(3).joined(separator: " "))
                    result = "  Set key"
                } else {
                    result = "  Invalid <arg1> passed"
                }
            } else {
                result = "  4 arguments required"
            }
        } else if cmd == "cls" {
            resultText = []
            result = "  Cleared console"
        }
        result = String(repeating: "-", count: 69) + "\n$ " + cmd + "\n" + result
        resultText.append(result)
        console.text = resultText.joined(separator: "\n")
        storage.set("console", resultText.joined(separator: "\n"))
        /*
        for ln in result.components(separatedBy: "\n") {
            resultText += ln.separate(every: 73, with: "\n").components(separatedBy: "\n")
        }
        
        console.text = resultText.suffix(40).joined(separator: "\n") + String(repeating: "\n", count: max(0, 40 - resultText.count))
        */
    }
    
    /*
     App Information > Location
     */
    @IBAction func Location (_ sender: Any) {
        self.performSegue(withIdentifier: "Location", sender: self)
    }
    @IBAction func LocationBack (_ sender: Any) {
        self.performSegue(withIdentifier: "LocationBack", sender: self)
    }
    @IBOutlet weak var cityEntry: UITextField!
    @IBOutlet weak var stateEntry: UITextField!
    @IBOutlet weak var zipEntry: UITextField!
    @IBAction func textFieldDidChange (_ textField: UITextField) {
        storage.saveKey("Settings>Default_City", cityEntry.text!, saveButton, savingIndicator)
        storage.saveKey("Settings>Default_State", stateEntry.text!, saveButton, savingIndicator)
        storage.saveKey("Settings>Default_Zipcode", zipEntry.text!, saveButton, savingIndicator)
    }
    
    static var zipText = ""
    
    var locationManager: CLLocationManager? = nil
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations [0]
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
            (placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                //let data = self.dataManager.GetDustData(zipcode: pm.postalCode!)
                if (pm.postalCode != nil) {
                    self.cityEntry.text = pm.locality!
                    self.stateEntry.text = pm.administrativeArea!
                    self.zipEntry.text = pm.postalCode!
                    storage.saveKey("Settings>Default_City", pm.locality!, self.saveButton, self.savingIndicator)
                    storage.saveKey("Settings>Default_State", pm.administrativeArea!, self.saveButton, self.savingIndicator)
                    storage.saveKey("Settings>Default_Zipcode", pm.postalCode!, self.saveButton, self.savingIndicator)
                } else {
                    utilities.sendAlert("Current Location Search Error", "The geolocater encountered an error while searching for the location.", self)
                }
                
                if self.locationManager != nil {
                    self.locationManager!.stopUpdatingLocation()
                    self.locationManager = nil
                }
                
                print(pm.postalCode!)
            } else {
                utilities.sendAlert("Current Location Search Error", "A problem occurred with the data sent by the geocoder.", self)
            }
        })
    }
    
    @IBAction func currentLocationZip (_ sender: Any) {
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestWhenInUseAuthorization()
        locationManager!.startUpdatingLocation()
        //let attempts = Int(storage.keys["notifAttempts"]!)! + 1
        //storage.set("notifAttempts", String(attempts))
        //notifTest.setTitle("Test Notifications (\(attempts) Attempts)", for: .normal)
        
        /*
         let content = UNMutableNotificationContent()
         content.title = "Emergency Weather Notification"
         content.body = "The Air Quality Index is forecasted at 147 in 38 hours, 588% higher than the average for the past 24 hours."
         content.sound = UNNotificationSound.default()
         
         let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
         let request = UNNotificationRequest(identifier: "weather", content: content, trigger: trigger)
         
         UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
         */
    }
    
    // End
    
    @IBAction func unwindToVC (segue: UIStoryboardSegue) {
        viewDidLoad()
    }
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        if AppTutorialNotif != nil {
            AppTutorialNotif.alpha = storage.keys["showTutorial"] == "yes" ? 1 : 0
            threshold.value = Float(storage.keys["s:Settings>Threshold"]!)!
            thresholdChanged(threshold)
            let notifSwitches = [ notif1, notif2 ], values = storage.keys["s:Settings>Notifications"]!.components(separatedBy: ",")
            for i in 0 ... 1 {
                notifSwitches[i]!.isOn = i >= values.count ? true : values[i] == "1"
            }
            graphType.selectedSegmentIndex = Int(storage.keys["s:Settings>Graph_Type"]!)!
        }
        
        if cityEntry != nil {
            cityEntry!.text = storage.keys["s:Settings>Default_City"]
            stateEntry!.text = storage.keys["s:Settings>Default_State"]
            zipEntry!.text = storage.keys["s:Settings>Default_Zipcode"]
        }
        
        if syncingIcon != nil {
            fetchSync()
            
            self.versionPicker.delegate = self
            self.versionPicker.dataSource = self
        }
        
        if console != nil {
            console.text = storage.keys["console"]!
        }
            // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
