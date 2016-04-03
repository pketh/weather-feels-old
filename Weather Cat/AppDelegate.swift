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
  let sunsetTimeMenuItemTag = 2
  let alertMenuItemTag = 3

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
      // menuitem.indentationLevel: Int -> 0(default) to 15
      // blah

      let sunsetTimeMenuItem = NSMenuItem(title: "🌙 ----", action: #selector(AppDelegate.openAlertInBrowser(_:)), keyEquivalent: "")
      sunsetTimeMenuItem.tag = sunsetTimeMenuItemTag
      menu.addItem(sunsetTimeMenuItem)

      // ----------------
      menu.addItem(NSMenuItem.separatorItem())

      let alertMenuItem = NSMenuItem(title: "----", action: #selector(AppDelegate.openAlertInBrowser(_:)), keyEquivalent: "")
      alertMenuItem.tag = alertMenuItemTag
      alertMenuItem.hidden = true
      menu.addItem(alertMenuItem)

      // ----------------
      menu.addItem(NSMenuItem.separatorItem())

      menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApp.terminate(_:)), keyEquivalent: ""))
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
     print("location is latitude \(latitude), longitude \(longitude)")
    forecastIOClient.units = .Auto
    forecastIOClient.getForecast(latitude: latitude, longitude: longitude) { (currentForecast, error) -> Void in
      if let currentForecast = currentForecast {
        let apparentTemperature = Int(round((currentForecast.currently?.apparentTemperature)!))

        // next: get weather/clothes emojis for temp string
        let weatherUnit = self.localWeatherUnit(currentForecast)
        let currentApparentTemperatureMenuItem = self.menu.itemWithTag(self.currentApparentTemperatureMenuItemTag)
        currentApparentTemperatureMenuItem?.title = "\(apparentTemperature)°\(weatherUnit)"

//        get weather summary statement for the day 'clear throughout day' - disabled or indented item
        print(currentForecast.currently?.summary)
        print(currentForecast.daily)

        self.updateSunsetTime(currentForecast)

//      todo:
//        print(currentForecast.hourly) "4pm 54F - 60F", etc
// w weatherunit

        self.updateWeatherAlerts(currentForecast)
      } else if let error = error {
        print(error)
      }
    }
  }

  //MARK: - Forecast Methods

  func updateSunsetTime(currentForecast: Forecast) {
    let sunset = currentForecast.daily?.data![0].sunsetTime
    let sunsetTime = "🌙 \(NSDateFormatter.localizedStringFromDate(sunset!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))"
    let sunsetTimeMenuItem = self.menu.itemWithTag(self.sunsetTimeMenuItemTag)
    sunsetTimeMenuItem?.title = sunsetTime
  }

  func updateWeatherAlerts(currentForecast: Forecast) {
    let alertMenuItem = self.menu.itemWithTag(self.alertMenuItemTag)
    if let alerts: Alert = currentForecast.alerts?[0] {
      alertMenuItem?.title = "\(alerts.title)"
      alertMenuItem?.hidden = false
      alertMenuItem?.representedObject = "\(alerts.uri)"
    } else {
      alertMenuItem?.hidden = true
    }
  }

  func localWeatherUnit(currentForecast: Forecast) -> String {
    let forecastUnit = currentForecast.flags?.units
    var unit = ""
    if forecastUnit == "us" {
      unit = "F"
    } else {
      unit = "C"
    }
    return unit
  }

  func openAlertInBrowser(sender: AnyObject) {
    print(sender.representedObject)
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


//  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
//  }

}

