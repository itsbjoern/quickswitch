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
        return true
    }

    var currOffset: CGFloat = 0
    func addSubview(_ view: PreferencesCell<NSView>) {
        super.addSubview(view)
        view.setFrameY(currOffset)
        currOffset += view.frame.height
    }

    override func addSubview(_ view: NSView) {
        super.addSubview(view)
        view.setFrameY(currOffset)
        currOffset += view.frame.height
    }
}

class PreferencesSeperator: NSView {
    let lineLeft = NSView()
    let lineRight = NSView()
    var text: NSLabel?

    init(text: String? = nil) {
        super.init(frame: NSMakeRect(0, 0, 1, 1))
        addSubview(lineLeft)
        addSubview(lineRight)
        let height: CGFloat = 30
        self.setFrameHeight(height)

        lineLeft.setFrameHeight(1)
        lineLeft.setFrameY(height / 2 - 0.5)
        lineLeft.wantsLayer = true
        lineLeft.layer?.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

        lineRight.setFrameHeight(1)
        lineRight.setFrameY(height / 2 - 0.5)
        lineRight.wantsLayer = true
        lineRight.layer?.backgroundColor = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)

        if text != nil {
            self.text = NSLabel(text: text!)
            self.text!.setFrameY(height / 2 - self.text!.frame.height / 2)
            self.text!.textColor! = .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
            addSubview(self.text!)
        }
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        guard let superview = self.superview else {
            return
        }

        self.setFrameWidth(superview.frame.width)
        lineLeft.setFrameX(10)

        if self.text != nil {
            self.text?.setFrameX(self.frame.width / 2 - self.text!.frame.width / 2)
            lineLeft.setFrameWidth(self.text!.frame.minX - 20)
            lineRight.setFrameX(self.text!.frame.maxX + 10)
            lineRight.setFrameWidth(superview.frame.width - self.text!.frame.maxX - 20)
        } else {
            lineLeft.setFrameWidth(superview.frame.width - 20)
        }
    }
}

class PreferencesCell<T: NSView>: ResizingView {
    let labelView: NSLabel
    let control: T
    let extraPadding: CGFloat = 10
    let textOffset: CGFloat

    override var isFlipped: Bool {
        return true
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

        labelView.setFrameOrigin(
            NSMakePoint(
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
        labelView.setFrameOrigin(
            NSMakePoint(
                self.frame.width / 2 - labelView.frame.width - 2,
                extraPadding + textOffset
            ))

    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
