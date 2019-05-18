//
//  PreferencesDefaults.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 02/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class PreferencesDefaults {
    static let Materials: [(label: String, value: NSVisualEffectView.Material)] = [
        ("Default", .appearanceBased),
        ("Dark", .dark),
        ("Darker", .ultraDark),
        ("Light", .light),
        ("Opaque Light", .mediumLight),
        ("HUD", .hudWindow)
    ]
}

