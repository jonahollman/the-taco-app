//
//  FavoritesViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 10/14/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit
import CoreLocation

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {

    @IBOutlet var favoritesTable: UITableView!
    var favorites = [String]()
    var favoriteLats = [CLLocationDegrees]()
    var favoriteLongs = [CLLocationDegrees]()
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "favorites") != nil {
            favorites = UserDefaults.standard.object(forKey: "favorites") as! [String]
            favoriteLats = UserDefaults.standard.object(forKey: "favoriteLats") as! [CLLocationDegrees]
            favoriteLongs = UserDefaults.standard.object(forKey: "favoriteLongs") as! [CLLocationDegrees]
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
