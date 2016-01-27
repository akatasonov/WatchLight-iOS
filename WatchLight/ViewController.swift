//
//  ViewController.swift
//  WatchLight
//
//  Created by Andrew Katasonov on 1/5/16.
//  Copyright © 2016 Andrew Katasonov. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, HSBColorPickerDelegate, WCSessionDelegate {

    @IBOutlet var colorPicker: HSBColorPicker!
    @IBOutlet var userSelectedColor: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "Choose the color")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        colorPicker.delegate = self
        // Check for any previously selected color
        var haveUserSelectedColor = false
        var color = UIColor.whiteColor()

        if let userSelectedColorData = NSUserDefaults.standardUserDefaults().objectForKey("UserSelectedColor") as? NSData {
            if let optionalColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedColorData) as? UIColor {
                color = optionalColor
                userSelectedColor.backgroundColor = color
                haveUserSelectedColor = true
            }
        }
        if !haveUserSelectedColor {
            userSelectedColor.backgroundColor = UIColor.whiteColor()
            color = userSelectedColor.backgroundColor!
        }
        
        if (WCSession.isSupported()) {
            //print("WatchConnectivity sessions are supported")
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            
            do {
                print("Sending color \(color) to the watch")
                let applicationDict = ["UserSelectedColor" : NSKeyedArchiver.archivedDataWithRootObject(color)]
                try session.updateApplicationContext(applicationDict)
            } catch let error {
                // Handle errors here
                print("Exception thrown during session.updateApplicationContext(): \(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    func HSBColorColorPickerTouched(sender: HSBColorPicker, color: UIColor, point: CGPoint, state: UIGestureRecognizerState) {
        //print("Selected color is \(color)")
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(color), forKey: "UserSelectedColor")
        defaults.synchronize()
        
        userSelectedColor.backgroundColor = color
        
        // send the color to the watch
        if WCSession.defaultSession().watchAppInstalled {
            do {
                print("Sending color \(color) to the watch")
                let applicationDict = ["UserSelectedColor" : NSKeyedArchiver.archivedDataWithRootObject(color)]
                try WCSession.defaultSession().updateApplicationContext(applicationDict)
            } catch let error {
                // Handle errors here
                print("Exception thrown during session.updateApplicationContext(): \(error)")
            }
        }
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        let openedOnWatch = message["OpenedOnWatch"] as? Bool
        if openedOnWatch != nil && openedOnWatch! {
            // record the hit from the watch
            let tracker = GAI.sharedInstance().defaultTracker
            tracker.set(kGAIScreenName, value: "Watch Main Screen")
            
            let builder = GAIDictionaryBuilder.createScreenView()
            tracker.send(builder.build() as [NSObject : AnyObject])
        }
    }
}

