//
//  QSWindow.swift
//  vechseler
//
//  Created by Björn Friedrichs on 30/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class QSWindow: NSObject {
  let cgWindow: CGWindow
  let axWindow: AXUIElement?
  let app: NSRunningApplication
  var isHidden = false
  var isClosed = false

  init(cgWindow: CGWindow, axWindow: AXUIElement?, app: NSRunningApplication) {
    self.cgWindow = cgWindow
    self.axWindow = axWindow
    self.app = app

    super.init()
  }

  func title() -> String {
    let cgTitle = cgWindow.name()
    if cgTitle != nil && cgTitle != "" {
      return cgTitle!
    }
    let axTitle: String? = axWindow?.getAttribute("Title")
    if axTitle != nil && axTitle != "" {
      return axTitle!
    }
    if app.localizedName != nil && app.localizedName != "" {
      return app.localizedName!
    }

    return "Unknown"
  }

  func focus() {
    // Call bridged function to focus the window
    // See SkyLight.c
    makeKeyWindow(
      app.processIdentifier, self.cgWindow.windowId())

    if axWindow == nil {
      app.activate(options: .activateIgnoringOtherApps)
    } else {
      axWindow!.setAttribute("Main", value: true as CFTypeRef)
      AXUIElementPerformAction(axWindow!, kAXRaiseAction as CFString)
    }
  }
}
