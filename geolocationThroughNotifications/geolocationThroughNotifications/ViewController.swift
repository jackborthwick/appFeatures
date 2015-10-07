//
//  ViewController.swift
//  geolocationThroughNotifications
//
//  Created by Jack Borthwick on 10/5/15.
//  Copyright © 2015 Jack Borthwick. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext: NSManagedObjectContext! = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let locationManager = CLLocationManager()
    var currentLocation             : CLLocation!
    enum UIUserNotificationActionBehavior : UInt {
        case Default // the default action behavior
        case TextInput // system provided action behavior, allows text input from the user
    }
    
    func requestPermissionAndRegisterNotifications () {
        let textAction = UIMutableUserNotificationAction()
        textAction.identifier = "TEXT_ACTION"
        textAction.title = "Reply"
        textAction.activationMode = .Background
        textAction.authenticationRequired = false
        textAction.destructive = false
        textAction.behavior = .TextInput
    
        let category = UIMutableUserNotificationCategory()
        category.identifier = "CATEGORY_ID"
        category.setActions([textAction], forContext: .Default)
        category.setActions([textAction], forContext: .Minimal)
        
        
        let categories = NSSet(objects: category) as! Set<UIUserNotificationCategory>
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: categories)
        UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    }
    
    
    func manuallyScheduleNotifications() { //code from http://fancypixel.github.io/blog/2015/06/11/ios9-notifications-and-text-input/
        let now: NSDateComponents = NSCalendar.currentCalendar().components([.Hour, .Minute], fromDate: NSDate())
        
        let reminder = UILocalNotification()
        reminder.fireDate = NSDate(timeIntervalSinceNow: 2)
        reminder.alertBody = "What is on your mind?"
        reminder.alertAction = "Reply"
        //reminder.soundName = "sound.aif"
        reminder.category = "CATEGORY_ID"
        
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
        
        //        let optionReminder = UILocalNotification()
        //        optionReminder.fireDate = date
        //        optionReminder.alertBody = "Are You Working?"
        //        optionReminder.alertAction = "enter"
        //        optionReminder.category = "OptionCat"
        //        UIApplication.sharedApplication().scheduleLocalNotification(optionReminder)
        print("Firing at \(now.hour):\(now.minute+1)")
    }
    
    func findMyLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated")
        print(locationManager.location)
        currentLocation = locations[0]
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
        currentLocation = locationManager.location
        print(currentLocation)
    }
    
    func gotNote(){
        print("GOT IN VC")
        locationManager.requestLocation()
        print(currentLocation)
        CLGeocoder().reverseGeocodeLocation(currentLocation) { (placemark, error) -> Void in
            if (error != nil) {
                print ("error")
            }
            else {
                print (placemark?.first?.name)
                print (placemark?.first?.addressDictionary)
                print (placemark?.first?.location)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        findMyLocation()
        requestPermissionAndRegisterNotifications()
        manuallyScheduleNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNote", name: "gotNoteAppD", object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

