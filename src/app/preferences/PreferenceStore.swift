//
//  PreferencesStore.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 02/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class PreferenceStore {
  fileprivate static var _instance: PreferenceStore?
  static var shared: PreferenceStore {
    guard let instance = PreferenceStore._instance else {
      PreferenceStore._instance = PreferenceStore()
      return PreferenceStore._instance!
    }
    return instance
  }

  private var _mainSequence = [KeyHandler.FlagAsInt.command.rawValue, 48]
  var mainSequence: [Int64] {
    get {
      return _mainSequence
    }
    set {
      _mainSequence = newValue

      DispatchQueue.main.async {
        let delegate = NSApp.delegate as! AppDelegate
        delegate.keyHandler!.removeEventListeners(key: .main)
        delegate.addMainListener(forSequence: newValue)

        UserDefaults.standard.set(
          newValue, forKey: "\(Bundle.main.bundleIdentifier!).mainSequence")
      }
    }
  }

  private var _reverseSequence = [
    KeyHandler.FlagAsInt.command.rawValue, KeyHandler.FlagAsInt.shift.rawValue, 48,
  ]
  var reverseSequence: [Int64] {
    get {
      return _reverseSequence
    }
    set {
      _reverseSequence = newValue

      DispatchQueue.main.async {
        UserDefaults.standard.set(
          newValue, forKey: "\(Bundle.main.bundleIdentifier!).reverseSequence")
      }
    }
  }

  private var _cycleBackwardsWithShift = true
  var cycleBackwardsWithShift: Bool {
    get {
      return _cycleBackwardsWithShift
    }
    set {
      _cycleBackwardsWithShift = newValue

      DispatchQueue.main.async {
        let delegate = NSApp.delegate as! AppDelegate
        delegate.cycleBackwardsWithShift = newValue

        UserDefaults.standard.set(
          newValue, forKey: "\(Bundle.main.bundleIdentifier!).cycleBackwardsWithShift")
      }
    }
  }

  private var _previewSize = 130
  var previewSize: Int {
    get {
      return _previewSize
    }
    set {
      _previewSize = newValue

      DispatchQueue.main.async {
        UserDefaults.standard.set(
          newValue, forKey: "\(Bundle.main.bundleIdentifier!).previewSize")
      }
    }
  }

  private var _keepClosedWindows = true
  var keepClosedWindows: Bool {
    get {
      return _keepClosedWindows
    }
    set {
      _keepClosedWindows = newValue

      DispatchQueue.main.async {
        UserDefaults.standard.set(
          newValue, forKey: "\(Bundle.main.bundleIdentifier!).keepClosedWindows")
      }
    }
  }

  private var _enableMouseSelection = true
  var enableMouseSelection: Bool {
    get {
      return _enableMouseSelection
    }
    set {
      _enableMouseSelection = newValue

      DispatchQueue.main.async {
        UserDefaults.standard.set(
          newValue, forKey: "\(Bundle.main.bundleIdentifier!).enableMouseSelection")
      }
    }
  }

  fileprivate init() {
    _mainSequence =
      UserDefaults.standard.object(forKey: "\(Bundle.main.bundleIdentifier!).mainSequence")
      as? [Int64] ?? _mainSequence
    _reverseSequence =
      UserDefaults.standard.object(forKey: "\(Bundle.main.bundleIdentifier!).reverseSequence")
      as? [Int64] ?? _reverseSequence

    _cycleBackwardsWithShift =
      UserDefaults.standard.object(
        forKey: "\(Bundle.main.bundleIdentifier!).cycleBackwardsWithShift") as? Bool
      ?? _cycleBackwardsWithShift

    _previewSize =
      UserDefaults.standard.object(forKey: "\(Bundle.main.bundleIdentifier!).previewSize")
      as? Int ?? _previewSize

    _keepClosedWindows =
      UserDefaults.standard.object(
        forKey: "\(Bundle.main.bundleIdentifier!).keepClosedWindows") as? Bool
      ?? _keepClosedWindows

    _enableMouseSelection =
      UserDefaults.standard.object(
        forKey: "\(Bundle.main.bundleIdentifier!).enableMouseSelection") as? Bool
      ?? _enableMouseSelection

  }
}
