//
//  AXUIElement.swift
//  vechseler
//
//  Created by Björn Friedrichs on 30/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

// https://gist.github.com/tylerlong/b5cee1d57920e705fa2df0b3f0990b48

import Cocoa

extension AXValue {
    class func initWith(_ t: Any) -> AXValue? {
        var t = t
        switch t {
        case is CGPoint:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &t)!
        case is CGSize:
            return AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &t)!
        default:
            return nil
        }
    }

    func convertTo<T>() -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: 1)
        AXValueGetValue(self, AXValueGetType(self), ptr)
        let val = ptr.pointee
        ptr.deallocate()
        return val
    }
}

extension AXUIElement {
    func getAttribute<T>(_ key: String) -> T? {
        var ptr: AnyObject?
        AXUIElementCopyAttributeValue(self, "AX\(key)" as CFString, &ptr)
        if key == "Size" || key == "Position" {
            let val = ptr as! AXValue
            return val.convertTo()
        }

        return ptr as? T
    }

    func printAttributes() {
        var attributes: CFArray?
        AXUIElementCopyAttributeNames(self, &attributes)
        if let attrs = attributes as? [String] {
            for attr in attrs {
                print("AXUIElement attribute: \(attr)")
            }
        } else {
            print("No attributes found.")
        }
    }

    func setAttribute<T: AnyObject>(_ key: String, value: T) {
        AXUIElementSetAttributeValue(self, "AX\(key)" as CFString, value)
    }

    func setBounds(_ bounds: NSRect) {
        setAttribute("Position", value: AXValue.initWith(bounds.origin)!)
        setAttribute("Size", value: AXValue.initWith(bounds.size)!)
    }
}
