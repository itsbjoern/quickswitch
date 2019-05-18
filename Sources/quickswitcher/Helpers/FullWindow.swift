//
//  FullWindow.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 30/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class FullWindow: NSObject {
    let kcgWindow: KCGWindow
    let axWindow: AXUIElement?
    let app: NSRunningApplication
    var isHidden = false
    var isClosed = false
    var screenshot: CGImage? = nil
    
    init(kcgWindow: KCGWindow, axWindow: AXUIElement?, app: NSRunningApplication) {
        self.kcgWindow = kcgWindow
        self.axWindow = axWindow
        self.app = app
        
        super.init()
    }
}
