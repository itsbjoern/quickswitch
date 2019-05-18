//
//  PreferencesCell.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 02/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class PreferenceTable: NSView {
    override var isFlipped: Bool {
        get {
            return true
        }
    }

    var currOffset: CGFloat = 0
    func addSubview(_ view: PreferencesCell<NSView>) {
        super.addSubview(view)
        view.setFrameY(currOffset)
        currOffset += view.frame.height
    }
}

class PreferencesCell<T: NSView>: ResizingView {
    let labelView: NSLabel
    let control: T
    let extraPadding: CGFloat = 10
    let textOffset: CGFloat

    override var isFlipped: Bool {
        get {
            return true
        }
    }
    
    init(label: String, tooltip: String, control: T, textOffset: CGFloat = 0) {
        let width: CGFloat = 500
        self.textOffset = textOffset
        
        labelView = NSLabel(text: "\(label):")
        labelView.font = .labelFont(ofSize: 13)
        labelView.sizeToFit()
        labelView.toolTip = tooltip
        
        self.control = control
        control.setFrameOrigin(NSMakePoint(width / 2, extraPadding))
        
        super.init(frame: NSMakeRect(0, 0, width, 1), withPadding: 0)
        self.adjustWidth = false
        
        labelView.setFrameOrigin(NSMakePoint(
            width / 2 - labelView.frame.width,
            extraPadding + textOffset
        ))
       
        self.addSubview(labelView)
        self.addSubview(control)
    }
    
    override func viewDidMoveToSuperview() {
        guard let superview = self.superview else {
            return
        }
        
        self.setFrameWidth(superview.frame.width)
        control.setFrameOrigin(NSMakePoint(self.frame.width / 2 + 2, extraPadding))
        labelView.setFrameOrigin(NSMakePoint(
            self.frame.width / 2 - labelView.frame.width - 2,
            extraPadding + textOffset
        ))
        
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
