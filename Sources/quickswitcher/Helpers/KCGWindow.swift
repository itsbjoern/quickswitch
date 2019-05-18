//
//  KCGWindow
//  quickswitcher
//
//  Created by Björn Friedrichs on 30/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Foundation

class KCGWindow: NSObject {
    let ownerName: String
    let processIdentifier: Int32
    let storeType: Int
    let windowLayer: Int
    let windowName: String?
    let windowNumber: Int32
    let sharingState: CGWindowSharingType
    let bounds: NSRect
    let memoryUsage: Int
    let windowAlpha: CGFloat
    
    init(_ data: [String: AnyObject]) {
        let bounds = data["kCGWindowBounds"] as! [String: CGFloat]
        
        self.ownerName = data["kCGWindowOwnerName"] as! String
        self.processIdentifier = data["kCGWindowOwnerPID"] as! Int32
        self.storeType = data["kCGWindowStoreType"] as! Int
        self.windowLayer = data["kCGWindowLayer"] as! Int
        self.windowName = data["kCGWindowName"] as? String
        self.windowNumber = data["kCGWindowNumber"] as! Int32
        self.sharingState = CGWindowSharingType.init(rawValue: data["kCGWindowSharingState"] as! UInt32)!
        self.bounds = NSMakeRect(bounds["X"]!, bounds["Y"]!, bounds["Width"]!, bounds["Height"]!)
        self.memoryUsage = data["kCGWindowMemoryUsage"] as! Int
        self.windowAlpha = data["kCGWindowAlpha"] as! CGFloat
        
        super.init()
    }
    
    static func createArrayFromList(_ windowList: CFArray?) -> [KCGWindow] {
        var result = [KCGWindow]()
        for window in windowList as! [[String: AnyObject]] {
            result.append(KCGWindow(window))
        }
        return result
    }
}
