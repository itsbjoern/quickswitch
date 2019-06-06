//
//  SwitcherWindow.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class SwitcherWindow: NSWindow {
    var controller: SwitcherViewController?
    var trackingArea: NSTrackingArea?
    
    convenience init() {
        self.init(contentRect: NSMakeRect(0, 0, 0, 0), styleMask: .borderless, backing: .buffered, defer: false)
    }
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: false)
        
        self.controller = SwitcherViewController(self)
        let content = self.contentView! as NSView
        let view = controller!.view
        content.addSubview(view)
        self.makeKeyAndOrderFront(nil)
        self.backgroundColor = NSColor.clear
        self.setIsVisible(false)
        self.collectionBehavior = .moveToActiveSpace
        
        trackingArea = NSTrackingArea.init(rect: getTrackingArea(), options: [.activeAlways, .mouseMoved], owner: self, userInfo: nil)
        content.addTrackingArea(trackingArea!)
    }
    
    func resize(_ newFrame: NSRect) {
        self.setFrame(newFrame, display: true)
        self.contentView?.removeTrackingArea(trackingArea!)
        trackingArea = NSTrackingArea.init(rect: getTrackingArea(), options: [.activeAlways, .mouseMoved, .mouseEnteredAndExited], owner: self, userInfo: nil)
        self.contentView?.addTrackingArea(trackingArea!)
    }
    
    func getTrackingArea() -> CGRect {
        return self.contentView!.bounds.applying(.init(translationX: 10, y: 10))
    }
    
    override func mouseExited(with event: NSEvent) {
        controller!.mouseSelection(.zero)
    }
    
    override func mouseMoved(with event: NSEvent) {
        controller!.mouseSelection(event.locationInWindow)
    }
    
    func cycleForwards() {
        controller!.moveSelection(by: 1)
    }
    
    func cycleBackwards() {
        controller!.moveSelection(by: -1)
    }
    
    func hide(activate: Bool = true) {
        self.setIsVisible(false)
        if activate {
            controller!.activateCurrent()
        }
    }
    
    func show() {
        self.controller!.reloadApplications()
        self.setIsVisible(true)
        self.makeKeyAndOrderFront(nil)
        self.orderFrontRegardless()
    }
}
