//
//  ConfigViewController.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 04/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class SequenceButton: NSButton {
    var prefType: PreferencesStore.Preference?
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

class ConfigViewController : NSViewController, PreferencePane {
    var preferenceTabTitle = "Config"
    let preferenceTable = PreferenceTable()

    let defaults = UserDefaults.standard
    let mainSequenceButton = SequenceButton(title: "", target: self, action: #selector(sequenceChange))
    let reverseSequenceButton = SequenceButton(title: "", target: self, action: #selector(sequenceChange))
    var recordingButton: SequenceButton?
    
    class FlippedView: NSView {
        override var isFlipped: Bool {
            get {
                return true
            }
        }
    }
    
    override func loadView() {
        let view = FlippedView(frame: NSMakeRect(0, 0, 500, 400))
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
    
    func getButton(_ button: SequenceButton, _ key: PreferencesStore.Preference) -> NSView {
        let sequence: [Int64] = PreferencesStore.shared.getValue(key)
        let sequenceString = sequenceToString(sequence)
        button.title = sequenceString
        button.sizeToFit()
        button.needsDisplay = true
        button.prefType = key
        return button
    }
    
    @objc func sequenceChange(_ button: SequenceButton) {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let keyHandler = delegate.keyHandler
        recordingButton = button

        button.setRecording()

        keyHandler.recordSequence { (sequence) in
            let nums: [NSNumber] = sequence.map({ (i) -> NSNumber in
                return NSNumber(value: i)
            })
            button.setNormal()

            let prefType = button.prefType!
            PreferencesStore.shared.saveValue(nums, forKey: prefType)
            button.title = self.sequenceToString(sequence)
            button.sizeToFit()
            self.recordingButton = nil
        }
    }
    
    func paneWillDisappear() {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        let keyHandler = delegate.keyHandler
        keyHandler.stopRecording()
        
        guard let button = recordingButton else {
            return
        }
        button.setNormal()
    }
    
    @objc func setCycleShift(_ checkbox: NSButton) {
        let isOn = checkbox.state == .on
        PreferencesStore.shared.saveValue(isOn, forKey: .cycleBackwardsWithShift)
    }
    
    func getReverseCell() -> NSView {
        let button = getButton(reverseSequenceButton, .reverseSequence)
        let checkbox = NSButton(checkboxWithTitle: "Enable ⌘ + ⇧ when activated.", target: self, action: #selector(setCycleShift))
        checkbox.state = PreferencesStore.shared.getValue(.cycleBackwardsWithShift) ? .on : .off
        button.setFrameY(button.frame.height - 10)
        checkbox.setFrameX(5)
        
        let wrapper = ResizingView()
        wrapper.addSubview(button)
        wrapper.addSubview(checkbox)
        return wrapper
    }
    
    override func viewDidLoad() {
        preferenceTable.addSubview(PreferencesCell(
            label: "Cycle Forwards",
            tooltip: "Key sequence used to activate and cycle forwards.",
            control: getButton(mainSequenceButton, .mainSequence),
            textOffset: 7
        ))
        preferenceTable.addSubview(PreferencesCell(
            label: "Cycle Backwards",
            tooltip: "Key sequence used to activate and cycle backwards.",
            control: getReverseCell(),
            textOffset: 7
        ))
    }
}
