//
//  ConfigViewController.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 04/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class SequenceButton: NSButton {
  var shortcutTitle: String?

  func setRecording() {
    self.isEnabled = false
    self.shortcutTitle = self.title
    self.title = "● Recording"
    self.sizeToFit()
    self.needsDisplay = true
  }

  func setNormal() {
    self.isEnabled = true
    self.title = self.shortcutTitle!
    self.sizeToFit()
    self.needsDisplay = true
  }
}

class ConfigViewController: NSViewController, PreferencePane {
  var preferenceTabTitle = "Config"
  let preferenceTable = PreferenceTable()

  let defaults = UserDefaults.standard
  let mainSequenceButton = SequenceButton(
    title: "", target: self, action: #selector(mainSequenceChange))
  let reverseSequenceButton = SequenceButton(
    title: "", target: self, action: #selector(reverseSequenceChange))
  var recordingButton: SequenceButton?

  class FlippedView: NSView {
    override var isFlipped: Bool {
      return true
    }
  }

  override func loadView() {
    let view = FlippedView(frame: NSMakeRect(0, 0, 500, 300))
    view.addSubview(preferenceTable)
    preferenceTable.setFrameSize(view.frame.size)
    self.view = view
  }

  func sequenceToString(_ sequence: [Int64]) -> String {
    var out = ""
    for key in sequence {
      if KeyHandler.FlagAsInt.contains(key: key) {
        out += " + \(KeyHandler.FlagAsInt(rawValue: key)!.asString())"
      } else {
        out += " + \(KeyCodes[key, default: KeyCode("?", 99999)].key)"
      }
    }
    return " \(String(out.dropFirst(3))) "
  }

  @objc func mainSequenceChange(_ button: SequenceButton) {
    let delegate = NSApplication.shared.delegate as! AppDelegate
    let keyHandler = delegate.keyHandler
    recordingButton = button

    button.setRecording()

    keyHandler!.recordSequence { (sequence) in
      //            let nums: [NSNumber] = sequence.map({ (i) -> NSNumber in
      //                return NSNumber(value: i)
      //            })
      button.setNormal()

      PreferenceStore.shared.mainSequence = sequence
      button.title = self.sequenceToString(sequence)
      button.sizeToFit()
      self.recordingButton = nil
    }
  }

  @objc func reverseSequenceChange(_ button: SequenceButton) {
    let delegate = NSApplication.shared.delegate as! AppDelegate
    let keyHandler = delegate.keyHandler
    recordingButton = button

    button.setRecording()

    keyHandler!.recordSequence { (sequence) in
      //            let nums: [NSNumber] = sequence.map({ (i) -> NSNumber in
      //                return NSNumber(value: i)
      //            })
      button.setNormal()

      PreferenceStore.shared.reverseSequence = sequence
      button.title = self.sequenceToString(sequence)
      button.sizeToFit()
      self.recordingButton = nil
    }
  }

  func paneWillDisappear() {
    let delegate = NSApplication.shared.delegate as! AppDelegate
    let keyHandler = delegate.keyHandler
    keyHandler!.stopRecording()

    guard let button = recordingButton else {
      return
    }
    button.setNormal()
  }

  func getMainCell() -> NSView {
    let wrapper = ResizingView()

    let sequence: [Int64] = PreferenceStore.shared.mainSequence
    let sequenceString = sequenceToString(sequence)
    mainSequenceButton.title = sequenceString
    mainSequenceButton.sizeToFit()
    mainSequenceButton.needsDisplay = true
    mainSequenceButton.setFrameX(-5)

    wrapper.addSubview(mainSequenceButton)
    return wrapper
  }

  @objc func setCycleShift(_ checkbox: NSButton) {
    let isOn = checkbox.state == .on
    PreferenceStore.shared.cycleBackwardsWithShift = isOn
  }

  func getReverseCell() -> NSView {
    let sequence: [Int64] = PreferenceStore.shared.reverseSequence
    let sequenceString = sequenceToString(sequence)

    reverseSequenceButton.title = sequenceString
    reverseSequenceButton.sizeToFit()
    reverseSequenceButton.needsDisplay = true
    reverseSequenceButton.setFrameX(-5)

    let checkbox = NSButton(
      checkboxWithTitle: "Enable ⌘ + ⇧ when activated.", target: self,
      action: #selector(setCycleShift))
    checkbox.state = PreferenceStore.shared.cycleBackwardsWithShift ? .on : .off
    reverseSequenceButton.setFrameY(reverseSequenceButton.frame.height - 10)

    let wrapper = ResizingView()
    wrapper.addSubview(reverseSequenceButton)
    wrapper.addSubview(checkbox)
    return wrapper
  }

  func getKeepClosedWindows() -> NSView {
    let checkbox = NSButton(
      checkboxWithTitle: "", target: self, action: #selector(setKeepClosedWindow))
    checkbox.state = PreferenceStore.shared.keepClosedWindows ? .on : .off
    return checkbox
  }

  @objc func setKeepClosedWindow(_ checkbox: NSButton) {
    let isOn = checkbox.state == .on
    PreferenceStore.shared.keepClosedWindows = isOn
  }

  func getEnableMouseSelection() -> NSView {
    let checkbox = NSButton(
      checkboxWithTitle: "", target: self, action: #selector(setEnableMouseSelection))
    checkbox.state = PreferenceStore.shared.enableMouseSelection ? .on : .off
    return checkbox
  }

  @objc func setEnableMouseSelection(_ checkbox: NSButton) {
    let isOn = checkbox.state == .on
    PreferenceStore.shared.enableMouseSelection = isOn
  }

  override func viewDidLoad() {
    preferenceTable.addSubview(PreferencesSeperator(text: "Keys"))
    preferenceTable.addSubview(
      PreferencesCell(
        label: "Cycle Forwards",
        tooltip: "Key sequence used to activate and cycle forwards.",
        control: getMainCell(),
        textOffset: 7
      ))
    preferenceTable.addSubview(
      PreferencesCell(
        label: "Cycle Backwards",
        tooltip: "Key sequence used to activate and cycle backwards.",
        control: getReverseCell(),
        textOffset: 7
      ))
    preferenceTable.addSubview(PreferencesSeperator(text: "Other"))
    preferenceTable.addSubview(
      PreferencesCell(
        label: "Keep running application windows",
        tooltip:
          "Enables reopening a window if the application is still running even if the window has been closed previously",
        control: getKeepClosedWindows()
      ))
    preferenceTable.addSubview(
      PreferencesCell(
        label: "Enable mouse selection",
        tooltip: "Select windows by hovering with the mouse",
        control: getEnableMouseSelection()
      ))
  }
}
