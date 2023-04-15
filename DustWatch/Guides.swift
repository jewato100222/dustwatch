//
//  Guides.swift
//  Dust Storm
//
//  Created by Jeffrey Tong on 7/21/18.
//  Copyright © 2018 Jeffrey Tong. All rights reserved.
//

let courses = [
    [
        "Source": "http://www.pitt.edu/~super7/49011-50001/49731.ppt",
        "Author": "University of Pittsburgh",
        "Title": "Intro to Dust Storms",
        "Description": "A quick introduction to dust storms and their effects",
        "Sections": [
            [ "Definition", "Dust storms, often referred to as sand storms, are meteorological events in which large quantities of dust particles are lifted into the air from the ground. The phenomenon is common in arid and semi-arid regions." ],
            [ "Health impacts", "Dust is a perfect place for bacteria and fungi to stay, which can lead to health issues. Dust also carries bacteria and spores from fungi, which can cause diseases long distances away." ],
            [ "Appendix 1", "1", "May 13, 2005: A dust storm rises from the desert regions in Egypt" ],
            [ "Appendix 2", "2", "A diagram showing the various costs and benefits of disaster preparation" ],
            [ "Economic impacts", "Reduced visibility and debris on roads or in the air hampers transportation and commerce. Additionally, dust storms reduce the amounts of soil in farms, and abrade crops. Organic matter is easier to carry than non-organic matter; thus, agriculture is decreased by dust storms." ],
            [ "Sources", "This course is a compressed presentation based off of www.pitt.edu/~super7/49011-50001/49731.ppt. All information and images can be taken directly or inferred from the source." ]
        ]
    ],
    [
        "Source": "https://ein.az.gov/hazards/dust-storms",
        "Author": "University of Arizona",
        "Title": "Responding to Dust Storms",
        "Description": "Important information on staying safe in the event of a dust storm",
        "Sections": [
            [ "Background", "Dust storms are created when amounts of dust particles are picked up by straight line winds and blown over large areas. They can decrease visibility to near zero. This leads to a multitude of accident possibilities, especially on roads." ],
            [ "Avoiding Danger in a Vehicle", "If you encounter a dust storm, quickly check all surrounding traffic. Move off of the road(and leave highways if possible) before visibility is reduced to zero. Turn off the engine and remove your feet from the pedals."],
            [ "Staying Safe While Driving", "Turn off headlights and taillights on your vehicle. Leaving lights on may cause other motorists following you to crash into you from behind." ],
            [ "Waiting Out a Storm", "Dust storms usually last between a few minutes to an hour. Because driving in such conditions is highly dangerous, the best option to wait out the storm is to stay where you are until the storm passes." ],
            [ "Sources", "All information was taken from the \"TAKE Action\" section of https://ein.az.gov/hazards/dust-storms." ]
        ]
    ],
    [
        "Source": "https://www.weather.gov/dmx/dsswind",
        "Author": "(Multiple, see sources)",
        "Title": "Using Air Quality Indicators",
        "Description": "",
        "Sections": [
            [ "Introduction", "The severity of dust storms is typically represented with four weather indicators: PM 2.5, Visibility, Wind Speed, and Dust Concentration. The indicators and color scales listed in the following sections are also used by DustWatch." ],
            [ "PM 2.5", "PM2.5, or particulate matter 2.5, is a metric used to quantify the mass of solid or liquid particles in the air with a diameter of less than or equal to 2.5 µm; it is generally measured in μg/m³. A PM2.5 of 15 or less is generally considered safe while a PM2.5 of more than 15 is considered unsafe." ],
            [ "PM 2.5 Cont.", "1", "A chart comparing different PM 2.5 values"],
            [ "Visibility", "The maximum distance at which objects or light can be identified is given by visibility. It is taken from surface weather observations." ],
            [ "Visibility Cont.", "2", "The implications of different visibilities"],
            [ "Wind Speed", "Wind speed provides a measurement of how quickly wind is moving." ],
            [ "Wind Speed Cont.", "3", "Comparing wind speeds"],
            [ "Dust Concentration", "Dust concentration is the amount of dust in a cubic meter of empty air, typically represented in micrograms."],
            [ "Dust Concentration Cont.", "4", "A comparison of dust concentrations" ],
            [ "Sources", "This guide contains mainly original research, with some specifications from the U.S. government retrieved from https://www3.epa.gov/airnow/aqi_brochure_02_14.pdf and https://www.weather.gov/dmx/dsswind."]
        ]
    ],
    [
        "Source": "https://www.health.nsw.gov.au/environment/factsheets/Pages/dust-storms.aspx",
        "Author": "New South Wales Government",
        "Title": "Precautions for Dust Storms",
        "Description": "Some safety information to prepare for and mitigate the effect of dust storms",
        "Sections": [
            [ "aaaaaa", "this will be filled in later" ],
            [ "Sources", "Information from https://www.health.nsw.gov.au/environment/factsheets/Pages/dust-storms.aspx was used in this course." ]
        ]
    ]
]
var courseNum = -1, page = 0

extension UISegmentedControl {
    func replaceSegments(_ segments: Array<Int>) {
        self.removeAllSegments()
        for segment in segments {
            self.insertSegment(withTitle: String(segment), at: self.numberOfSegments, animated: false)
        }
    }
}

import UIKit

class Guides: UIViewController, UITextViewDelegate {
    @IBOutlet weak var Course0: UIView!
    @IBOutlet weak var Course0Progress: UIImageView!
    
    /*
    @IBOutlet weak var Course0Title: UILabel!
    @IBOutlet weak var Course0Source: UILabel!
    @IBOutlet weak var Course0Description: UILabel!
    */

    @IBOutlet weak var Course1: UIView!
    @IBOutlet weak var Course1Progress: UIImageView!
    /*
    @IBOutlet weak var Course1Title: UILabel!
    @IBOutlet weak var Course1Source: UILabel!
    @IBOutlet weak var Course1Description: UILabel!
    */
 
    @IBOutlet weak var Course2: UIView!
    @IBOutlet weak var Course2Progress: UIImageView!
    /*
    @IBOutlet weak var Course2Title: UILabel!
    @IBOutlet weak var Course2Source: UILabel!
    @IBOutlet weak var Course2Description: UILabel!
    */
 
    @IBOutlet weak var Course3: UIView!
    @IBOutlet weak var Course3Progress: UIImageView!
    /*
    @IBOutlet weak var Course3Title: UILabel!
    @IBOutlet weak var Course3Source: UILabel!
    @IBOutlet weak var Course3Description: UILabel!
    */
    
    @IBOutlet weak var path: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseAuthor: UILabel!
    @IBOutlet weak var courseSource: UIButton!
    @IBOutlet weak var sectionTitle: UILabel!
    @IBOutlet weak var reading: UILabel!
    @IBOutlet weak var readingView: UIView!
    @IBOutlet weak var appendixImage: UIImageView!
    @IBOutlet weak var appendixCaption: UILabel!
    @IBOutlet weak var sectionController: UISegmentedControl!
    
    @IBAction func openSource (_ sender: UIButton) {
        if let url = URL(string: sender.title(for: .normal)!), !url.absoluteString.isEmpty {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
    }
    
    @IBOutlet weak var locationsSaveButton: UIButton!
    @IBOutlet weak var locationsSavingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bodyText: UITextView!
    @IBAction func toggleLocationsSave () {
        locationsSaveButton.alpha = 1.5 - locationsSaveButton.alpha
    }
    @IBAction func shelterLocations (_ sender: Any) {
        self.performSegue(withIdentifier: "Locations", sender: self)
    }
    @IBAction func locationsBackButton (segue: UIStoryboardSegue) {
        
    }
    
    func textViewDidChange (_ textView: UITextView) {
        if locationsSaveButton != nil {
            if locationsSaveButton.alpha == 1 {
                storage.saveKey("Guides>Shelter_Locations", bodyText.text, locationsSaveButton, locationsSavingIndicator)
            }
        } else {
            if contactsSaveButton.alpha == 1 {
                storage.saveKey("Guides>Emergency_Contacts", contactsTextView.text, contactsSaveButton, contactsSavingIndicator)
            }
        }
    }
    
    @IBOutlet weak var contactsSaveButton: UIButton!
    @IBOutlet weak var contactsSavingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var contactsTextView: UITextView!
    @IBAction func toggleContactsSave () {
        contactsSaveButton.alpha = 1.5 - contactsSaveButton.alpha
    }
    @IBAction func emergencyContacts (_ sender: Any) {
        self.performSegue(withIdentifier: "Contacts", sender: self)
    }
    @IBAction func contactsBackButton (segue: UIStoryboardSegue) {
        
    }
    /*
    @IBAction func contactsTextViewUpdated() {
        con
    }
 */
        
    @IBAction func coursesBackButton (_ sender: Any) {
        self.performSegue(withIdentifier: "CoursesBack", sender: self)
        courseNum = -1
        print(courseNum)
        page = 0
    }
    @IBAction func Course1Button (_ sender: UIButton!) {
        self.performSegue(withIdentifier: "Courses", sender: self)
        courseNum = Int(sender.title(for: .normal)!)!
    }
    
    @IBAction func pageBack (_ sender: Any) {
        if page > 0 {
            page -= 1
            updateSection()
        }
    }
    @IBAction func pageChanged (_ sender: UISegmentedControl) {
        page = sender.selectedSegmentIndex
        updateSection()
    }
    @IBAction func pageForward (_ sender: Any) {
        if page < sectionController.numberOfSegments - 1 {
            page += 1
            updateSection()
        }
    }
    
    func updateSection () {
        sectionController.selectedSegmentIndex = page
        let courseContent = courses[courseNum]["Sections"]! as! [[String]]
        let pageContent = courseContent[page]
        sectionTitle.text = pageContent[0]
        if pageContent.count == 2 {
            readingView.alpha = 1
            reading.text = pageContent[1]
            reading.sizeToFit()
        } else {
            readingView.alpha = 0
            let sectionImage = UIImage(named: "Course\(courseNum + 1)-\(pageContent[1])")
            appendixImage.image = sectionImage
            //appendixImage.frame.size = CGSize(width: 359, height: (sectionImage?.size.height)! / sectionImage!.size.width * 359)
            appendixCaption.text = pageContent[2]
        }
        var values = storage.keys["s:Guides>Course_Progress"]!.components(separatedBy: ",")
        if page + 1 > Int(values[courseNum])! {
            values[courseNum] = String(page + 1)
            storage.set("s:Guides>Course_Progress", values.joined(separator: ","))
        }
        
    }
    
    @IBAction func unwindToVC (segue: UIStoryboardSegue) {
        courseNum = -1
        page = 0
        
        viewDidLoad()
    }
    
    override func viewDidLoad () {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        var courseViews = [
            [ Course0 ],
            [ Course1 ],
            [ Course2 ],
            [ Course3 ]
        ], progressIndicators = [
            Course0Progress,
            Course1Progress,
            Course2Progress,
            Course3Progress
        ]
        for view in 0 ... courseViews.count - 1 {
            if courses.count <= view {
                courseViews[view][0]?.alpha = 0
            } else if view < courses.count {
                let courseProgress = Int(storage.keys["s:Guides>Course_Progress"]!.components(separatedBy: ",")[view])!
                let totalPages: [[String]] = courses[view]["Sections"] as! Array
                if courseProgress == totalPages.count {
                    progressIndicators[view]?.image = UIImage(named: "courseProgress2")
                } else if courseProgress > 0 {
                    progressIndicators[view]?.image = UIImage(named: "courseProgress1")
                }
                // if possible, correctly configure labels
            }
        }
        if courseNum >= 0 {
            guard path != nil else {
                courseNum = -1
                return
            }
            path.text = "» Courses » Course " + String(courseNum + 1)
            courseTitle.text = "Course \(courseNum + 1): \(courses[courseNum]["Title"] ?? "undefined")"
            courseAuthor.text = courses[courseNum]["Author"] as? String
            courseSource.setTitle(courses[courseNum]["Source"] as? String, for: .normal)
            sectionController.replaceSegments(Array(1 ... (courses[courseNum]["Sections"] as! [[String]]).count))
            sectionController.selectedSegmentIndex = 0
            updateSection()
        }
        if locationsSaveButton != nil {
            bodyText.delegate = self
            bodyText.text = storage.keys["s:Guides>Shelter_Locations"]
            bodyText.alpha = 1
        }
        if contactsSaveButton != nil {
            contactsTextView.delegate = self
            contactsTextView.text = storage.keys["s:Guides>Emergency_Contacts"]
            contactsTextView.alpha = 1
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning () {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
