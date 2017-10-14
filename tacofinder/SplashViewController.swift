//
//  ViewController.swift
//  tacofinder
//
//  Created by Jonah Ollman on 10/8/17.
//  Copyright © 2017 Jonah Ollman. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet var tacoTop: UIImageView!
    @IBOutlet var tacoBottom: UIImageView!
    @IBOutlet var tacoButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        
    }

    @IBAction func tacosTapped(_ sender: Any) {
        
        UIView.animate(withDuration: 1.1, animations: {
            self.tacoTop.transform = CGAffineTransform(scaleX: 12, y: 12)
        }) { (success) in
            self.performSegue(withIdentifier: "splashToResult", sender: self)
        }
        
    }
    
}

