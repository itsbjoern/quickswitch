//
//  ConfigViewController.swift
//  vechseler
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

  // Buttons need to be properties so they can be updated
  let mainSequenceButton = SequenceButton(title: "", target: nil, action: nil)
  let reverseSequenceButton = SequenceButton(title: "", target: nil, action: nil)
  var recordingButton: SequenceButton?

  override func loadView() {
    print("Loading ConfigViewController")
    // Container view for padding
    let container = NSView()
    container.translatesAutoresizingMaskIntoConstraints = false

    // Main vertical stack
    let mainStack = NSStackView()
    mainStack.orientation = .vertical
    mainStack.spacing = 16
    mainStack.alignment = .leading
    mainStack.translatesAutoresizingMaskIntoConstraints = false

    // Section: Keys
    mainStack.addArrangedSubview(makeSectionHeader(title: "Keys"))

    // Cycle Forwards
    let mainSeqStack = NSStackView()
    mainSeqStack.orientation = .horizontal
    mainSeqStack.spacing = 8
    mainSeqStack.alignment = .centerY

    let mainSeqLabel = NSLabel(text: "Cycle Forwards")
    mainSeqLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
    mainSeqLabel.textColor = .labelColor
    mainSeqLabel.toolTip = "Key sequence used to activate and cycle forwards."

    let mainSequence = PreferenceStore.shared.mainSequence
    mainSequenceButton.title = sequenceToString(mainSequence)
    mainSequenceButton.sizeToFit()
    mainSequenceButton.needsDisplay = true
    mainSequenceButton.setFrameX(-5)
    mainSequenceButton.target = self
    mainSequenceButton.action = #selector(mainSequenceChange(_:))

    mainSeqStack.addArrangedSubview(mainSeqLabel)
    mainSeqStack.addArrangedSubview(mainSequenceButton)
    mainStack.addArrangedSubview(mainSeqStack)

    // Cycle Backwards
    let reverseSeqStack = NSStackView()
    reverseSeqStack.orientation = .horizontal
    reverseSeqStack.spacing = 8
    reverseSeqStack.alignment = .centerY

    let reverseSeqLabel = NSLabel(text: "Cycle Backwards")
    reverseSeqLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
    reverseSeqLabel.textColor = .labelColor
    reverseSeqLabel.toolTip = "Key sequence used to activate and cycle backwards."

    let reverseSequence = PreferenceStore.shared.reverseSequence
    reverseSequenceButton.title = sequenceToString(reverseSequence)
    reverseSequenceButton.sizeToFit()
    reverseSequenceButton.needsDisplay = true
    reverseSequenceButton.setFrameX(-5)
    reverseSequenceButton.target = self
    reverseSequenceButton.action = #selector(reverseSequenceChange(_:))

    let shiftCheckbox = NSButton(
      checkboxWithTitle: "Enable backwards cycling with ⌘ + ⇧ while activated.", target: self,
      action: #selector(setCycleShift(_:)))
    shiftCheckbox.state = PreferenceStore.shared.cycleBackwardsWithShift ? .on : .off

    let reverseButtonStack = NSStackView()
    reverseButtonStack.orientation = .vertical
    reverseButtonStack.spacing = 6
    reverseButtonStack.alignment = .leading
    reverseButtonStack.addArrangedSubview(reverseSequenceButton)
    reverseButtonStack.addArrangedSubview(shiftCheckbox)

    reverseSeqStack.addArrangedSubview(reverseSeqLabel)
    reverseSeqStack.addArrangedSubview(reverseButtonStack)
    mainStack.addArrangedSubview(reverseSeqStack)

    // Section: Other
    mainStack.addArrangedSubview(makeSectionHeader(title: "Other"))

    // Enable mouse selection
    let mouseStack = NSStackView()
    mouseStack.orientation = .horizontal
    mouseStack.spacing = 8
    mouseStack.alignment = .centerY

    let mouseLabel = NSLabel(text: "Enable mouse selection")
    mouseLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
    mouseLabel.textColor = .labelColor
    mouseLabel.toolTip = "Select windows by hovering with the mouse"

    let mouseCheckbox = NSButton(
      checkboxWithTitle: "", target: self, action: #selector(setEnableMouseSelection(_:)))
    mouseCheckbox.state = PreferenceStore.shared.enableMouseSelection ? .on : .off

    mouseStack.addArrangedSubview(mouseLabel)
    mouseStack.addArrangedSubview(mouseCheckbox)
    mainStack.addArrangedSubview(mouseStack)

    container.addSubview(mainStack)
    self.view = container

    // Padding: 20pt on all sides
    NSLayoutConstraint.activate([
      mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
      mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
      mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
      mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
    ])
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

  @objc func setCycleShift(_ checkbox: NSButton) {
    let isOn = checkbox.state == .on
    PreferenceStore.shared.cycleBackwardsWithShift = isOn
  }

  @objc func setEnableMouseSelection(_ checkbox: NSButton) {
    let isOn = checkbox.state == .on
    PreferenceStore.shared.enableMouseSelection = isOn
  }

}
