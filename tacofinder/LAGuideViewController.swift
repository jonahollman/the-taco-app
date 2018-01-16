//
//  LAGuideViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 11/28/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup
import CoreLocation
import MapKit
import Mixpanel
import Device

class LAGuideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var top50Table: UITableView!
    var top50Names = [String]()
    var top50Opens = [String]()
    var top50Dictionary = [[String: String]]()
    var favorites = [String]()
    var favoriteLats = [CLLocationDegrees]()
    var favoriteLongs = [CLLocationDegrees]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        top50Table.delegate = self
        top50Table.dataSource = self
        
        if UserDefaults.standard.object(forKey: "laTop50") == nil {
            fetchGuide()
        } else {
            top50Dictionary = UserDefaults.standard.object(forKey: "laTop50") as! [[String : String]]
        }
        fetchFavorites()
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
            top50Table.reloadData()
            UserDefaults.standard.set(top50Dictionary, forKey: "laTop50")
        }catch Exception.Error( _, let message){
            print(message)
        }catch{
            print("error")
        }

    }
    
    func fetchFavorites() {
        if UserDefaults.standard.object(forKey: "favorites") != nil {
            self.favorites = UserDefaults.standard.object(forKey: "favorites") as! [String]
            self.favoriteLats = UserDefaults.standard.object(forKey: "favoriteLats") as! [CLLocationDegrees]
            self.favoriteLongs = UserDefaults.standard.object(forKey: "favoriteLongs") as! [CLLocationDegrees]
        }
    }
    
    @objc func addToFavorites(sender: UIButton) {
        if favorites.contains(top50Dictionary[sender.tag]["name"]!) {
            let index = favorites.index(of: top50Dictionary[sender.tag]["name"]!)
            favorites.remove(at: index!)
            favoriteLats.remove(at: index!)
            favoriteLongs.remove(at: index!)
            sender.setImage(UIImage(named: "heart-outline-plus"), for: .normal)
        } else {
            favorites.append(top50Dictionary[sender.tag]["name"]!)
            favoriteLats.append(Double(top50Dictionary[sender.tag]["lat"]!)!)
            favoriteLongs.append(Double(top50Dictionary[sender.tag]["long"]!)!)
            sender.setImage(UIImage(named: "heart-outline"), for: .normal)
            Mixpanel.mainInstance().track(event: "Added to Favorites", properties: ["name": top50Dictionary[sender.tag]["name"]!, "lat": top50Dictionary[sender.tag]["lat"]!, "long": top50Dictionary[sender.tag]["long"]!])
        }
        updateUserDefaults()
    }
    
    func updateUserDefaults() {
        UserDefaults.standard.set(favorites, forKey: "favorites")
        UserDefaults.standard.set(favoriteLats, forKey: "favoriteLats")
        UserDefaults.standard.set(favoriteLongs, forKey: "favoriteLongs")
        print(favorites)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.top50Dictionary.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = top50Table.dequeueReusableCell(withIdentifier: "cell") as! Top50TableViewCell
        
        cell.rank.text = String(indexPath.row + 1)
        cell.rankContainer.layer.cornerRadius = cell.rankContainer.layer.frame.height / 2
        cell.name.text = top50Dictionary[indexPath.row]["name"]
        cell.openStatus.text = top50Dictionary[indexPath.row]["open"]
        cell.address.setTitle(top50Dictionary[indexPath.row]["hood"], for: .normal)
        cell.recommended.text = "\(top50Dictionary[indexPath.row]["rec"] ?? "Anything")"
        
        cell.address.isUserInteractionEnabled = true
        cell.address.tag = indexPath.row
        cell.address.addTarget(self, action: #selector(hoodToAddress), for: .touchUpInside)
        
        cell.favoritesIcon.isUserInteractionEnabled = true
        cell.favoritesIcon.tag = indexPath.row
        cell.favoritesIcon.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
        
        cell.goButton.isUserInteractionEnabled = true
        cell.goButton.tag = indexPath.row
        cell.goButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        
        cell.goButton.layer.shadowColor = UIColor.blue.withAlphaComponent(0.8).cgColor
        cell.goButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        cell.goButton.layer.shadowOpacity = 1.0
        cell.goButton.layer.shadowRadius = 0.0
        cell.goButton.layer.masksToBounds = false
        
        cell.openStatus.layer.cornerRadius = 5
        cell.address.layer.cornerRadius = 5
        cell.goButton.layer.cornerRadius = 5
        cell.nameContainer.layer.cornerRadius = 5
        
        if cell.openStatus.text == "Open" {
            cell.openStatus.backgroundColor = UIColor.green
        } else {
            cell.openStatus.backgroundColor = UIColor.red
        }
        
        if top50Dictionary[indexPath.row]["layout"] == "R" {
            cell.descriptionImage.image = UIImage(named: "restaurant")
        } else if top50Dictionary[indexPath.row]["layout"] == "T" {
            cell.descriptionImage.image = UIImage(named: "truck")
        } else {
            cell.descriptionImage.image = UIImage(named: "stand")
        }
        
        if favorites.contains(top50Dictionary[indexPath.row]["name"]!) {
            cell.favoritesIcon.setImage(UIImage(named: "heart-outline"), for: .normal)
        } else {
            cell.favoritesIcon.setImage(UIImage(named: "heart-outline-plus"), for: .normal)
        }
        
        return cell
    }
    
    @objc func hoodToAddress(sender: UIButton) {
        if sender.title(for: .normal) == top50Dictionary[sender.tag]["address"] {
            sender.setTitle(top50Dictionary[sender.tag]["hood"], for: .normal)
        } else {
            sender.setTitle(top50Dictionary[sender.tag]["address"], for: .normal)
            Mixpanel.mainInstance().track(event: "Viewed Address", properties: ["name": top50Dictionary[sender.tag]["name"]!])
        }
    }
    
    @objc func getDirections(sender: UIButton) {
        
        let latitude = Double(top50Dictionary[sender.tag]["lat"]!)!
        let longitude = Double(top50Dictionary[sender.tag]["long"]!)!
        
        let coordinate = CLLocationCoordinate2DMake(latitude, longitude)
        let placemark:MKPlacemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem:MKMapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(top50Dictionary[sender.tag]["name"] ?? "Tacos")"
        
        let launchOptions:NSDictionary = NSDictionary(object: MKLaunchOptionsDirectionsModeDriving, forKey: MKLaunchOptionsDirectionsModeKey as NSCopying)
        
        let currentLocationMapItem:MKMapItem = MKMapItem.forCurrentLocation()
        
        Mixpanel.mainInstance().track(event: "Pressed Go", properties: ["from": "Top 50 LA", "name": top50Dictionary[sender.tag]["name"]!, "lat": coordinate.latitude, "long": coordinate.longitude])
        
        MKMapItem.openMaps(with: [currentLocationMapItem, mapItem], launchOptions: launchOptions as? [String : AnyObject])
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        if Device.size() == Size.screen5_8Inch {
            return false
        } else {
            return true
        }
    }
    

}
