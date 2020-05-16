//
//  FavoritesViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 10/14/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit
import CoreLocation
import CDYelpFusionKit
import MapKit
import Mixpanel
import Device

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var favoritesTable: UITableView!
    var favorites = [String]()
    var favoriteLats = [CLLocationDegrees]()
    var favoriteLongs = [CLLocationDegrees]()
    var resultNumber = Int()
    var tacoResults = [CDYelpBusiness]()
    
    @IBOutlet var emptyTableTop: NSLayoutConstraint!
    @IBOutlet var emptyTableBottom: NSLayoutConstraint!
    @IBOutlet var emptyTableAlert: UIView!
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "favorites") != nil {
            favorites = UserDefaults.standard.object(forKey: "favorites") as! [String]
            favoriteLats = UserDefaults.standard.object(forKey: "favoriteLats") as! [CLLocationDegrees]
            favoriteLongs = UserDefaults.standard.object(forKey: "favoriteLongs") as! [CLLocationDegrees]
        } else {
            hideTableAndDisplayAlert()
        }
        
        if favorites.count == 0 {
            hideTableAndDisplayAlert()
        } else {
            showTableAndHideAlert()
        }
        
        if Device.size() == .screen4Inch {
            emptyTableBottom.constant = 60
            emptyTableTop.constant = 45
        }
        
        favoritesTable.delegate = self
        favoritesTable.dataSource = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }

    }
    
    func hideTableAndDisplayAlert() {
        favoritesTable.isHidden = true
        emptyTableAlert.isHidden = false
        emptyTableAlert.layer.cornerRadius = 10
        emptyTableAlert.layer.borderWidth = 2
        emptyTableAlert.layer.borderColor = UIColor.black.cgColor
    }
    
    func showTableAndHideAlert() {
        favoritesTable.isHidden = false
        emptyTableAlert.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = favoritesTable.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = favorites[indexPath.row]
        
        let tacoLocation = CLLocation(latitude: favoriteLats[indexPath.row], longitude: favoriteLongs[indexPath.row])
        let userLocation = locationManager.location
        cell.detailTextLabel?.text = "\(round(10*(userLocation?.distance(from: tacoLocation))!/1609)/10) miles away"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            Mixpanel.mainInstance().track(event: "Removed from Favorites", properties: ["name": favorites[indexPath.row], "lat": favoriteLats[indexPath.row], "long": favoriteLongs[indexPath.row]])
            
            favorites.remove(at: indexPath.row)
            favoriteLats.remove(at: indexPath.row)
            favoriteLongs.remove(at: indexPath.row)
            
            updateUserDefaults()
            
            if favorites.count == 0 {
                hideTableAndDisplayAlert()
            } else {
                favoritesTable.reloadData()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coordinate = CLLocationCoordinate2DMake(favoriteLats[indexPath.row], favoriteLongs[indexPath.row])
        
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = "\(favorites[indexPath.row])"
        
        let launchOptions = NSDictionary(object: MKLaunchOptionsDirectionsModeWalking, forKey: MKLaunchOptionsDirectionsModeKey as NSCopying)
        
        let currentLocationMapItem = MKMapItem.forCurrentLocation()
        
        Mixpanel.mainInstance().track(event: "Removed from Favorites", properties: ["name": favorites[indexPath.row], "lat": favoriteLats[indexPath.row], "long": favoriteLongs[indexPath.row]])
        
        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions as? [String : AnyObject])
    }
    
    func updateUserDefaults() {
        UserDefaults.standard.set(favorites, forKey: "favorites")
        UserDefaults.standard.set(favoriteLats, forKey: "favoriteLats")
        UserDefaults.standard.set(favoriteLongs, forKey: "favoriteLongs")
        print(favorites)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ResultViewController {
            let vc = segue.destination as! ResultViewController
            vc.resultNumber = resultNumber
            vc.tacoResults = tacoResults
        }
    }

}
