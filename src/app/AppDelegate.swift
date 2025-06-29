//
//  AppDelegate.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 26/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Carbon
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
  var keyHandler: KeyHandler?

  lazy var preferencesWindowController = PreferenceController()
  lazy var previewWindow = PreviewWindow()
  var statusbarItem: NSStatusItem?

  fileprivate let _cycleBackwardsWithShiftSequence = [
    KeyHandler.FlagAsInt.command.rawValue, KeyHandler.FlagAsInt.shift.rawValue,
  ]
  fileprivate var _cycleBackwardsWithShift = false
  var cycleBackwardsWithShift: Bool {
    get {
      return self._cycleBackwardsWithShift
    }
    set {
      if newValue && self._cycleBackwardsWithShift != newValue {
        keyHandler!.addEventListener(
          key: .mainReverse, sequence: _cycleBackwardsWithShiftSequence,
          self.reverseCallback)
      }
      self._cycleBackwardsWithShift = newValue
      if !newValue {
        keyHandler!.removeEventListeners(
          key: .mainReverse, sequence: _cycleBackwardsWithShiftSequence)
      }
    }
  }

  func addMainListener(forSequence sequence: [Int64]) {
    let switcher = previewWindow
    self.keyHandler!.addEventListener(key: .main, sequence: sequence) { _ -> Bool in
      if !switcher.isVisible {
        switcher.show()
      }
      switcher.cycleForwards()
      return true
    }
  }

  func reverseCallback(_ evt: KeyHandler.Event) -> Bool {
    let switcher = previewWindow
    if !switcher.isVisible {
      if self.cycleBackwardsWithShift && evt.sequence == _cycleBackwardsWithShiftSequence {
        return false
      }
      switcher.show()
    }
    switcher.cycleBackwards()
    return true
  }

  func addReverseListener(forSequence sequence: [Int64]) {
    self.keyHandler!.addEventListener(
      key: .mainReverse, sequence: sequence, self.reverseCallback)
  }

  func promptForAccessibilityAccess() {
    // Check if the app is already trusted
    let isTrusted = AXIsProcessTrusted()

    guard !isTrusted else {
      print("Accessibility access already granted.")
      return
    }

    // Show a user-facing alert explaining why it's needed
    let alert = NSAlert()
    alert.messageText = "Accessibility Permission Required"
    alert.informativeText = """
      This app requires Accessibility access to control the mouse, keyboard, or other input devices.
      Please enable this in System Settings under Privacy & Security → Accessibility.
      """
    alert.alertStyle = .warning
    alert.addButton(withTitle: "Done")
    alert.addButton(withTitle: "Quit")

    if let url = URL(
      string:
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    {
      NSWorkspace.shared.open(url)
    }
    let response = alert.runModal()
    if response == .alertFirstButtonReturn {
      // Done
    } else {
      exit(1)
    }
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    while !AXIsProcessTrusted() {
      promptForAccessibilityAccess()
    }
    self.keyHandler = KeyHandler()

    let switcher = previewWindow
    let mainSequence: [Int64] = PreferenceStore.shared.mainSequence
    self.addMainListener(forSequence: mainSequence)

    let reverseSequence: [Int64] = PreferenceStore.shared.reverseSequence
    self.addReverseListener(forSequence: reverseSequence)

    self.cycleBackwardsWithShift = PreferenceStore.shared.cycleBackwardsWithShift
    self.keyHandler!.addEventListener(key: .close, sequence: []) { _ -> Bool in
      if switcher.isVisible {
        switcher.hide()
      }
      return false
    }

    let menu = MenuBar()

    let bar = NSStatusBar.system
    statusbarItem = bar.statusItem(withLength: -1)
    let statusImage = NSImage(named: "StatusbarIcon")!
    let ar = statusImage.size.height / statusImage.size.width
    statusImage.size = NSMakeSize(17, 17 * ar)
    statusbarItem!.button!.image = statusImage

    statusbarItem!.menu = menu
  }
}
