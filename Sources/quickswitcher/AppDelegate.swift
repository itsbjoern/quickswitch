//
//  AppDelegate.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 26/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa
import Carbon
import AXSwift

class AppDelegate: NSObject, NSApplicationDelegate {
    var keyHandler: KeyHandler?
    
    lazy var preferencesWindowController = PreferenceController()
    lazy var switcherWindow = SwitcherWindow()
    var statusbarItem: NSStatusItem?
    
    fileprivate let _cycleBackwardsWithShiftSequence = [KeyHandler.FlagAsInt.command.rawValue, KeyHandler.FlagAsInt.shift.rawValue]
    fileprivate var _cycleBackwardsWithShift = false
    var cycleBackwardsWithShift: Bool {
        get {
            return self._cycleBackwardsWithShift
        }
        set {
            if newValue && self._cycleBackwardsWithShift != newValue {
                keyHandler!.addEventListener(key: .mainReverse, sequence: _cycleBackwardsWithShiftSequence, self.reverseCallback)
            }
            self._cycleBackwardsWithShift = newValue
            if !newValue {
                keyHandler!.removeEventListeners(key: .mainReverse, sequence: _cycleBackwardsWithShiftSequence)
            }
        }
    }
    
    func addMainListener(forSequence sequence: [Int64]) {
        let switcher = switcherWindow
        self.keyHandler!.addEventListener(key: .main, sequence: sequence) { _ -> Bool in
            if !switcher.isVisible {
                switcher.show()
            }
            switcher.cycleForwards()
            return true
        }
    }
    
    func reverseCallback(_ evt: KeyHandler.Event) -> Bool {
        let switcher = switcherWindow
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
        self.keyHandler!.addEventListener(key: .mainReverse, sequence: sequence, self.reverseCallback)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard AXIsProcessTrusted() else {
            AXSwift.checkIsProcessTrusted(prompt: true)
            let alert = NSAlert()
            alert.messageText = "Accessibility permissions needed"
            alert.informativeText = "Please enable accessibility permissions and re-run the application."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Confirm")
            alert.runModal()
            exit(1)
        }
        self.keyHandler = KeyHandler()

        let switcher = switcherWindow
        let mainSequence: [Int64] = PreferencesStore.shared.getValue(.mainSequence)
        self.addMainListener(forSequence: mainSequence)

        let reverseSequence: [Int64] = PreferencesStore.shared.getValue(.reverseSequence)
        self.addReverseListener(forSequence: reverseSequence)
        
        self.cycleBackwardsWithShift = PreferencesStore.shared.getValue(.cycleBackwardsWithShift)
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
