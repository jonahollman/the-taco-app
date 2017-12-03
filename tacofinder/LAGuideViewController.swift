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

class LAGuideViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var top50Table: UITableView!
    var top50Names = [String]()
    var top50Opens = [String]()
    var top50Dictionary = [[String: String]]()
    var favorites = [String]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        top50Table.delegate = self
        top50Table.dataSource = self
        
        fetchGuide()
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
            let namesArray = try names.text().split(separator: "X")
            let opensArray = try opens.text().split(separator: " ")
            let hoodArray = try hoods.text().split(separator: "X")
            let recsArray = try recs.text().split(separator: "X")
            let layoutArray = try layout.text().split(separator: " ")
            let addressArray = try address.text().split(separator: "X")
            
            for i in 0..<namesArray.count {
                var business = [String: String]()
                business["name"] = String(namesArray[i].trimmingCharacters(in: .whitespaces))
                business["open"] = String(opensArray[i])
                business["hood"] = String(hoodArray[i].trimmingCharacters(in: .whitespaces))
                business["rec"] = String(recsArray[i].trimmingCharacters(in: .whitespaces))
                business["layout"] = String(layoutArray[i])
                business["address"] = String(addressArray[i].trimmingCharacters(in: .whitespaces))
                
                top50Dictionary.append(business)
            }
            
            print(top50Dictionary)
            top50Table.reloadData()
        }catch Exception.Error( _, let message){
            print(message)
        }catch{
            print("error")
        }

    }
    
    func fetchFavorites() {
        if UserDefaults.standard.object(forKey: "favorites") != nil {
            self.favorites = UserDefaults.standard.object(forKey: "favorites") as! [String]
        }
    }
    
    func updateUserDefaults() {
        
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

        cell.openStatus.layer.cornerRadius = 5
        cell.address.layer.cornerRadius = 5
        
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
        
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = UIColor.groupTableViewBackground
        }
        
        return cell
    }
    
    @objc func hoodToAddress(sender: UIButton) {
        if sender.title(for: .normal) == top50Dictionary[sender.tag]["address"] {
            sender.setTitle(top50Dictionary[sender.tag]["hood"], for: .normal)
        } else {
            sender.setTitle(top50Dictionary[sender.tag]["address"], for: .normal)
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
