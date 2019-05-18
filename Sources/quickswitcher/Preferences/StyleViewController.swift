//
//  StyleViewController
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class StyleViewController : NSViewController, PreferencePane {
    var preferenceTabTitle = "Style"
    let preferenceTable = PreferenceTable()

    let defaults = UserDefaults.standard
    
    class FlippedView: NSView {
        override var isFlipped: Bool {
            get {
                return true
            }
        }
    }
    
    override func loadView() {
        let view = FlippedView(frame: NSMakeRect(0, 0, 400, 300))
        view.addSubview(preferenceTable)
        preferenceTable.setFrameSize(view.frame.size)
        self.view = view
    }
    
    @objc func didChangeStyle(_ sender: NSPopUpButton) {
        let index = sender.indexOfSelectedItem
        PreferencesStore.shared.saveValue(index, forKey: .backgroundStyle)
    }
    
    func getStyleCell() -> NSView {
        let styleIndex: Int = PreferencesStore.shared.getValue(.backgroundStyle)
        let styleChoice = NSPopUpButton(frame: NSMakeRect(0, 0, 150, 32), pullsDown: false)
        styleChoice.target = self
        styleChoice.action = #selector(self.didChangeStyle)
        styleChoice.addItems(withTitles: PreferencesDefaults.Materials.map({ (e) -> String in
            return e.label
        }))
        styleChoice.selectItem(at: styleIndex)
        self.view.addSubview(styleChoice)
        return styleChoice
    }
    
    func getShowPreviews() -> NSView {
        let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(setShowPreviews))
        checkbox.state = PreferencesStore.shared.getValue(.showPreviews) ? .on : .off
        return checkbox
    }
    
    @objc func setShowPreviews(_ checkbox: NSButton) {
        let isOn = checkbox.state == .on
        PreferencesStore.shared.saveValue(isOn, forKey: .showPreviews)
    }
    
    func getShowCloseButton() -> NSView {
        let checkbox = NSButton(checkboxWithTitle: "", target: self, action: #selector(setShowCloseButton))
        checkbox.state = PreferencesStore.shared.getValue(.showCloseButton) ? .on : .off
        return checkbox
    }
    
    @objc func setShowCloseButton(_ checkbox: NSButton) {
        let isOn = checkbox.state == .on
        PreferencesStore.shared.saveValue(isOn, forKey: .showCloseButton)
    }
    
    override func viewDidLoad() {
        preferenceTable.addSubview(PreferencesCell(
            label: "Background Style",
            tooltip: "The switcher background style. Default is the same as the Light or Dark setting but depends on the system default.",
            control: self.getStyleCell(),
            textOffset: 7
        ))
        preferenceTable.addSubview(PreferencesCell(
            label: "Show Previews",
            tooltip: "Show screenshots of windows as a preview.",
            control: self.getShowPreviews()
        ))
        preferenceTable.addSubview(PreferencesCell(
            label: "Show Close Button",
            tooltip: "When hovering a cell, display a close button.",
            control: self.getShowCloseButton()
        ))
    }
}
