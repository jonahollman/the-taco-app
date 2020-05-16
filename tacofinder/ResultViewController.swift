//
//  ResultViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 10/14/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit
import CDYelpFusionKit
import MapKit
import CoreLocation
import Mixpanel
import Device

class ResultViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var locationMap: MKMapView!
    @IBOutlet var tacoName: UILabel!
    @IBOutlet var yelpStars: UIImageView!
    @IBOutlet var yelpLink: UIButton!
    @IBOutlet var tacoAddress: UILabel!
    @IBOutlet var tacoHours: UILabel!
    @IBOutlet var tacoFavoriteStar: UIImageView!
    @IBOutlet var favoritesIcon: UIImageView!
    @IBOutlet var tacoPhone: UIButton!
    @IBOutlet var goButton: UIButton!
    @IBOutlet var favoritesButton: UIButton!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var mapHeight: NSLayoutConstraint!
    @IBOutlet var tacoHoursTop: NSLayoutConstraint!
    @IBOutlet var nextWidth: NSLayoutConstraint!
    @IBOutlet var favesWidth: NSLayoutConstraint!
    @IBOutlet var homeWidth: NSLayoutConstraint!
    
    var locationManager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var tacoResults = [CDYelpBusiness]()
    var tacoLocation: CDYelpCoordinates?
    var resultNumber = 0
    var favorites: [String] = []
    var favoriteLats: [CLLocationDegrees] = []
    var favoriteLongs: [CLLocationDegrees] = []
    var isFavorite = false
    var phoneNumber = ""
    var top50Dictionary = [[String: String]]()
    var tacoLink = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        if UserDefaults.standard.object(forKey: "favorites") != nil {
            favorites = UserDefaults.standard.object(forKey: "favorites") as! [String]
            favoriteLats = UserDefaults.standard.object(forKey: "favoriteLats") as! [CLLocationDegrees]
            favoriteLongs = UserDefaults.standard.object(forKey: "favoriteLongs") as! [CLLocationDegrees]
        }
        
        if UserDefaults.standard.object(forKey: "laTop50") != nil {
            if (UserDefaults.standard.object(forKey: "laTop50") as? [[String: String]]) != nil {
                top50Dictionary = UserDefaults.standard.object(forKey: "laTop50") as! [[String: String]]
                print("Top 50 Stored")
            } else {
                print("Top 50 Not Stored")
            }
            
        }
        
        setupUI()
        setupResult()
        setupFavoritesIcon()
    }
    
    func setupResult() {
        let result = tacoResults[resultNumber]
        DispatchQueue.main.async {
            self.tacoName.text = result.name
            self.tacoAddress.text = "\(result.location!.displayAddress![0])"
            if result.displayPhone != nil {
                self.phoneNumber = result.phone!
                self.tacoPhone.isHidden = false
            } else {
                self.tacoPhone.isHidden = true
            }
            self.tacoLink = "https://www.yelp.com/biz/\(result.id!)"
            self.setupStars(rating: result.rating!)
            self.setupHours(id: result.id!, day: self.getDay())
            Mixpanel.mainInstance().track(event: "Viewed Taco Result", properties: ["name": result.name!, "city": (result.location?.city!)!, "state": (result.location?.state!)!])
        }
        tacoLocation = result.coordinates
        setupMap(location: result.coordinates!)
        checkIfFavorite()
    }
    
    func setupMap(location: CDYelpCoordinates) {
        locationMap.delegate = self
        locationMap.removeAnnotations(locationMap.annotations)
        
        let center = CLLocationCoordinate2D(latitude: (location.latitude)!, longitude: (location.longitude)!)
        let pin = MKPointAnnotation()
        pin.coordinate = center
        locationMap.addAnnotation(pin)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        locationMap.setRegion(region, animated: true)
    }
    
    func setupFavoritesIcon() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeFavoritesStatus))
        favoritesIcon.isUserInteractionEnabled = true
        favoritesIcon.addGestureRecognizer(tap)
    }
    
    func checkIfFavorite() {
        print("Favorites: \(favorites)")
        for favorite in favorites {
            if favorite == tacoResults[resultNumber].name {
                favoritesIcon.image = UIImage(named: "heart-outline")
                isFavorite = true
                break
            } else {
                favoritesIcon.image = UIImage(named: "heart-outline-plus")
                isFavorite = false
            }
        }
        tacoFavoriteStar.isHidden = true
        for entry in top50Dictionary {
            if entry["name"] == tacoResults[resultNumber].name {
                tacoFavoriteStar.isHidden = false
                print("Isatop50")
                break
            } else {
                tacoFavoriteStar.isHidden = true
            }
        }
    }
    
    func setupUI() {
        
        if Device.size() == Size.screen4Inch {
            mapHeight.constant = 130
            homeWidth.constant = 86
            favesWidth.constant = 86
            nextWidth.constant = 86
            tacoHoursTop.constant = 25
        }
        
        tacoPhone.layer.borderColor = UIColor.black.cgColor
        tacoPhone.layer.borderWidth = 2
        tacoPhone.layer.cornerRadius = 5
        
        goButton.layer.shadowColor = UIColor.blue.withAlphaComponent(0.8).cgColor
        goButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        goButton.layer.shadowOpacity = 1.0
        goButton.layer.shadowRadius = 0.0
        goButton.layer.masksToBounds = false
        goButton.layer.cornerRadius = 5
        
        favoritesButton.layer.shadowColor = UIColor(red: 1, green: 111/255, blue: 104/255, alpha: 0.8).cgColor
        favoritesButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        favoritesButton.layer.shadowOpacity = 1.0
        favoritesButton.layer.shadowRadius = 0.0
        favoritesButton.layer.masksToBounds = false
        favoritesButton.layer.cornerRadius = 5
        
        nextButton.layer.shadowColor = UIColor(red: 1, green: 205/255, blue: 93/255, alpha: 0.8).cgColor
        nextButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        nextButton.layer.shadowOpacity = 1.0
        nextButton.layer.shadowRadius = 0.0
        nextButton.layer.masksToBounds = false
        nextButton.layer.cornerRadius = 5
        
        homeButton.layer.shadowColor = UIColor(red: 156/255, green: 217/255, blue: 167/255, alpha: 0.8).cgColor
        homeButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        homeButton.layer.shadowOpacity = 1.0
        homeButton.layer.shadowRadius = 0.0
        homeButton.layer.masksToBounds = false
        homeButton.layer.cornerRadius = 5
        
        tacoHours.layer.cornerRadius = tacoHours.layer.frame.height / 2
        tacoHours.layer.borderColor = UIColor.green.cgColor
        tacoHours.layer.borderWidth = 2
        tacoHours.sizeToFit()
        
    }
    
    func getDay() -> Int {
        let todayDate = Date()
        let myCalendar = Calendar(identifier: .gregorian)
        let myComponents = myCalendar.dateComponents([Calendar.Component.weekday], from: todayDate)
        let weekDay = myComponents.weekday!
        print("Weekday: \(weekDay)")
        switch weekDay {
        case 1:
            return 6
        default:
            return weekDay - 2
        }
    }
    
    @objc func changeFavoritesStatus() {
        if isFavorite {
            favoritesIcon.image = UIImage(named: "heart-outline-plus")
            isFavorite = false
            let index = favorites.firstIndex(of: tacoName.text!)
            favorites.remove(at: index!)
            favoriteLats.remove(at: index!)
            favoriteLongs.remove(at: index!)
            print("Favorites: \(favorites)")
        } else {
            favoritesIcon.image = UIImage(named: "heart-outline")
            isFavorite = true
            favorites.append(tacoName.text!)
            favoriteLats.append((tacoLocation?.latitude!)!)
            favoriteLongs.append((tacoLocation?.longitude)!)
            Mixpanel.mainInstance().track(event: "Added to Favorites", properties: ["name": self.tacoName.text!, "city": (tacoResults[resultNumber].location?.city)!, "state": (tacoResults[resultNumber].location?.state)!])
            print("Favorites: \(favorites)")
        }
        updateUserDefaults()
    }
    
    func setupStars(rating: Double) {
        switch rating {
        case 0:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.zero, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_0")
            break
        case 1:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.one, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_1")
            break
        case 1.5:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.oneHalf, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_1_half")
            break
        case 2:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.two, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_2")
            break
        case 2.5:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.twoHalf, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_2_half")
            break
        case 3:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.three, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_3")
            break
        case 3.5:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.threeHalf, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_3_half")
            break
        case 4:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.four, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_4")
            break
        case 4.5:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.fourHalf, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_4_half")
            break
        case 5:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.five, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_5")
            break
        default:
            yelpStars.image = UIImage.yelpStars(numberOfStars: CDYelpStars.zero, forSize: .regular)
            yelpStars.image = UIImage(named: "regular_0")
        }
    }
    
    func setupHours(id: String, day: Int) {
        tacoHours.text = "Open     "
        appDelegate.apiClient.fetchBusiness(forId: id, locale: nil) { business in
            if let business = business,
                (business.hours ?? []).count > 0,
                business.hours![0].open != nil,
                business.hours![0].open!.count > day + 1,
                business.hours![0].open![day].end != nil,
                let todayClose = business.hours![0].open![day].end {
                    var todayString = String()
                    if todayClose.numberValue! > 1200 {
                        todayString = String(todayClose.numberValue! - 1200) + " PM"
                        if todayClose.numberValue! >= 2200 {
                            todayString.insert(":", at: (todayClose.index((todayClose.endIndex), offsetBy: -2)))
                        } else {
                            todayString.insert(":", at: (todayClose.index((todayClose.endIndex), offsetBy: -3)))
                        }
                    } else {
                        todayString = todayClose + " AM"
                        todayString.insert(":", at: (todayClose.index((todayClose.endIndex), offsetBy: -2)))
                    }
                    if todayString[todayString.startIndex] == "0" {
                        todayString.remove(at: todayString.startIndex)
                    }
                    if todayString == "0:00 AM" {
                        todayString = "Midnight"
                    } else if todayString == "12:00 PM" {
                        todayString = "Noon"
                    } else if todayString == "0:30 AM" {
                        todayString = "12:30 AM"
                    }
                    self.tacoHours.text = "Open until \(todayString)     "
            } else {
                self.tacoHours.text = "Open     "
            }
        }
    }
    
    func updateUserDefaults() {
        UserDefaults.standard.set(favorites, forKey: "favorites")
        UserDefaults.standard.set(favoriteLats, forKey: "favoriteLats")
        UserDefaults.standard.set(favoriteLongs, forKey: "favoriteLongs")
        print("Favorites: \(favorites)")
    }
    
    @IBAction func viewOnYelp(_ sender: Any) {
        print(tacoResults[resultNumber].id as Any)
        
        UIApplication.shared.open(URL(string: tacoLink)!, options: [:]) { _ in
            print("Opened Yelp site: \(self.tacoLink)")
            Mixpanel.mainInstance().track(event: "Viewed on Yelp", properties: ["name": self.tacoResults[self.resultNumber].name!, "city": (self.tacoResults[self.resultNumber].location?.city)!, "state": (self.tacoResults[self.resultNumber].location?.state)!])
        }
    }
    
    
    @IBAction func callTaco(_ sender: Any) {
        let phoneurl = URL(string: "tel://\(phoneNumber)")
        print("Phone: \(phoneurl!)")
        
        let phonealertController = UIAlertController(
            title: "Call \(tacoResults[resultNumber].name!)?",
            message: "Are you sure you want to call?",
            preferredStyle: .alert)
        
        let phonecancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        phonealertController.addAction(phonecancelAction)
        
        let callAction = UIAlertAction(title: "Call", style: .default) { _ in
            Mixpanel.mainInstance().track(event: "Called Business", properties: ["name": self.tacoResults[self.resultNumber].name!, "city": (self.tacoResults[self.resultNumber].location?.city)!, "state": (self.tacoResults[self.resultNumber].location?.state)!])
            UIApplication.shared.open(phoneurl!, completionHandler: { _ in
            })
        }
        
        phonealertController.addAction(callAction)
        
        present(phonealertController, animated: true, completion: nil)
    }
    
    @IBAction func goToTaco(_ sender: Any) {
        
        let coordinate = CLLocationCoordinate2DMake((tacoLocation?.latitude)!, (tacoLocation?.longitude)!)
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.tacoName.text!)"
        
        Mixpanel.mainInstance().track(event: "Pressed Go", properties: ["from": "Individual Result", "name": tacoResults[resultNumber].name!, "city": (tacoResults[resultNumber].location?.city)!, "state": (tacoResults[resultNumber].location?.state)!])
        
        let launchOptions = NSDictionary(object: MKLaunchOptionsDirectionsModeWalking, forKey: MKLaunchOptionsDirectionsModeKey as NSCopying)
        
        let currentLocationMapItem = MKMapItem.forCurrentLocation()
        
        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions as? [String : AnyObject])
    }
    
    @IBAction func nextResult(_ sender: Any) {
        resultNumber += 1
        print("result number: \(resultNumber)")
        if resultNumber <= 19 {
            setupResult()
            Mixpanel.mainInstance().track(event: "Clicked Next", properties: ["Result number": resultNumber])
        } else {
            resultNumber = 0
            setupResult()
            Mixpanel.mainInstance().track(event: "Reached 20 Results")
        }
    }

    @IBAction func goHome(_ sender: Any) {
        let home = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "splash") as! SplashViewController
        home.modalPresentationStyle = .fullScreen
        present(home, animated: true, completion: nil)
    }
    
    @IBAction func goToFavorites(_ sender: Any) {
        let favorites = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "favorites") as! FavoritesViewController
        favorites.modalPresentationStyle = .fullScreen
        favorites.resultNumber = resultNumber
        favorites.tacoResults = tacoResults
        
        Mixpanel.mainInstance().track(event: "Viewed Favorites")
        
        present(favorites, animated: true, completion: nil)
    }

}

extension String {
    var numberValue:Int? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let int = formatter.number(from: self)! as! Int
        return int
    }
}
