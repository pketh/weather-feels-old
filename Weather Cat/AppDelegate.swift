//
//  AppDelegate.swift
//  Weather Cat
//
//  Created by Pirijan on 2016-04-02.
//  Copyright © 2016 Pirijan Ketheswaran. All rights reserved.
//

import Cocoa
import CoreLocation

import ForecastIO

let forecastIOClient = APIClient(apiKey: "480b791a0bd0965a07bc7b19c4b901e7")


//let locationMgr = CLLocationManager()
//
//class GeoCordDelegate: NSObject, CLLocationManagerDelegate {
//  func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//    print("Updated Location: " + newLocation.description)
//  }
//  func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
//    print("Error while updating location " + error.localizedDescription)
//  }
//}

class CoreLocationController : NSObject, CLLocationManagerDelegate {

}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
  var location = ""

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    if let button = statusItem.button {
      button.image = NSImage(named: "StatusBarButtonImage")
      // button.action = getWeather (?)
      let menu = NSMenu()
      statusItem.menu = menu
      menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
      menu.addItem(NSMenuItem.separatorItem())
      menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
      // getLocation() {
        // location = 'new york city/brooklyn'
      // saves to global var
      // }
      // AppDelegate.getWeather(location) on the hour
//      let geoCoordDelegate = GeoCordDelegate()
//      locationMgr.delegate = geoCoordDelegate
//      locationMgr.desiredAccuracy = kCLLocationAccuracyBest
//      locationMgr.startUpdatingLocation()

    }
  }

  // func getLocation() {
  // }

  // func getWeather(location) {
  // gets current weather for *location
  // }

  func getWeather(latitude: NSNumber, longitude: NSNumber) -> Void {
    print("location is latitude \(latitude), longitude \(longitude)")
  }

  func printQuote(sender: AnyObject) {
    let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
    let quoteAuthor = "Mark Twain"
    print("\(quoteText) — \(quoteAuthor)")
  }


  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
  
  
}

