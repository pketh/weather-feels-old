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
  let summaryMenuItemTag = 2
  let sunsetTimeMenuItemTag = 3
  let alertMenuItemTag = 4

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    self.menu.autoenablesItems = false
    if let button = statusItem.button {
      button.image = NSImage(named: "StatusBarButtonImage")
      // button.action = #selector(AppDelegate.updateData(_:))
      statusItem.menu = menu

      let currentApparentTemperatureMenuItem = NSMenuItem(title: "--°", action: #selector(AppDelegate.openForecastInBrowser(_:)), keyEquivalent: "t")
      currentApparentTemperatureMenuItem.tag = currentApparentTemperatureMenuItemTag
      // 🐈 hide or remove this item once I get the temp in the statusitem
      //      currentApparentTemperatureMenuItem.hidden = true
      menu.addItem(currentApparentTemperatureMenuItem)

      // becomes a submenu w hourly updates list
      let summaryMenuItem = NSMenuItem(title: "🔮🌈 -----", action: Selector(), keyEquivalent: "")
      summaryMenuItem.tag = summaryMenuItemTag
      menu.addItem(summaryMenuItem)

      let sunsetTimeMenuItem = NSMenuItem(title: "🌙 --:--", action: Selector(), keyEquivalent: "")
      sunsetTimeMenuItem.tag = sunsetTimeMenuItemTag
      sunsetTimeMenuItem.enabled = false
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
    // print("location is latitude \(latitude), longitude \(longitude)")
    forecastIOClient.units = .Auto
    forecastIOClient.getForecast(latitude: latitude, longitude: longitude) { (currentForecast, error) -> Void in
      if let currentForecast = currentForecast {
        let apparentTemperature = Int(round((currentForecast.currently?.apparentTemperature)!))

        // 🐈 set this to using temp in the statusitem
        let weatherUnit = self.localWeatherUnit(currentForecast)
        let currentApparentTemperatureMenuItem = self.menu.itemWithTag(self.currentApparentTemperatureMenuItemTag)
        currentApparentTemperatureMenuItem?.title = "\(apparentTemperature)°\(weatherUnit)"
        currentApparentTemperatureMenuItem?.representedObject = "\(latitude),\(longitude)"

        let weatherEmoji = self.weatherEmoji(currentForecast)
        let summary = (currentForecast.minutely?.summary)! as NSString
        let summaryMenuItem = self.menu.itemWithTag(self.summaryMenuItemTag)
        summaryMenuItem?.title = "\(weatherEmoji) \(summary)"

        //      todo: submenu
        //        print(currentForecast.hourly) "4pm 54F - 60F", etc
        // w weatherunit
        self.updateSunsetTime(currentForecast)

        self.updateWeatherAlerts(currentForecast)
      } else if let error = error {
        print(error)
      }
    }
  }

//MARK: - Forecast Methods

  func weatherEmoji(currentForecast: Forecast) -> String {
//    - hot(sunny+>70) 👙👟
//      - medium(60-70) 👕👗
//        - cold(>60) 👖👘
//
//    also, (prepended)
//    - ☔️ add precip warning emoji if precipProbability > .. and preceipIntensity > ..
//    - 🌂 for less chance
    // ☔️ add precip warning emoji if precipProbability > .. and preceipIntensity > ..
    // next: get weather/clothes emojis for temp string
    return "👙👟"
  }

  func updateSunsetTime(currentForecast: Forecast) {
    let moonPhase = currentForecast.daily?.data![0].moonPhase
    let moon = updateMoonPhaseEmoji(moonPhase!)
    let sunset = currentForecast.daily?.data![0].sunsetTime
    let sunsetTime = "\(moon) \(NSDateFormatter.localizedStringFromDate(sunset!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))"
    let sunsetTimeMenuItem = self.menu.itemWithTag(self.sunsetTimeMenuItemTag)
    sunsetTimeMenuItem?.title = sunsetTime
  }

  func updateMoonPhaseEmoji(moonPhase: Float) -> String {
    var moon = ""
    if moonPhase == 0 || moonPhase == 100 {
      moon = "🌑"
    } else if moonPhase > 0 && moonPhase < 25 {
      moon = "🌒"
    } else if moonPhase == 25 {
      moon = "🌓"
    } else if moonPhase > 25 && moonPhase < 50 {
      moon = "🌔"
    } else if moonPhase == 50 {
      moon = "🌕"
    } else if moonPhase > 50 && moonPhase < 75 {
      moon = "🌖"
    } else if moonPhase == 75 {
      moon = "🌗"
    } else if moonPhase > 75 && moonPhase < 100 {
      moon = "🌘"
    } else {
      moon = "🌙"
    }
    return moon
  }

  func updateWeatherAlerts(currentForecast: Forecast) {
    let alertMenuItem = self.menu.itemWithTag(self.alertMenuItemTag)
    if let alerts: Alert = currentForecast.alerts?[0] {
      alertMenuItem?.title = "\(alerts.title)…"
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
    if let uri = sender.representedObject {
      NSWorkspace.sharedWorkspace().openURL(NSURL(string: "\(uri!)")!)
    }
  }

  func openForecastInBrowser(sender: AnyObject) {
    if let location = sender.representedObject {
      NSWorkspace.sharedWorkspace().openURL(NSURL(string: "http://forecast.io/#/f/\(location!)")!)
    }
    // http://forecast.io/#/f/40.6950,-73.9954
  }

//  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
//  }

}

