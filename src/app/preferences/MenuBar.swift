//
//  MenuBar.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 28/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class MenuBar: NSMenu {
    var preferences: PreferenceController

    init() {
        let del = NSApplication.shared.delegate as! AppDelegate
        self.preferences = del.preferencesWindowController

        super.init(title: "QuickSwitcher")
        let titleItem = NSMenuItem(
            title: "QuickSwitcher v\(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!)",
            action: nil, keyEquivalent: "")
        self.addItem(titleItem)
        self.addItem(.separator())

        let openPrefsItem = NSMenuItem(
            title: "Preferences", action: #selector(self.openPrefs), keyEquivalent: "")
        openPrefsItem.target = self
        self.addItem(openPrefsItem)

        let closeItem = NSMenuItem(
            title: "Quit", action: #selector(self.closeApp), keyEquivalent: "")
        closeItem.target = self
        self.addItem(closeItem)
    }

    @objc func openPrefs() {
        preferences.showWindow(nil)
    }

    @objc func closeApp() {
        exit(0)
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
