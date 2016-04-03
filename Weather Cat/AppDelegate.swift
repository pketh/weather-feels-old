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

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
  let locationManager = CLLocationManager()

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    if let button = statusItem.button {
      button.image = NSImage(named: "StatusBarButtonImage")
      let menu = NSMenu()
      statusItem.menu = menu
      menu.addItem(NSMenuItem(title: "Print Quote", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P"))
      menu.addItem(NSMenuItem.separatorItem())
      menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
      updateLocationAndWeather()
    }
  }

  func updateLocationAndWeather() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    //self.locationManager.distanceFilter = 10
    self.locationManager.startUpdatingLocation()
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    let location:CLLocation = locations[locations.count-1] as! CLLocation
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    locationManager.stopUpdatingLocation() // Stop Location Manager - keep here to run just once
    getWeather(latitude, longitude: longitude)
  }

  func getWeather(latitude: Double, longitude: Double) {
    print("location is latitude \(latitude), longitude \(longitude)")
    forecastIOClient.getForecast(latitude: latitude, longitude: longitude) { (currentForecast, error) -> Void in
      if let currentForecast = currentForecast {
        //  We got the current forecast!
        print(currentForecast.currently)
      } else if let error = error {
        //  Uh-oh we have an error!
        print(error)
      }
    }
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

