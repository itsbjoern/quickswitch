//
//  PreferencesStore.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 02/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class PreferencesStore {
    enum Preference: String { case backgroundStyle, mainSequence, reverseSequence, cycleBackwardsWithShift, showPreviews, showCloseButton, previewSize, keepClosedWindows, enableMouseSelection }

    struct Default {
        let key: Preference
        let defaultValue: AnyObject
        let onChange: (AnyObject) -> Void
        
        init(_ key: Preference, _ defaultValue: AnyObject, _ onChange: @escaping (AnyObject) -> Void) {
            self.key = key
            self.defaultValue = defaultValue
            self.onChange = onChange
        }
    }

    fileprivate let userDefaults = UserDefaults.standard
    fileprivate var defaults: [Preference: Default] = [:]
    fileprivate let prefix = Bundle.main.bundleIdentifier!
    
    fileprivate static var _instance: PreferencesStore?
    static var shared: PreferencesStore {
        get {
            guard let instance = PreferencesStore._instance else {
                PreferencesStore._instance = PreferencesStore()
                return PreferencesStore._instance!
            }
            return instance
        }
    }
    
    fileprivate init() {
        let lst: [Default] = [
            Default(.backgroundStyle, NSVisualEffectView.Material.dark as AnyObject, { (newValue) in
                let delegate = NSApp.delegate as! AppDelegate
                let view = delegate.switcherWindow.controller!.view as! NSVisualEffectView
                let mat = PreferencesDefaults.Materials[newValue as! Int]
                view.material = mat.value
            }),
            Default(.mainSequence, [KeyHandler.FlagAsInt.command.rawValue, 48] as AnyObject, { (newValue) in
                let delegate = NSApp.delegate as! AppDelegate
                delegate.keyHandler!.removeEventListeners(key: .main)
                delegate.addMainListener(forSequence: newValue as! [Int64])
            }),
            Default(.reverseSequence, [KeyHandler.FlagAsInt.command.rawValue, KeyHandler.FlagAsInt.shift.rawValue, 48] as AnyObject, { (newValue) in
            }),
            Default(.cycleBackwardsWithShift, true as AnyObject, { (newValue) in
                let delegate = NSApp.delegate as! AppDelegate
                delegate.cycleBackwardsWithShift = newValue as! Bool
            }),
            Default(.showPreviews, true as AnyObject, { (newValue) in
            }),
            Default(.previewSize, 130 as AnyObject, { (newValue) in
            }),
            Default(.showCloseButton, true as AnyObject, { (newValue) in
                let delegate = NSApp.delegate as! AppDelegate
                let switcher = delegate.switcherWindow.controller!
                switcher.setShowClose(newValue as! Bool)
            }),
            Default(.keepClosedWindows, true as AnyObject, { (newValue) in
            }),
            Default(.enableMouseSelection, true as AnyObject, { (newValue) in
            }),
        ]
        
        for l in lst {
            defaults.updateValue(l, forKey: l.key)
        }
    }

    func saveValue(_ val: Bool, forKey key: Preference) {
        self.saveValue(val as AnyObject, forKey: key)
    }
    
    func saveValue(_ val: String, forKey key: Preference) {
        self.saveValue(val as AnyObject, forKey: key)
    }
    
    func saveValue(_ val: Int, forKey key: Preference) {
        self.saveValue(val as AnyObject, forKey: key)
    }
    
    func saveValue(_ val: [Int], forKey key: Preference) {
        self.saveValue(val as AnyObject, forKey: key)
    }
    
    func saveValue(_ val: [NSNumber], forKey key: Preference) {
        self.saveValue(val as AnyObject, forKey: key)
    }
    
    fileprivate func saveValue(_ val: AnyObject, forKey key: Preference) {
        DispatchQueue.main.async {
            self.userDefaults.set(val, forKey: "\(self.prefix).\(key.rawValue)")
            self.applyChange(key: key, newValue: val as AnyObject)
        }
    }
    
    fileprivate func applyChange(key: Preference, newValue: AnyObject) {
        let def = self.defaults[key]
        def!.onChange(newValue)
    }
    
    fileprivate func getValue(_ key: Preference) -> Any? {
        return userDefaults.object(forKey: "\(self.prefix).\(key.rawValue)")
    }

    func getValue<T: Any>(_ key: Preference) -> T {
        let val = self.getValue(key)
        return val as? T ?? self.defaults[key]!.defaultValue as! T
    }
    
    func getValue<T: RawRepresentable>(_ key: Preference) -> T {
        let val = self.getValue(key)
        return T.init(rawValue: val as? T.RawValue ?? self.defaults[key]!.defaultValue as! T.RawValue)!
    }
}
