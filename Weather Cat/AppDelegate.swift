//
//  Weather Cat
//

import Cocoa
import CoreLocation

import SwiftDate
import ForecastIO
let forecastIOClient = APIClient(apiKey: "480b791a0bd0965a07bc7b19c4b901e7")

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {
  let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-2)
  let locationManager = CLLocationManager()
  let menu = NSMenu()

  let currentApparentTemperatureMenuItemTag = 1
  let summaryMenuItemTag = 2
  // 👷 'sunset' to 'sunriseOrSunset'
  let sunriseOrSunsetTimeMenuItemTag = 3
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

      let sunriseOrSunsetTimeMenuItem = NSMenuItem(title: "🌙 --:--", action: Selector(), keyEquivalent: "")
      sunriseOrSunsetTimeMenuItem.tag = sunriseOrSunsetTimeMenuItemTag
      sunriseOrSunsetTimeMenuItem.enabled = false
      menu.addItem(sunriseOrSunsetTimeMenuItem)

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
        let summary = (currentForecast.daily?.data![0].summary)! as NSString
        let summaryMenuItem = self.menu.itemWithTag(self.summaryMenuItemTag)
        summaryMenuItem?.title = "\(weatherEmoji) \(summary)"

        //      todo: submenu
        //        print(currentForecast.hourly) "4pm 54F - 60F", etc
        // w weatherunit
        self.updateSunriseOrSunsetTime(currentForecast)

        self.updateWeatherAlerts(currentForecast)
      } else if let error = error {
        print(error)
      }
    }
  }

//MARK: - Forecast Methods

  func weatherEmoji(currentForecast: Forecast) -> String {
    let precipEmoji = getPrecipWeatherEmoji(currentForecast)
    let apparentTemperature = Int(round((currentForecast.currently?.apparentTemperature)!))
    let warm = 70
    let cool = 50
//    - hot(sunny+>70) 👙👟
//      - medium(50-70) 👕👗
//        - cold(>50) 👖👘
//
//    also, (prepended)

    //    - >= 0.6 ☔️ add precip warning emoji if precipProbability > .. and preceipIntensity > ..
    //    - < 0.6 🌂 for less chance
    // - < 0.2 no emoji
    // ☔️ add precip warning emoji if precipProbability > .. and preceipIntensity > ..
    // next: get weather/clothes emojis for temp string
    return "\(precipEmoji)👙👟"
  }

  func getPrecipWeatherEmoji(currentForecast: Forecast) -> String {
    let precipProbability = currentForecast.daily?.data![0].precipProbability as Float!
    print(precipProbability)
    var precipEmoji = ""
    if precipProbability >= 0.6 {
      precipEmoji = "☔️"
    } else if precipProbability < 0.6 && precipProbability >= 0.2 {
      precipEmoji = "🌂"
    } else if precipProbability < 0.2 {
      precipEmoji = ""
    }
    return precipEmoji
  }

  func updateSunriseOrSunsetTime(currentForecast: Forecast) {
    let sunset = currentForecast.daily?.data![0].sunsetTime as NSDate!
    let sunrise = currentForecast.daily?.data![0].sunriseTime as NSDate!
    let now = NSDate()
    var sunriseOrSunset = ""
    if now < sunrise {
      let sunriseTime = "☀️ \(NSDateFormatter.localizedStringFromDate(sunrise!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))"
      sunriseOrSunset = sunriseTime
    } else {
      let moonPhase = currentForecast.daily?.data![0].moonPhase
      let moon = updateMoonPhaseEmoji(moonPhase!)
      let sunsetTime = "\(moon) \(NSDateFormatter.localizedStringFromDate(sunset!, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle))"
      sunriseOrSunset = sunsetTime
    }
    let sunriseOrSunsetTimeMenuItem = self.menu.itemWithTag(self.sunriseOrSunsetTimeMenuItemTag)
    sunriseOrSunsetTimeMenuItem?.title = sunriseOrSunset
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
  }

//  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
//  }

}

