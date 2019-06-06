//
//  NSLabel.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//
import Cocoa

class NSLabel: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.textColor = NSColor.controlTextColor
        self.alphaValue = 0.9
        self.maximumNumberOfLines = 1
        self.isBezeled = false
//        self.drawsBackground = false
        self.isEditable = false
        self.isSelectable = false
        self.backgroundColor = .none
    }
    
    convenience init(frame frameRect: NSRect, text: String) {
        self.init(frame: frameRect)
        self.stringValue = text
    }
    
    convenience init(text: String) {
        self.init(frame: NSMakeRect(0, 0, 0, 0))
        self.stringValue = text
        self.sizeToFit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
