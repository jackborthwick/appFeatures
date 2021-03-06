//
//  ViewController.swift
//  geolocationThroughNotifications
//
//  Created by Jack Borthwick on 10/5/15.
//  Copyright © 2015 Jack Borthwick. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Foundation
import CoreLocation
class ViewController: UIViewController, CLLocationManagerDelegate {
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let managedObjectContext: NSManagedObjectContext! = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    let locationManager = CLLocationManager()
    var currentLocation                 : CLLocation!
    @IBOutlet var map                   :MKMapView!
    
    func placeAnnotations() {
        var locs = fetchLocations()
        for loc in locs{
            var annot = MKPointAnnotation()
            annot.coordinate = CLLocationCoordinate2DMake(NSString(string: loc.lat!).doubleValue, NSString(string: loc.lon!).doubleValue)
            annot.title = loc.name
            print(annot.coordinate)
            map.addAnnotation(annot)
        }
    }
    
    
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
        UIApplication.sharedApplication().scheduleLocalNotification(reminder)
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
        currentLocation = locations[0]
        print(currentLocation)
    }
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error")
        currentLocation = locationManager.location
    }
    
    func gotNote(){
        print("GOT IN VC")
        locationManager.requestLocation()
        CLGeocoder().reverseGeocodeLocation(currentLocation) { (placemark, error) -> Void in
            if (error != nil) {
                print ("error")
            }
            else {
                let entityDescription : NSEntityDescription! = NSEntityDescription.entityForName("ResponseLocation", inManagedObjectContext: self.managedObjectContext)
                var newLocation = ResponseLocation(entity: entityDescription, insertIntoManagedObjectContext: self.managedObjectContext)
                newLocation.name = placemark?.first?.name
                newLocation.lat = placemark?.first?.location?.coordinate.latitude.description
                newLocation.lon = placemark?.first?.location?.coordinate.longitude.description
                self.appDelegate.saveContext()
                self.fetchLocations()
            }
        }
    }
    func fetchLocations ()->[ResponseLocation] {
        let fetchRequest :NSFetchRequest = NSFetchRequest(entityName: "ResponseLocation")
        let locations = try! self.managedObjectContext!.executeFetchRequest(fetchRequest) as! [ResponseLocation]
        //return tempSettings[0]
        print(locations.count)
        return locations
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        findMyLocation()
        requestPermissionAndRegisterNotifications()
        manuallyScheduleNotifications()
        placeAnnotations()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "gotNote", name: "gotNoteAppD", object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

