//
//  AppDelegate.swift
//  Weather Cat
//
//  Created by Pirijan on 2016-04-02.
//  Copyright © 2016 Pirijan Ketheswaran. All rights reserved.
//

import Cocoa

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
    }
  }

  // func getLocation() {
  // }

  // func getWeather(location) {
  // gets current weather for *location
  // }

  func printQuote(sender: AnyObject) {
    let quoteText = "Never put off until tomorrow what you can do the day after tomorrow."
    let quoteAuthor = "Mark Twain"
    print("\(quoteText) — \(quoteAuthor)")
  }


  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }
  
  
}

