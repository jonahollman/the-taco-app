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
import Alamofire
import SwiftSoup
import Mixpanel
import Device

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
    var checkLocationTimer = Timer()
    
    var activityIndicator = UIActivityIndicatorView()
    var strLabel = UILabel()
    
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    var tacoResults = [CDYelpBusiness]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noLocationPopUp.isHidden = true
        introAnimation()
        checkForLocationPermission()
        setupUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

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
        
        UIView.animate(withDuration: 1.1, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 3.1, options: [], animations: {
            self.tacoBottom.transform = CGAffineTransform.identity
        }) { (true) in
        }
        
        UIView.animate(withDuration: 1.3, delay: 0.7, usingSpringWithDamping: 0.35, initialSpringVelocity: 3.2, options: [], animations: {
            self.tacoTop.transform = CGAffineTransform.identity
        }) { (true) in
        }
        
    }
    
    @objc func checkForLocationPermission() {
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.showNoLocationPopUp()
            case .authorizedAlways, .authorizedWhenInUse:
                locationManager.startUpdatingLocation()
                self.checkLocationTimer.invalidate()
                if !self.noLocationPopUp.isHidden {
                    self.dismissNoLocationPopUp()
                }
                checkForCity()
            }
            
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        checkForLocationPermission()
    }
    
    func setupUI() {
        
        if Device.size() == Size.screen4Inch {
            self.losAngelesGuideButton.titleLabel?.font = UIFont.avenirMediumFontOfSize(size: 18)
        }
        
        self.losAngelesGuideButton.layer.cornerRadius = self.losAngelesGuideButton.layer.frame.height / 2
        self.losAngelesGuideButton.layer.borderWidth = 2
        self.losAngelesGuideButton.layer.borderColor = UIColor(red: 1, green: 111/255, blue: 104/255, alpha: 1).cgColor
        
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
                    self.checkLocationTimer.invalidate()
                    Mixpanel.mainInstance().track(event: "In City Guide Range", properties: ["City": "Los Angeles"])
                    if UserDefaults.standard.object(forKey: "laTop50") == nil {
                        fetchGuide()
                    } else {
                        print("Top 50 Stored")
                    }
                }
            }
        }
    }
    
    func showCityGuide() {
        UIView.animate(withDuration: 0.8, delay: 2.0, options: [], animations: {
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
        noLocationPopUp.layer.borderWidth = 2
        noLocationPopUp.isHidden = false
        noLocationPopUp.target(forAction: #selector(dismissNoLocationPopUp), withSender: self)
        UIView.animate(withDuration: 0.2, animations: {
            self.noLocationPopUp.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (true) in
            UIView.animate(withDuration: 0.2, animations: {
                self.noLocationPopUp.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        }
        
        checkLocationTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.checkForLocationPermission), userInfo: nil, repeats: true)
        
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
            self.checkLocationTimer.invalidate()
        }
    }
    
    func showActivityIndicator() {
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        effectView.frame = CGRect(x: view.frame.midX - 130, y: view.frame.midY - 23 , width: 260, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: effectView.frame.minX + 5 , y: effectView.frame.midY - 23, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        strLabel = UILabel(frame: CGRect(x: activityIndicator.frame.maxX + 5, y: view.frame.midY - 23, width: 200, height: 46))
        strLabel.text = "Finding tacos near you"
        strLabel.font = UIFont.avenirMediumFontOfSize(size: 17)
        strLabel.textColor = UIColor.white
        
        view.addSubview(effectView)
        view.addSubview(activityIndicator)
        view.addSubview(strLabel)
    }

    @IBAction func tacosTapped(_ sender: Any) {
        
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                self.showNoLocationPopUp()
            case .authorizedAlways, .authorizedWhenInUse:
                showActivityIndicator()
                print("Location access")
                self.dismissNoLocationPopUp()
                Mixpanel.mainInstance().track(event: "Tapped for Tacos")
                searchForTacos()
                
            }
            
        } else {
            showNoLocationPopUp()
        }
        
    }
    
    @IBAction func closePopUp(_ sender: Any) {
        self.dismissNoLocationPopUp()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkForLocationPermission()
        print("Location status updated")
    }
    
    func searchForTacos() {
        
        appDelegate.apiClient.searchBusinesses(byTerm: "tacos", location: nil, latitude: self.latitude , longitude: self.longitude, radius: nil, categories: nil, locale: nil, limit: nil, offset: nil, sortBy: CDYelpBusinessSortType.distance, priceTiers: nil, openNow: true, openAt: nil, attributes: nil) { (response) in
            if let response = response, response.error == nil {
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
    
    func fetchGuide() {
        let url = URL(string: "https://docs.google.com/spreadsheets/d/e/2PACX-1vT7AS8-joC6aaPByYJT00uUDQ9ueyQ08bBKOuZSQPCBCe4K-hOLKzgsgcOw5JQELXfGjatmG_mTLrSD/pubhtml?gid=0&single=true")
        
        Alamofire.request(url!).responseString { (response) in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
        }
    }
    
    func parseHTML(html: String) {
        
        var top50Dictionary = [[String: String]]()
        
        do{
            let doc: Document = try SwiftSoup.parse(html)
            let names: Elements = try doc.getElementsByClass("s5")
            let opens: Elements = try doc.getElementsByClass("s13")
            let hoods: Elements = try doc.getElementsByClass("s7")
            let recs: Elements = try doc.getElementsByClass("s11")
            let layout: Elements = try doc.getElementsByClass("s12")
            let address: Elements = try doc.getElementsByClass("s6")
            let lats: Elements = try doc.getElementsByClass("s14")
            let longs: Elements = try doc.getElementsByClass("s15")
            let namesArray = try names.text().split(separator: "X")
            let opensArray = try opens.text().split(separator: " ")
            let hoodArray = try hoods.text().split(separator: "X")
            let recsArray = try recs.text().split(separator: "X")
            let layoutArray = try layout.text().split(separator: " ")
            let addressArray = try address.text().split(separator: "X")
            let latsArray = try lats.text().split(separator: " ")
            let longsArray = try longs.text().split(separator: " ")
            
            for i in 0..<namesArray.count {
                var business = [String: String]()
                business["name"] = String(namesArray[i].trimmingCharacters(in: .whitespaces))
                business["open"] = String(opensArray[i])
                business["hood"] = String(hoodArray[i].trimmingCharacters(in: .whitespaces))
                business["rec"] = String(recsArray[i].trimmingCharacters(in: .whitespaces))
                business["layout"] = String(layoutArray[i])
                business["address"] = String(addressArray[i].trimmingCharacters(in: .whitespaces))
                business["lat"] = String(latsArray[i])
                business["long"] = String(longsArray[i])
                
                top50Dictionary.append(business)
            }
            
            print(top50Dictionary)
            UserDefaults.standard.set(top50Dictionary, forKey: "laTop50")
        }catch Exception.Error( _, let message){
            print(message)
        }catch{
            print("error")
        }
        
    }
    
    
    @IBAction func goToLAGuide(_ sender: Any) {
        let laGuide = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "laGuide")
        
        if UserDefaults.standard.object(forKey: "laTop50") == nil {
            let errorAlert = UIAlertController(title: "Uh oh", message: "We're having trouble finding you tacos. Check your internet connection and try again.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            errorAlert.addAction(okAction)
            self.present(errorAlert, animated: true, completion: nil)
            self.fetchGuide()
        } else {
            Mixpanel.mainInstance().track(event: "Visited City Guide", properties: ["City": "Los Angeles"])
            self.present(laGuide, animated: true, completion: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ResultViewController {
            let vc = segue.destination as! ResultViewController
            vc.tacoResults = self.tacoResults
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

extension UIFont {
    class func avenirMediumFontOfSize(size: CGFloat) -> UIFont {
        return UIFont(name: "Avenir Next Medium", size: size)!
    }
}

