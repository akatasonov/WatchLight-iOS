//
//  InterfaceController.swift
//  WatchLight WatchKit Extension
//
//  Created by Andrew Katasonov on 1/5/16.
//  Copyright © 2016 Andrew Katasonov. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var backgroundGroup: WKInterfaceGroup!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if (WCSession.isSupported()) {
            let session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
            session.sendMessage(["OpenedOnWatch":Bool(true)], replyHandler: {(_: [String : AnyObject]) -> Void in
                // handle reply from iPhone app here, but we don't need it
                }, errorHandler: {(error ) -> Void in
                    // catch any errors here
                    print ("Caught exception while sending GARecordHit message to the main app: \(error)")
            })
        }
        // Configure interface objects here.
        if let userSelectedColorData = NSUserDefaults.standardUserDefaults().objectForKey("UserSelectedColor") as? NSData {
            if let userSelectedColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedColorData) as? UIColor {
                print("Using the saved background color \(userSelectedColor)")
                backgroundGroup.setBackgroundColor(userSelectedColor)
            } else {
                print("Setting the default white color")
                backgroundGroup.setBackgroundColor(UIColor.whiteColor())
            }
        } else {
            print("Setting the default white color")
            backgroundGroup.setBackgroundColor(UIColor.whiteColor())
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        print("Received applicationContext update")
        if let userSelectedColorData = applicationContext["UserSelectedColor"] as? NSData {
            if let userSelectedColor = NSKeyedUnarchiver.unarchiveObjectWithData(userSelectedColorData) as? UIColor {
                print("Updating watch background color to \(userSelectedColor)")
                // update the background color
                backgroundGroup.setBackgroundColor(userSelectedColor)
                // save to defaults too
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(userSelectedColor), forKey: "UserSelectedColor")
                defaults.synchronize()
            }
        }
    }

}
