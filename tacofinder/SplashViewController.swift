//
//  ViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 10/8/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit
import CoreLocation

class SplashViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var tacoTop: UIImageView!
    @IBOutlet var tacoBottom: UIImageView!
    @IBOutlet var tacoButtonOutlet: UIButton!
    
    @IBOutlet var noLocationPopUp: UIView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noLocationPopUp.isHidden = true
        introAnimation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func introAnimation() {
        
        tacoButtonOutlet.alpha = 0
        
        tacoTop.transform = CGAffineTransform(translationX: 0, y: -400)
        tacoBottom.transform = CGAffineTransform(translationX: 0, y: -400)
        
        UIView.animate(withDuration: 2.1, animations: {
            self.tacoButtonOutlet.alpha = 1
        }, completion: { (true) in
        })
        
        UIView.animate(withDuration: 1.1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.1, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.tacoBottom.transform = CGAffineTransform.identity
        }) { (true) in
        }
        
        UIView.animate(withDuration: 1.3, delay: 0.7, usingSpringWithDamping: 0.35, initialSpringVelocity: 3.2, options: UIViewAnimationOptions.allowUserInteraction, animations: {
            self.tacoTop.transform = CGAffineTransform.identity
        }) { (true) in
            
            self.checkForLocationPermission()
            
        }
        
    }
    
    func checkForLocationPermission() {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.showNoLocationPopUp()
            case .authorizedAlways, .authorizedWhenInUse:
                print("Location access")
            }
            
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
        
    /*    UIView.animate(withDuration: 1.1, animations: {
            self.tacoTop.transform = CGAffineTransform(scaleX: 12, y: 12)
        }) { (success) in
            self.performSegue(withIdentifier: "splashToResult", sender: self)
        } */
        
    }
    
}

