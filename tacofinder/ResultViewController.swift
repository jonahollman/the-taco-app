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

class ResultViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var locationMap: MKMapView!
    @IBOutlet var tacoName: UILabel!
    @IBOutlet var yelpStars: UIImageView!
    @IBOutlet var yelpLink: UIButton!
    @IBOutlet var tacoAddress: UILabel!
    @IBOutlet var tacoHours: UILabel!
    @IBOutlet var tacoFavoriteLabel: UILabel!
    @IBOutlet var favoritesIcon: UIImageView!
    @IBOutlet var tacoPhone: UIButton!
    
    var locationManager = CLLocationManager()
    var tacoResults = [CDYelpBusiness]()
    var tacoLocation: CDYelpCoordinates?
    var resultNumber = 0
    var favorites = [String]()
    var favoriteLats = [CLLocationDegrees]()
    var favoriteLongs = [CLLocationDegrees]()
    var isFavorite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        
        if UserDefaults.standard.object(forKey: "favorites") != nil && UserDefaults.standard.object(forKey: "favoriteLats") != nil && UserDefaults.standard.object(forKey: "favoriteLongs") != nil {
            favorites = UserDefaults.standard.object(forKey: "favorites") as! [String]
            favoriteLats = UserDefaults.standard.object(forKey: "favoriteLats") as! [CLLocationDegrees]
            favoriteLongs = UserDefaults.standard.object(forKey: "favoriteLongs") as! [CLLocationDegrees]
        }

        setupResult()
        
        setupFavoritesIcon()
        
    }
    
    func setupResult() {
        let result = tacoResults[resultNumber]
        DispatchQueue.main.async {
            self.tacoName.text = result.name
            self.tacoAddress.text = """
            \(result.location!.addressOne ?? "")
            \(result.location!.addressTwo ?? "")
            \(result.location!.addressThree ?? "")
            """
            // self.tacoHours.text = result![0].open![0].end as? String
            self.tacoPhone.setTitle(result.displayPhone, for: .normal)
        }
        self.tacoLocation = result.coordinates
        setupMap(location: result.coordinates!)
        checkIfFavorite()
    }
    
    func setupMap(location: CDYelpCoordinates) {
        locationMap.delegate = self
        if self.locationMap.annotations.count != 0 {
            self.locationMap.removeAnnotation(self.locationMap.annotations[0])
        }
        
        let center = CLLocationCoordinate2D(latitude: (location.latitude)!, longitude: (location.longitude)!)
        let pin = MKPointAnnotation()
        pin.coordinate = center
        locationMap.addAnnotation(pin)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        locationMap.setRegion(region, animated: true)
    }
    
    func setupFavoritesIcon() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeFavoritesStatus))
        self.favoritesIcon.isUserInteractionEnabled = true
        self.favoritesIcon.addGestureRecognizer(tap)
    }
    
    func checkIfFavorite() {
        print(favorites)
        for favorite in favorites {
            if favorite == tacoResults[resultNumber].name {
                self.favoritesIcon.image = UIImage(named: "heart-outline")
                self.isFavorite = true
                break
            } else {
                self.favoritesIcon.image = UIImage(named: "heart-outline-plus")
                self.isFavorite = false
            }
        }
    }
    
    @objc func changeFavoritesStatus() {
        if self.isFavorite {
            self.favoritesIcon.image = UIImage(named: "heart-outline-plus")
            self.isFavorite = false
            let index = self.favorites.index(of: self.tacoName.text!)
            self.favorites.remove(at: index!)
            self.favoriteLats.remove(at: index!)
            self.favoriteLongs.remove(at: index!)
            print(favorites)
        } else {
            self.favoritesIcon.image = UIImage(named: "heart-outline")
            self.isFavorite = true
            self.favorites.append(self.tacoName.text!)
            self.favoriteLats.append((self.tacoLocation?.latitude!)!)
            self.favoriteLongs.append((self.tacoLocation?.longitude)!)
            print(favorites)
        }
        updateUserDefaults()
    }
    
    func updateUserDefaults() {
        UserDefaults.standard.set(self.favorites, forKey: "favorites")
        UserDefaults.standard.set(self.favoriteLats, forKey: "favoriteLats")
        UserDefaults.standard.set(self.favoriteLongs, forKey: "favoriteLongs")
    }
    
    @IBAction func goToTaco(_ sender: Any) {
        
        let coordinate = CLLocationCoordinate2DMake((tacoLocation?.latitude)!, (tacoLocation?.longitude)!)
        let placemark:MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem:MKMapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(self.tacoName)"
        
        let launchOptions:NSDictionary = NSDictionary(object: MKLaunchOptionsDirectionsModeWalking, forKey: MKLaunchOptionsDirectionsModeKey as NSCopying)
        
        let currentLocationMapItem:MKMapItem = MKMapItem.forCurrentLocation()
        
        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions as? [String : AnyObject])
    }
    
    @IBAction func nextResult(_ sender: Any) {
        self.resultNumber += 1
        print("result number: \(resultNumber)")
        setupResult()
    }

    
    @IBAction func goToFavorites(_ sender: Any) {
        let favorites = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "favorites") as! FavoritesViewController
        favorites.resultNumber = self.resultNumber
        favorites.tacoResults = self.tacoResults
        
        self.present(favorites, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
