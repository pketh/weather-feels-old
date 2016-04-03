//
//  Weather Cat
//

import Cocoa
import CoreLocation

import ForecastIO
let forecastIOClient = APIClient(apiKey: "480b791a0bd0965a07bc7b19c4b901e7")

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
  let locationManager = CLLocationManager()
  let menu = NSMenu()

  let currentApparentTemperatureMenuItemTag = 1

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    if let button = statusItem.button {
      button.image = NSImage(named: "StatusBarButtonImage")
      // button.action = #selector(AppDelegate.updateData(_:))
      statusItem.menu = menu

      let currentApparentTemperatureMenuItem = NSMenuItem(title: "🔮 --°", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "P")
      currentApparentTemperatureMenuItem.tag = currentApparentTemperatureMenuItemTag
      menu.addItem(currentApparentTemperatureMenuItem)

      // addItem dailySummary, tag 2
      //      dailySummary.hidden = true

      menu.addItem(NSMenuItem.separatorItem())
      menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"))
      updateLocationAndWeather()
    }
  }

  func updateLocationAndWeather() {
    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.startUpdatingLocation()
  }

  func locationManager(manager: CLLocationManager, didUpdateLocations locations: [AnyObject]) {
    let location:CLLocation = locations[locations.count-1] as! CLLocation
    let latitude = location.coordinate.latitude
    let longitude = location.coordinate.longitude
    locationManager.stopUpdatingLocation() // Stop Location Manager - keep here to run just once -> ⛄️ update daily
    updateWeather(latitude, longitude: longitude)
  }

  func updateWeather(latitude: Double, longitude: Double) {
    // print("location is latitude \(latitude), longitude \(longitude)")
    forecastIOClient.getForecast(latitude: latitude, longitude: longitude) { (currentForecast, error) -> Void in
      if let currentForecast = currentForecast {
        let apparentTemperature = Int(round((currentForecast.currently?.apparentTemperature)!))

        // next: get weather/clothes emojis for temp string
        // menuitem.indentationLevel: Int -> 0(default) to 15

        // 🔮 update currentApparentTemperatureMenuItem title based on tag
//        let x = NSMenuItem(title: "\(apparentTemperature)°", action: #selector(AppDelegate.printQuote(_:)), keyEquivalent: "")
//        self.menu.addItem(x)
        let currentApparentTemperatureMenuItem = self.menu.itemWithTag(self.currentApparentTemperatureMenuItemTag)
        currentApparentTemperatureMenuItem?.title = "\(apparentTemperature)°"

//        get weather summary 'clear throughout day' - disabled item
// get sunset time "🌙 7:23 PM" - disabled item

        self.updateWeatherAlerts(currentForecast)

      } else if let error = error {
        print(error)
      }
    }
  }

  func updateWeatherAlerts(currentForecast: Forecast) {
    if let alerts: Alert = currentForecast.alerts?[0] {
      let alertMenuItem = NSMenuItem(title: "\(alerts.title)", action: #selector(AppDelegate.openAlertInBrowser(_:)), keyEquivalent: "")
      alertMenuItem.representedObject = "\(alerts.uri)"
      self.menu.addItem(alertMenuItem)
    }
  }

  func openAlertInBrowser(sender: AnyObject) {
    if let uri = sender.representedObject {
      NSWorkspace.sharedWorkspace().openURL(NSURL(string: "\(uri!)")!)
    }
  }

  // 👷
  func printQuote(sender: AnyObject) {
    print(sender)
    print(sender.tag)
    let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
    let quoteAuthor = "Mark Twain"
    print("\(quoteText) — \(quoteAuthor)")
  }


  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }

}

