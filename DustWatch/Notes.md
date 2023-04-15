# Changelog
**v0.10.0**
2018.11.12
Experimented with MKMapView and remodeled the map page

**v0.9.5**
2018.10.28
The current version 

**v0.3.14159265358979323846**

**v0.1.0** Blah blah

**v0.0.0** Conceptualization

# Saved Code Snippets
*HTTP Web Service Calls:*
```
/*
let url = URL(string: "http://air.csiss.gmu.edu/Dust_WebService/dustWS?wsdl")!

let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
guard let data = data else { return }
print(String(data: data, encoding: .utf8)!)
}

task.resume()
*/

/*
var is_URL: String = "http://air.csiss.gmu.edu/Dust_WebService/dustWS?wsdl"

var lobj_Request = NSMutableURLRequest(url: NSURL(string: is_URL)! as URL)
var session = URLSession.shared
var err: NSError?

lobj_Request.httpMethod = "GET"
lobj_Request.httpBody = is_SoapMessage.data(using: String.Encoding.utf8)
lobj_Request.addValue("air.csiss.gmu.edu", forHTTPHeaderField: "Host")
lobj_Request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
lobj_Request.addValue(String(is_SoapMessage.count), forHTTPHeaderField: "Content-Length")
//lobj_Request.addValue("223", forHTTPHeaderField: "Content-Length")
lobj_Request.addValue("http://air.csiss.gmu.edu/Dust_WebService", forHTTPHeaderField: "SOAPAction")

var task = session.dataTask(with: lobj_Request as URLRequest, completionHandler: {
data, response, error -> Void in
print("Response: \(response)")
var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
print("Body: \(strData)")

if error != nil {
print("Error: " + error.debugDescription)
}
})
task.resume()
*/

/*
let url = URL(string: "http://air.csiss.gmu.edu/Dust_WebService/dustWS?wsdl")!
var request = URLRequest(url: url)
request.httpMethod = "GET"

NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {(response, data, error) in
guard let data = data else { return }
print(String(data: data, encoding: .utf8)!)
}
*/
```

*Wallpaper Selection*
```swift
/*
// for use if we add a wallpaper functionality
@IBOutlet weak var selected1: UIImageView!
@IBAction func wallpaper1(_ sender: Any) {
selectWallpaper(0)
}

@IBOutlet weak var selected2: UIImageView!
@IBAction func wallpaper2(_ sender: Any) {
selectWallpaper(1)
}

@IBOutlet weak var selected3: UIImageView!
@IBAction func wallpaper3(_ sender: Any) {
selectWallpaper(2)
}

@IBOutlet weak var selected4: UIImageView!
@IBAction func wallpaper4(_ sender: Any) {
selectWallpaper(3)
}

func selectWallpaper(_ number: Int) {
var wallpaperSelections = [
selected1,
selected2,
selected3,
selected4
]
for i in 0 ... wallpaperSelections.count - 1 {
if i == number {
wallpaperSelections[i]?.alpha = 1
} else {
wallpaperSelections[i]?.alpha = 0
}
}
}
*/
```

*Current Location Manager*
```swift
let manager = CLLocationManager()

manager.delegate = self
manager.desiredAccuracy = kCLLocationAccuracyBest
manager.requestWhenInUseAuthorization()
manager.startUpdatingLocation()

// kc
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
let location = locations [0]
CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in

if error != nil {
print("Reverse geocoder failed with error" + error!.localizedDescription)
return
}

if placemarks!.count > 0 {
let pm = placemarks![0]
self.zipcode.text = pm.postalCode!
print("CLLocation Test:" + pm.postalCode!)
} else {
print("Problem with the data received from geocoder")
}
})
}
```

*Current Location Snippets*
```/*
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
print("nay")
guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
print("locations = \(locValue.latitude) \(locValue.longitude)")
}
locationManager()
*/
/*
locManager.delegate = self
locManager.desiredAccuracy = kCLLocationAccuracyBest
locManager.requestWhenInUseAuthorization()
locManager.startUpdatingLocation()

print("tried clz")
// kc

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
print("locations = \(locValue.latitude) \(locValue.longitude)")
}
*/

/*
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
print("Reached kc()")
let location = locations[0]
CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
(placemarks, error) -> Void in
print("Reached CLG.rGL()")

if error != nil {
print("Reverse geocoder failed with error" + error!.localizedDescription)
return
}

if placemarks!.count > 0 {
let pm = placemarks![0]
self.zipEntry.text = pm.postalCode!
print("CLLocation Test:" + pm.postalCode!)
} else {
print("Problem with the data received from geocoder")
}
})
}

*/
```

*Drawing a line on the Home Page*
```
//view.layer.addSublayer(shapeLayer)

var path = UIBezierPath()
path.move(to: CGPoint(x: 300, y: 20))
path.addLine(to: CGPoint(x: 350, y: 30))
//path.close()

var shapeLayer = CAShapeLayer()
shapeLayer.path = path.cgPath
shapeLayer.strokeColor = UIColor.red.cgColor
shapeLayer.lineWidth = 1.0
self.view.layer.addSublayer(shapeLayer)
//lineTest.fillColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0).cgColor
//UIColor.red.set()
//lineTest.stroke()
```

*Send notif*
```
/*
@IBAction func sendNotif(_ sender: Any) {
let attempts = Int(storage.keys["notifAttempts"]!)! + 1
storage.set("notifAttempts", String(attempts))
notifTest.setTitle("Test Notifications (\(attempts) Attempts)", for: .normal)

let content = UNMutableNotificationContent()
content.title = "Weather Info Notif"
content.body = "Notification Test #" + String(attempts)
content.sound = UNNotificationSound.default()

let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
let request = UNNotificationRequest(identifier: "weather", content: content, trigger: trigger)

UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}
*/
```

*Guarded Segue*
```
func guardedSegue(_ segue: String) {
if saveButton != nil && saveButton.isEnabled {
let alert = UIAlertController(title: "Unsaved data", message: "The page you are trying to leave has unsaved data on it. Data can be saved by pressing the floppy disk icon in the top-right corner.", preferredStyle: .alert)
alert.addAction(UIAlertAction(title: "Return", style: .cancel))
alert.addAction(UIAlertAction(title: "Continue", style: .destructive, handler: {
action in
self.performSegue(withIdentifier: segue, sender: Settings.self)
}))
self.present(alert, animated: true, completion: nil)
} else {
self.performSegue(withIdentifier: segue, sender: Settings.self)
}
}
```

*Broken Current Location Receiver*
```
/*
let manager = CLLocationManager()
print("65 runs")
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
print("line 67 runs")

let location = locations [0]
CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
print("line 71 runs")
if error != nil {
print("Reverse geocoder failed with error" + error!.localizedDescription)
return
}

if placemarks!.count > 0 {
let pm = placemarks![0]

//let data = self.dataManager.GetDustData(zipcode: pm.postalCode!)
var dataString = ""

self.zipEntry.text = pm.postalCode

/*
if data == nil {
self.zipEntry.text = "borked"
}else{
//self.zipEntry.text = dataString
}
*/
print(pm.postalCode!)
}
else {
print("Problem with the data received from geocoder")
}
})
}
/*
let manager = CLLocationManager()

manager.delegate = self
manager.desiredAccuracy = kCLLocationAccuracyBest
manager.requestWhenInUseAuthorization()
manager.startUpdatingLocation()

// kc
func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
let location = locations [0]
CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in

if error != nil {
print("Reverse geocoder failed with error" + error!.localizedDescription)
return
}

if placemarks!.count > 0 {
let pm = placemarks![0]
self.zipEntry.text = pm.postalCode!
print("CLLocation Test:" + pm.postalCode!)
} else {
print("Problem with the data received from geocoder")
}
})
}
*/
*/
```

*Original home page search*
```
/*
let urlstr = "http://air.csiss.gmu.edu/DSWeb/DS_Service.jsp?zip=" + storage.keys["saved>Settings>Default Zipcode"]!

if let url = URL(string: urlstr) {


let task = URLSession.shared.dataTask(with: url) {
(data, response, error) in guard data != nil else { return }
DispatchQueue.main.async {
// let searchResult = String(data: data, encoding: .utf8)?.components(separatedBy: "***")[1]
// print(String(data: data, encoding: .utf8)!)
//242x16px

let rects = [ self.cond1rect, self.cond2rect, self.cond3rect, self.cond4rect ]
let texts = [ self.cond1text, self.cond2text, self.cond3text, self.cond4text ]
let units = ["/500", " km", " m/s", " μg/m³"]

for i in 0 ... 3 {
rects[i]!.frame.size.width = CGFloat(81 * i)
texts[i]!.text = String(81 * i) + "\(utilities.units[i][0])"
}

self.conditions1.alpha = 1
self.updatedLabel.text = storage.keys["lastUpdated"]!
}
}

task.resume()
}

*/
```
