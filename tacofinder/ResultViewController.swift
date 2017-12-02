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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupFirstResult()
        setupMap()
        
    }
    
    func setupFirstResult() {
        let firstTaco = tacoResults[1]
        self.tacoName.text = firstTaco.name
        self.tacoAddress.text = """
            \(firstTaco.location?.addressOne)
            \(firstTaco.location?.addressTwo)
            \(firstTaco.location?.addressThree)
            """
       // self.tacoHours.text = firstTaco.hours![0].open![0].end as? String
        self.tacoPhone.setTitle(firstTaco.displayPhone, for: .normal)
        self.tacoLocation = firstTaco.coordinates
    }
    
    func setupMap() {
        locationMap.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }
        
        let center = CLLocationCoordinate2D(latitude: (self.tacoLocation?.latitude)!, longitude: (self.tacoLocation?.longitude)!)
        var region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        locationMap.setRegion(region, animated: false)
    }
    
    @IBAction func goToTaco(_ sender: Any) {
    }
    
    @IBAction func nextResult(_ sender: Any) {
    }
    
    func addToFavorites() {
        
    }
    
    @IBAction func goToFavorites(_ sender: Any) {
        let favorites = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "favorites")
        
        self.present(favorites, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
