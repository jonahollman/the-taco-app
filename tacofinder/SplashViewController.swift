//
//  ViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 10/8/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit
import CoreLocation
import CDYelpFusionKit

class SplashViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var tacoTop: UIImageView!
    @IBOutlet var tacoBottom: UIImageView!
    @IBOutlet var tacoButtonOutlet: UIButton!
    @IBOutlet var noLocationPopUp: UIView!
    @IBOutlet var losAngelesGuideButton: UIButton!
    
    var locationManager = CLLocationManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let losAngelesCoordinate = CLLocation(latitude: 34.0522, longitude: -118.2437)
    var token = UserDefaults.standard.string(forKey: "token")
    var latitude = CLLocationDegrees()
    var longitude = CLLocationDegrees()
    
    var tacoResults = [CDYelpBusiness]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noLocationPopUp.isHidden = true
        introAnimation()
        checkForCity()
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkForLocationPermission()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func introAnimation() {
        
        tacoButtonOutlet.alpha = 0
        losAngelesGuideButton.alpha = 0
        losAngelesGuideButton.isHidden = true
        
        tacoTop.transform = CGAffineTransform(translationX: 0, y: -400)
        tacoBottom.transform = CGAffineTransform(translationX: 0, y: -400)
        
        UIView.animate(withDuration: 2.1, animations: {
            self.tacoButtonOutlet.alpha = 1
        }, completion: { (true) in
            self.checkForLocationPermission()
        })
        
        UIView.animate(withDuration: 1.1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.tacoBottom.transform = CGAffineTransform.identity
        }) { (true) in
        }
        
        UIView.animate(withDuration: 1.3, delay: 0.7, usingSpringWithDamping: 0.35, initialSpringVelocity: 3.2, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.tacoTop.transform = CGAffineTransform.identity
        }) { (true) in
        }
        
    }
    
    func checkForLocationPermission() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.showNoLocationPopUp()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location access")
                self.dismissNoLocationPopUp()
                checkForCity()
            }
            
        }
        
    }
    
    func setupUI() {
        self.losAngelesGuideButton.layer.cornerRadius = self.losAngelesGuideButton.layer.frame.height / 2
        self.losAngelesGuideButton.layer.borderWidth = 2
        self.losAngelesGuideButton.layer.borderColor = UIColor.blue.cgColor
    }
    
    func checkForCity() {
        if CLLocationManager.locationServicesEnabled() {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                locationManager.startUpdatingLocation()
                self.latitude = (locationManager.location?.coordinate.latitude)!
                self.longitude = (locationManager.location?.coordinate.longitude)!
                let currentCoordinates = CLLocation(latitude: latitude, longitude: longitude)
                let distanceInMiles = currentCoordinates.distance(from: losAngelesCoordinate) / 1609
                if distanceInMiles <= 30 {
                    showCityGuide()
                }
            }
        }
    }
    
    func showCityGuide() {
        UIView.animate(withDuration: 0.8, delay: 1.9, options: [], animations: {
            self.tacoButtonOutlet.transform = CGAffineTransform(translationX: 0, y: -70)
            self.tacoTop.transform = CGAffineTransform(translationX: 0, y: -70)
            self.tacoBottom.transform = CGAffineTransform(translationX: 0, y: -70)
            self.losAngelesGuideButton.isHidden = false
            self.losAngelesGuideButton.alpha = 1.0
        }) { (true) in
            return
        }
    }
    
    func showNoLocationPopUp() {
        noLocationPopUp.layer.cornerRadius = 10
        noLocationPopUp.layer.borderColor = UIColor.gray.cgColor
        noLocationPopUp.layer.borderWidth = 3
        noLocationPopUp.isHidden = false
        noLocationPopUp.target(forAction: #selector(dismissNoLocationPopUp), withSender: self)
        UIView.animate(withDuration: 0.2, animations: {
            self.noLocationPopUp.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                self.noLocationPopUp.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
    }
    
    @IBAction func goToSettings(_ sender: Any) {
        dismissNoLocationPopUp()
        let settingsUrl = URL(string: UIApplicationOpenSettingsURLString)
    
        UIApplication.shared.open(settingsUrl!, completionHandler: { (success) in
                print("Settings opened")
            })
        
    }
    
    
    @objc func dismissNoLocationPopUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.noLocationPopUp.alpha = 0
        }) { (true) in
            self.noLocationPopUp.isHidden = true
            self.noLocationPopUp.alpha = 1
        }
    }

    @IBAction func tacosTapped(_ sender: Any) {
        
        checkForLocationPermission()
        
        searchForTacos()
        
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        self.dismissNoLocationPopUp()
    }
    
    
    func searchForTacos() {
        
        appDelegate.apiClient.searchBusinesses(byTerm: "tacos", location: nil, latitude: self.latitude , longitude: self.longitude, radius: nil, categories: nil, locale: nil, limit: nil, offset: nil, sortBy: .distance, priceTiers: nil, openNow: true, openAt: nil, attributes: nil) { (response) in
            if let response = response {
                self.tacoResults = response.businesses!
                if self.tacoResults.count > 0 {
                    self.performSegue(withIdentifier: "splashToResult", sender: self)
                } else {
                    let noResultsAlert = UIAlertController(title: "Uh oh", message: "We can't find any tacos nearby! We highly suggest moving to an area with more deliciousness.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    noResultsAlert.addAction(okAction)
                    self.present(noResultsAlert, animated: true, completion: nil)
                }
            } else {
                let errorAlert = UIAlertController(title: "Uh oh", message: "We're having trouble finding you tacos. Check your internet connection and try again.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                errorAlert.addAction(okAction)
                self.present(errorAlert, animated: true, completion: nil)

            }
        }
        
    }
    
    
    @IBAction func goToLAGuide(_ sender: Any) {
        let laGuide = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "laGuide")
        
        self.present(laGuide, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ResultViewController {
            let vc = segue.destination as! ResultViewController
            vc.tacoResults = self.tacoResults
        }
    }
    
}

