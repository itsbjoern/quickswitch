//
//  ResizingView.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class ResizingView: NSView {
    var padding: CGFloat = 0
    var adjustWidth = true
    var adjustHeight = true
    
    convenience init() {
        self.init(frame: NSMakeRect(0, 0, 0, 0))
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    init(frame frameRect: NSRect, withPadding padding: CGFloat) {
        super.init(frame: frameRect)
        self.padding = padding
    }
    
    convenience init(withPadding padding: CGFloat) {
        self.init(frame: NSMakeRect(0, 0, 0, 0), withPadding: padding)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        resize()
        let padded = NSMakePoint(subview.frame.origin.x + padding, subview.frame.origin.y + padding)
        subview.setFrameOrigin(padded)
    }
    
    override func willRemoveSubview(_ subview: NSView) {
        super.willRemoveSubview(subview)
        resize(exclude: subview)
    }
    
    func resize(exclude: NSView? = nil) {
        var size = NSMakeSize(
            adjustWidth ? 0 : self.frame.width,
            adjustHeight ? 0 : self.frame.height)

        for s in self.subviews {
            if s == exclude {
                continue
            }
            
            if adjustWidth {
                size.width = max(size.width, abs(s.frame.origin.x) + s.frame.width)
            }
            if adjustHeight {
                size.height = max(size.height, abs(s.frame.origin.y) + s.frame.height)
            }
        }
        if adjustWidth {
            size.width += padding * 2
        }
        if adjustHeight {
            size.height += padding * 2
        }

        self.setFrameSize(size)
        guard let superview = self.superview else {
            return
        }
        if superview is ResizingView {
            (superview as! ResizingView).resize()
        }
    }
}

class ResizingEffectView: NSVisualEffectView {
    var padding: CGFloat = 0
    var adjustWidth = true
    var adjustHeight = true

    convenience init() {
        self.init(frame: NSMakeRect(0, 0, 0, 0), withPadding: 0)
    }
    
    init(frame frameRect: NSRect, withPadding padding: CGFloat) {
        super.init(frame: frameRect)
        self.padding = padding
    }
    
    convenience init(withPadding padding: CGFloat) {
        self.init(frame: NSMakeRect(0, 0, 0, 0), withPadding: padding)
    }
    
    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didAddSubview(_ subview: NSView) {
        super.didAddSubview(subview)
        resize()
        let padded = NSMakePoint(subview.frame.origin.x + padding, subview.frame.origin.y + padding)
        subview.setFrameOrigin(padded)
    }
    
    override func willRemoveSubview(_ subview: NSView) {
        super.willRemoveSubview(subview)
        resize(exclude: subview)
    }
    
    func resize(exclude: NSView? = nil) {
        var size = NSMakeSize(
            adjustWidth ? 0 : self.frame.width,
            adjustHeight ? 0 : self.frame.height)
        
        for s in self.subviews {
            if s == exclude {
                continue
            }
            
            if adjustWidth {
                size.width = max(size.width, abs(s.frame.minX) + s.frame.width)
            }
            if adjustHeight {
                size.height = max(size.height, abs(s.frame.minY) + s.frame.height)
            }
        }
        if adjustWidth {
            size.width += padding * 2
        }
        if adjustHeight {
            size.height += padding * 2
        }
        
        self.setFrameSize(size)
        guard let superview = self.superview else {
            return
        }
        if superview is ResizingView {
            (superview as! ResizingView).resize()
        }
    }
}
