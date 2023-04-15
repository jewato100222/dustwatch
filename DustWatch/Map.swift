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
var pieces: [[Double]] = [], graphPaths: [CAShapeLayer] = []

/*
let sources = [
    ["FOX 10 Phoneix", "https://www.youtube.com/watch?v=RD5I9UhbRgg"],
    ["Bassminded", "https://i.redd.it/cqvjzlvz6mb11.jpg"],
    ["California Academy of Sciences", "https://astro0.files.wordpress.com/2008/11/theduststorm2.jpg"],
    ["Doug Lemov", "http://www.youthincmag.com/wp-content/uploads/2018/05/duststorm.jpg"]
]
*/
 
class Map: UIViewController {
    @IBOutlet weak var searchType: UISegmentedControl!
    @IBOutlet weak var zipcode: UITextField!
    @IBOutlet weak var city: UITextField!
    @IBOutlet weak var state: UITextField!
    
    @IBAction func typeChanged (_ sender: Any) {
        tci = searchType.selectedSegmentIndex
        city.alpha = CGFloat(1 - tci)
        state.alpha = CGFloat(1 - tci)
        zipcode.alpha = CGFloat(tci)
    }
    
    @IBOutlet weak var webServiceIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleBox: UILabel!
    @IBOutlet weak var searchTimeBox: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var generatingView: UIView!
    @IBOutlet weak var generatingLabel: UILabel!
    @IBOutlet weak var generatingBar: UIProgressView!
    
    @IBOutlet weak var dataType: UISegmentedControl!
    @IBOutlet weak var selectedDatum: UIView!
    @IBOutlet weak var yAxis: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    @IBAction func loadDefaults (_ sender: Any) {
        city.text = storage.keys["s:Settings>Default_City"]
        state.text = storage.keys["s:Settings>Default_State"]
        zipcode.text = storage.keys["s:Settings>Default_Zipcode"]
        
        /*
        if storage.keys["showLoadDefaults"] == "yes" {
            utilities.sendAlert("Loaded Defaults", "The city, state, and ZIP Code fields have been filled according to the corresponding default values saved. The city and state fields were updated automatically by the geolocator if you updated the default location by pressing \"Use Current Location\" in the Settings tab. Otherwise, you will need to manually update them.", self, [
                UIAlertAction(title: "Do not show again", style: .default, handler: {
                    action in
                    
                    storage.set("showLoadDefaults", "no")
                }),
                UIAlertAction(title: "OK", style: .default)
            ])
        }
 
        searchType.selectedSegmentIndex = 1
        typeChanged(-1)
        */
        searchZipcode(-1)
    }
    
    func typesetScale (_ scalef: Int, _ unit: String) -> String {
        var str = "Value (in units of"
        if scalef != 0 {
            str += " 10"
            if scalef != 1 {
                if scalef < 0 { str += "⁻" }
                str += ["⁰", "¹", "²", "³", "⁴", "⁵", "⁶", "⁷", "⁸", "⁹"][abs(scalef)]
            }
        }
        return str + unit + ")"
    }
    
    func generateGraph () {
        self.generatingView.alpha = 1
        self.generatingLabel.alpha = 1
        self.generatingBar.alpha = 1
        self.selectedDatum.frame.origin.x = -10
        
        self.generatingBar.progress = 0
        func updateProgress () {
            self.generatingBar.progress += 0.02
            if round(100 * self.generatingBar.progress) / 100 == 1 {
                // left axis: 23, 352
                // bounds: 23, 352 => 367, 604
                var previousPoint = CGPoint(x: 0, y: 0)
                let maxVal = pieces.map({$0[dataType.selectedSegmentIndex]}).max()!
                let scalef = floor(log2(maxVal) / log2(10) - 1)
                func adjustedMax (_ scalar: Double) -> String {
                    return String(Int(floor(maxVal / pow(10, scalef) * scalar)))
                }
                // let adjustedMax = maxVal / pow(10, scalef)
                //adjustedMax.round()
                let blank = String(repeating: "\n", count: 8)
                yAxis.text = adjustedMax(1.0) + blank + adjustedMax(0.75) + blank + adjustedMax(0.5) + blank + adjustedMax(0.25) + blank + "0"
                valueLabel.text = typesetScale(Int(scalef), utilities.units[dataType.selectedSegmentIndex][0] as! String)
                
                for cx in 0 ... pieces.count - 1 {
                    let layer = CAShapeLayer(), rtHeight = Int(pieces[cx][dataType.selectedSegmentIndex] / maxVal * 236), shapeLayer = CAShapeLayer(), dotLayer = CAShapeLayer()
                    var colR = pieces[cx][dataType.selectedSegmentIndex] / (utilities.units[dataType.selectedSegmentIndex][2] as! Double)
                    if colR > 1 { colR = 1 }
                    if colR < 0 { colR = 0 }
                    if storage.keys["s:Settings>Graph_Type"] == "0" {
                        layer.path = UIBezierPath(roundedRect: CGRect(x: Int(30 + 7.14 * Double(cx)), y: 593 - rtHeight, width: 5, height: rtHeight), cornerRadius: 0).cgPath
                    } else {
                        layer.path = UIBezierPath(roundedRect: CGRect(x: Int(30 + 7.14 * Double(cx)), y: 591 - rtHeight, width: 5, height: 5), cornerRadius: 2.5).cgPath
                        if cx > 0 {
                            let path = UIBezierPath()
                            path.move(to: previousPoint)
                            path.addLine(to: CGPoint(x: Int(32.5 + 7.14 * Double(cx)), y: 593 - rtHeight))
                            shapeLayer.path = path.cgPath
                            
                            shapeLayer.lineWidth = 2
                        }
                        previousPoint = CGPoint(x: Int(32.5 + 7.14 * Double(cx)), y: 593 - rtHeight)
                        //path.close()
                    }
                    /*
                     old lfc values:
                     
                     let lfc: [UIColor] = [
                     UIColor(red: CGFloat(colR), green: CGFloat(1.0 - colR), blue: CGFloat(0.0), alpha: CGFloat(1.0)),
                     UIColor(red: 0.282352941176471, green: 0.713725490196078, blue: 0.235294117647059, alpha: 1),
                     UIColor(red: 0.007843137254902, green: 0.474509803921569, blue: 0.984313725490196, alpha: 1),
                     UIColor(red: 0.996078431372549, green: 0.756862745098039, blue: 0.619607843137255, alpha: 1)
                     ]
 
 
                    */
                    let lfc0 = utilities.hazardScale(colR, 1.0 - Double(cx) / 48.0)
                    let lfc1 = utilities.hazardScale(1 - colR, 1.0 - Double(cx) / 48.0)
                    let lfc: [UIColor] = [ lfc0, lfc0, lfc1, lfc0 ]
                    // replace lfc[0] with lfc[dataType.selectedSegmentIndex] to make color scheme based on selected weather condition
                    layer.fillColor = lfc[dataType.selectedSegmentIndex].cgColor
                    graphPaths.append(layer)
                    self.view.layer.addSublayer(layer)
                    shapeLayer.strokeColor = lfc[dataType.selectedSegmentIndex].cgColor
                    graphPaths.append(shapeLayer)
                    self.view.layer.addSublayer(shapeLayer)
                    dotLayer.path = UIBezierPath(roundedRect: CGRect(x: 10 + Int((dataType.selectedSegmentIndex == 2 ? 1 - colR : colR) * 348), y: 334, width: 3, height: 3), cornerRadius: 2.5).cgPath
                    dotLayer.fillColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.25).cgColor
                    self.view.layer.addSublayer(dotLayer)
                    graphPaths.append(dotLayer)
                }
                
                // let d = Draw(frame: CGRect(x: 100, y: 400, width: 100, height: 100))
                
                self.generatingView.alpha = 0
                self.generatingLabel.alpha = 0
                self.generatingBar.alpha = 0
            }
        }
        for i in 1 ... 50 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01 * Double(i), execute: updateProgress)
        }
    }
    func clearGraph () {
        for i in graphPaths {
            i.path = nil
        }
        generatingView.alpha = 1
        graphPaths = []
    }
    
    @IBAction func searchZipcode (_ sender: Any) {
        state.text = state.text?.prefix(2).uppercased()
        zipcode.text = String((zipcode.text?.prefix(5))!)
        view.endEditing(true)
        
        utilities.getData(
            query: tci == 1 ? "zip=\(zipcode.text!)" : "city=\(city.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)&state=\(state.text!)",
            onSearching: {
                () in
                self.titleBox.text = "Searching..."
                self.titleBox.frame.origin.x = 35
                self.webServiceIndicator.alpha = 1
                self.searchTimeBox.alpha = 0
            },
            onReturn: {
                () in
                self.titleBox.frame.origin.x = 10
                self.webServiceIndicator.alpha = 0
            },
            onSuccess: {
                (results, timeTaken) in
                pieces = results
                self.clearGraph()
                self.generateGraph()
                self.titleBox.text = "Found result for city"
                self.searchTimeBox.text = "(\(pieces.count)/47 sets in \(timeTaken)ms)"
                self.searchTimeBox.alpha = 1
            },
            onError: {
                (errorCode) in
                self.titleBox.text = "⚠️ " + [
                    "No data found",
                    "Invalid search query",
                    "Internal server error"
                ][errorCode]
                self.clearGraph()
                /*
                 "The location specified does not exist. Check that the city and state names are correctly spelled and capitalized and that no extra trailing or leading whitespaces are entered. Additionally, make sure that the state provided is a two-letter abbreviation."
                 """
                 The city, state, and/or ZIP Code provided were not formatted correctly and the search query could not be completed. Make sure that:
                 • the city entered only contains letters and regular whitespaces.
                 • the state entered is a two-letter state abbreviation.
                 • the ZIP Code is a five-digit number.
                 """*/
                self.searchTimeBox.alpha = 0
            }
        )
        /*
        let url = URL(string: "http://air.csiss.gmu.edu/DSWeb/DS_Service.jsp?" + (tci == 1 ? "zip=\(zipcode.text!)" : "city=\(city.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)&state=\(state.text!)"))
        
        if url != nil {
            
            
            let searchStarted =
            
            let task = URLSession.shared.dataTask(with: url!) {
                (data, response, error) in guard let data = data else { return }
                DispatchQueue.main.async {
                    let searchResult = String(data: data, encoding: .utf8)?.components(separatedBy: "***")[1]
                    
                    self.titleBox.frame.origin.x = 10
                    self.webServiceIndicator.alpha = 0
                    
                    if searchResult!.count > 0 {
                        pieces = searchResult!
                        .components(separatedBy: "|")
                        .map({$0
                            .components(separatedBy: ";")
                            .map({Double($0)!})
                        })
                        print(pieces)
                        
                        let searchFinished = Date().timeIntervalSince1970 * 1000
                                            } else {
                        
                    }
                }
            }
            
            task.resume()
        } else {

        }
        */
    }
    
    @IBAction func clearAll (_ sender: Any) {
        city.text = ""
        state.text = ""
        zipcode.text = ""
        
        titleBox.text = ""
        searchTimeBox.alpha = 0
        clearGraph()
    }
    
    @IBAction func dataChanged () {
        clearGraph()
        generateGraph()
    }
    
    override func touchesBegan (_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self.view)
        if (graphPaths.count > 0 && location.x > 24 && location.x < 368 && location.y > 357 && location.y  < 594) {
            var sDfox = (location.x - 22.86) / 7.14
            sDfox.round()
            if sDfox < 1 || Int(sDfox) > pieces.count {
                utilities.sendAlert("Error", "The selected value is out of range.", self)
            } else {
                selectedDatum.frame.origin.x = sDfox * 7.14 + 21.86
                let dTsSI = dataType.selectedSegmentIndex
                utilities.sendAlert("Precise value", "In \(Int(sDfox)) hour(s) from now, the " + [ "Dust Concentration", "PM 2.5", "Visibility", "Wind Speed" ][dTsSI] + " is forecasted to be \(String(Double(round(1000 * pieces[Int(sDfox) - 1][dTsSI]) / 1000)))\(utilities.units[dTsSI][0]).", self)
            }
        }
    }
    
    @IBAction func unwindToVC (segue: UIStoryboardSegue) {
        viewDidLoad()
    }
    
    override func viewDidLoad () {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        valueLabel.transform = CGAffineTransform(rotationAngle: -.pi / 2)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning () {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
