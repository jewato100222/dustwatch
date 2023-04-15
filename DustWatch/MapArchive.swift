/*
//
//  Map.swift
//  Dust Storm
//
//  Created by Jeffrey Tong on 7/21/18.
//  Copyright © 2018 Jeffrey Tong. All rights reserved.
//

import UIKit
// import MapKit

// var downloaded = false, data: [[String]] = []

var tci = 0

/*
 let sources = [
 ["FOX 10 Phoneix", "https://www.youtube.com/watch?v=RD5I9UhbRgg"],
 ["Bassminded", "https://i.redd.it/cqvjzlvz6mb11.jpg"],
 ["California Academy of Sciences", "https://astro0.files.wordpress.com/2008/11/theduststorm2.jpg"],
 ["Doug Lemov", "http://www.youthincmag.com/wp-content/uploads/2018/05/duststorm.jpg"]
 ]
 */

class Map: UIViewController {
    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBOutlet weak var searchType: UISegmentedControl!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    
    @IBAction func typeChanged(_ sender: Any) {
        tci = typeChaged.selectedSegmentIndex
        city.alpha = 1 - tci
        state.alpha = 1 - tci
        zipcode.alpha = tci
    }
    
    @IBOutlet weak var webServiceIndicator: UIActivityIndicatorView!
    @IBOutlet weak var dataBox: UILabel!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var generatingView: UIView!
    @IBOutlet weak var generatingBar: UIProgressView!
    
    @IBAction func searchZipcode(_ sender: Any) {
        titleBox.text = "Searching..."
        webServiceIndicator.alpha = 1
        
        let url = URL(string: "http://air.csiss.gmu.edu/DSWeb/DS_Service.jsp?city=Clarksville&state=MD")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.dataBox.text = String(data: data, encoding: .utf8)!
                self.webServiceIndicator.alpha = 0
            }
            // print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
        /*
         if downloaded {
         view.endEditing(true)
         let result = data.first(where: {$0[2] == zipcode.text!})
         if result != nil {
         generatingView.alpha = 1
         generatingBar.progress = 0
         
         var entry = result!, message = entry[3] + ", " + entry[5] + " County, " + entry[4] + "\n"
         
         titleBox.text = "Found 1 result for zipcode \(entry[2])"
         
         if entry[1].count < 2 { entry[1] = "0" + entry[1] }
         let long = Double(entry[6])!
         let lat = Double(entry[7])!
         
         if long >= 0 { message += String(long) + "º E " }
         else { message += String(-long) + "º W " }
         
         if lat >= 0 { message += String(lat) + "º N\n" }
         else { message += String(-lat) + "º S\n" }
         
         message += "Date: \(entry[0].prefix(4)), day \(entry[0].suffix(3)) | " +
         "Time: \(entry[1]):00 UTC\n\n" +
         "Dust records:\n" +
         "\(entry.suffix(48).joined(separator: " "))\n"
         
         dataBox.text = message
         let maxSize = CGSize(width: 358, height: 374)
         let size = dataBox.sizeThatFits(maxSize)
         dataBox.frame = CGRect(origin: CGPoint(x: 10, y: 220), size: size)
         
         func updateProgress() {
         generatingBar.progress += 0.01
         if round(100 * generatingBar.progress) / 100 == 1 {
         generatingView.alpha = 0
         }
         }
         
         for i in 1 ... 100 {
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.02 * Double(i), execute: updateProgress)
         }
         } else {
         dataBox.text = ""
         titleBox.text = "No data found for zipcode " + zipcode.text!
         }
         } else {
         titleBox.text = "The data has not been downloaded yet."
         }
         */
    }
    
    @IBAction func clearZipcode(_ sender: Any) {
        zipcode.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zipcode.text = storage.keys["defaultZipcode"] as! String
        
        /*
         
         */
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: updateUI)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateUI() {
        print("updated")
        dataBox.text = ""
        searchButton.backgroundColor = UIColor(red: 0.51, green: 0.78, blue: 0.99, alpha: 1.0)
        if let path = Bundle.main.path(forResource: "data", ofType: "txt") {
            // print(path)
            
            if let dir = FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
                ).first {
                
                
                
                //let fileURL = dir.appendingPathComponent("data.txt")
                /*
                 let location = NSString(string: "~/data.txt").expandingTildeInPath
                 */
                let dataRaw = String(try! NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue))
                /*
                 let dataRaw = try String(
                 contentsOf: fileURL,
                 encoding: .utf8
                 )
                 */
                downloadBox.text = "Downloaded \(dataRaw.count / 1000000)MB of data, " +
                "\(dataRaw.split(separator: "\n").count) counties registered."
                let rows = dataRaw.split(separator: "\n")
                for str in rows {
                    let row = String(str).split(separator: " ")
                    data.append(row.map{ String($0) })
                }
                downloaded = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
*/
