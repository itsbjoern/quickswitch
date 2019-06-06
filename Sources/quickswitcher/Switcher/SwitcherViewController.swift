//
//  SwitcherViewController.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class SelectionView: NSView {
    override func updateLayer() {
        super.updateLayer()
        self.layer!.backgroundColor = NSColor.textColor.withAlphaComponent(0.1).cgColor
    }
}

class SwitcherViewController : NSViewController {
    let window: SwitcherWindow
    var mainView: ResizingEffectView?
    let applicationView = ResizingView()
    let selectionView = SelectionView()
    let closeButton = NSButton(frame: NSMakeRect(0, 0, 12, 12))
    var windowList: [FullWindow] = []
    var selected = 0
    
    let mainPadding: CGFloat = 10
    let cellPadding: CGFloat = 10
    let selectionPadding: CGFloat = 10
    let cellMargin: CGFloat = 10
    
    init(_ window: SwitcherWindow) {
        self.window = window
        super.init(nibName: nil, bundle: nil)
        
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.spaceChanged), name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.hideWindow), name: NSWorkspace.didHideApplicationNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(self.unhideWindow), name: NSWorkspace.didUnhideApplicationNotification, object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func spaceChanged() {
        self.windowList = []
        selected = 0
        self.window.hide(activate: false)
    }
    
    func changeWindowHiddenStatus(_ app: NSRunningApplication, isHidden: Bool) {
        for win in self.windowList {
            if win.app.processIdentifier == app.processIdentifier {
                win.isHidden = isHidden
            }
        }
    }
    
    @objc func hideWindow(_ notification: NSNotification) {
        let running: NSRunningApplication = notification.userInfo![NSWorkspace.applicationUserInfoKey] as! NSRunningApplication
        changeWindowHiddenStatus(running, isHidden: true)
    }
    
    @objc func unhideWindow(_ notification: NSNotification) {
        let running: NSRunningApplication = notification.userInfo![NSWorkspace.applicationUserInfoKey] as! NSRunningApplication
        changeWindowHiddenStatus(running, isHidden: false)
    }
    
    override func loadView() {
        let view = ResizingEffectView(withPadding: mainPadding)
        self.view = view
        self.mainView = view
        view.addSubview(selectionView)
        view.addSubview(applicationView)
        let showClose: Bool = PreferencesStore.shared.getValue(.showCloseButton)
        if showClose {
            view.addSubview(closeButton)
        }
        
        let selectionShadow = Shadow(0.4, .black, NSMakeSize(0, -3), 6)
        selectionView.addShadow(selectionShadow)
        
        applicationView.wantsLayer = true
        applicationView.layer?.masksToBounds = false

        view.material = PreferencesStore.shared.getValue(.backgroundStyle)
        view.blendingMode = .behindWindow
        view.state = .active
        view.wantsLayer = true
        view.layer!.backgroundColor = .clear
        view.layer!.cornerRadius = 16
        
        selectionView.wantsLayer = true
        selectionView.layer!.cornerRadius = 8

        closeButton.isHidden = true
        closeButton.target = self
        closeButton.action = #selector(closeWindow)
        closeButton.title = ""
        closeButton.wantsLayer = true
        closeButton.isBordered = false
        closeButton.bezelStyle = .circular
        closeButton.layer!.cornerRadius = 6
        closeButton.layer!.backgroundColor = CGColor(red: 1, green: 0.349, blue: 0.325, alpha: 1)
    }
    
    func setShowClose(_ show: Bool) {
        let contains = self.view.subviews.contains(closeButton)
        if show {
            if contains {
                return
            }
            self.view.addSubview(closeButton)
           
        } else {
            if !contains {
                return
            }
            closeButton.removeFromSuperview()
        }
    }
    
    @objc func closeWindow() {
        let fullWindow = windowList[selected]
        let axWindow = fullWindow.axWindow

       
        if axWindow != nil {
            AXUIElementPerformAction(axWindow!, kAXRaiseAction as CFString)
            axWindow!.setAttribute("Main", value: true as CFTypeRef)

            let buttonRef = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
            AXUIElementCopyAttributeValue(axWindow!, kAXCloseButtonAttribute as CFString, buttonRef)
            if buttonRef.pointee != nil {
                let button = buttonRef.pointee as! AXUIElement
                AXUIElementPerformAction(button, kAXPressAction as CFString)
            }
            buttonRef.deallocate()
        } else {
            fullWindow.app.activate(options: .activateIgnoringOtherApps)
            fullWindow.app.terminate()
        }
        self.windowList.remove(at: self.selected)
        let savedIndex = self.selected
        self.updateRender()
        self.moveSelection(toIndex: savedIndex == 0 ? 0 : savedIndex - 1)
    }

    func activateCurrent() {
        let fullWindow = windowList[selected]
        let axWindow = fullWindow.axWindow
        if axWindow != nil {
            AXUIElementPerformAction(axWindow!, kAXRaiseAction as CFString)
            axWindow!.setAttribute("Main", value: true as CFTypeRef)
        }
        
        fullWindow.app.activate(options: .activateIgnoringOtherApps)

        if fullWindow.isClosed {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: fullWindow.app.bundleIdentifier!, options: .default, additionalEventParamDescriptor: nil, launchIdentifier: nil)
        }
        
        fullWindow.isClosed = false
        fullWindow.isHidden = false
        
        windowList.remove(at: selected)
        windowList.insert(fullWindow, at: 0)
    }

    func mouseSelection(_ point: CGPoint) {
        let mouseSelection: Bool = PreferencesStore.shared.getValue(.enableMouseSelection)
        let showClose: Bool = PreferencesStore.shared.getValue(.showCloseButton)

        var any = false
        for (i, view) in self.applicationView.subviews.enumerated() {
            let padded = view.frame
                .insetBy(dx: -selectionPadding, dy: -selectionPadding * 2)
                .offsetBy(dx: selectionPadding, dy: selectionPadding - 10)
            if padded.contains(point) {
                if mouseSelection {
                    self.moveSelection(toIndex: i)
                }
                
                if showClose {
                    closeButton.setFrameOrigin(NSMakePoint(
                        padded.origin.x + 8,
                        padded.origin.y + padded.height - closeButton.frame.height - 8))
                    
                    closeButton.isHidden = false
                    if closeButton.frame.contains(point) {
                        let color = NSColor(red: 0.631, green: 0.027, blue: 0.016, alpha: 1)
                        closeButton.attributedTitle = NSAttributedString(string: "x", attributes: [.foregroundColor: color, .baselineOffset: 1])
                    } else {
                        closeButton.title = ""
                    }
                }
                any = true
                break
            }
        }
        if !any {
            closeButton.isHidden = true
        }
    }
    
    func moveSelection(by offset: Int) {
        moveSelection(toIndex: selected + offset)
    }

    func moveSelection(toIndex index: Int) {
        let count = applicationView.subviews.count
        if count == 0 {
            return
        }
        selected = (index % count + count) % count
        let subview = applicationView.subviews[selected]

        let newSize = NSMakeSize(
            subview.frame.size.width + selectionPadding * 2,
            subview.frame.size.height + selectionPadding * 2)

        let newOrigin = NSMakePoint(
            subview.frame.origin.x - selectionPadding + mainPadding,
            subview.frame.origin.y - selectionPadding + mainPadding)

        selectionView.setFrameSize(newSize)
        selectionView.setFrameOrigin(newOrigin)
    }

    func screenshot(_ pids: [Int32]) -> [Int32: CGImage?] {
        let windowInfoList = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID)! as NSArray
        let info = (windowInfoList as NSArray? as? [[String: AnyObject]])!

        var idMap: [Int32: Int32] = [:]
        info.forEach({ entry in
            idMap[entry["kCGWindowOwnerPID"]! as! Int32] = (entry["kCGWindowNumber"]! as! Int32)
        })

        var screenshots: [Int32: CGImage] = [:]
        for pid in pids {
            guard let windowId = idMap[pid] else {
                print("Couldnt retrieve windowid")
                continue
            }
            let screenshot = CGWindowListCreateImage(.null, .optionIncludingWindow, CGWindowID(windowId), [.boundsIgnoreFraming, .nominalResolution])
            if screenshot!.height == 1 {
                screenshots[pid] = nil
            } else {
                screenshots[pid] = screenshot
            }

        }

        return screenshots
    }
    
    func captureWindow(_ windowId: Int32) -> CGImage? {
        let screenshot = CGWindowListCreateImage(.null, .optionIncludingWindow, CGWindowID(windowId), [.boundsIgnoreFraming, .nominalResolution])
        
        return screenshot!.height <= 1 ? nil : screenshot
    }
    
    func reloadApplications() {
        let applications = NSWorkspace.shared.runningApplications
        
        let orderedWindowsList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
        let orderedWindowInfo = KCGWindow.createArrayFromList(orderedWindowsList)

        var appPIDMap: [Int32: (NSRunningApplication, [AXUIElement])] = [:]
        for app in applications {
            if app.activationPolicy != .regular { continue }
            
            let axApp = AXUIElementCreateApplication(app.processIdentifier)
            let windowPtr = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
            AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, windowPtr)
            let axWindowList = windowPtr.pointee as? [AXUIElement] ?? []
            windowPtr.deallocate()
            appPIDMap[app.processIdentifier] = (app, axWindowList)
        }
        
        let filteredWindowInfo = orderedWindowInfo.filter { (window) -> Bool in
            guard let _ = appPIDMap[window.processIdentifier] else {
                return false
            }

            // filter the garbage
            if window.bounds.width < 23 || window.bounds.height < 23 {
                return false
            }
            
            if window.windowName == "" {
                return false
            }
            
            return true
        }
        
        var newWindowList = filteredWindowInfo.map { (window) -> FullWindow in
            let axWindowList = appPIDMap[window.processIdentifier]!.1
            var foundIndex: Int? = nil
            for (i, axWindow) in axWindowList.enumerated() {
                guard let name = window.windowName else { continue }
                
                let title: String = axWindow.getAttribute("Title") ?? ""
                if !title.starts(with: name) {
                    continue
                }
                let point: NSPoint = axWindow.getAttribute("Position") ?? .zero
                if point != window.bounds.origin {
                    continue
                }
                let size: NSSize = axWindow.getAttribute("Size") ?? .zero
                if size != window.bounds.size {
                    continue
                }

                foundIndex = i
                break
            }
            var axWindowMatch: AXUIElement? = nil
            if foundIndex != nil {
                axWindowMatch = axWindowList[foundIndex!]
                appPIDMap[window.processIdentifier]!.1.remove(at: foundIndex!)
            }

            let app = appPIDMap[window.processIdentifier]!.0
            return FullWindow(kcgWindow: window, axWindow: axWindowMatch, app: app)
        }
        
        for (i, window) in windowList.enumerated() {
            if window.app.processIdentifier == ProcessInfo.processInfo.processIdentifier {
                continue
            }
            
            var stillExists = false
            var appHasAnotherWindow = false
            for newWindow in newWindowList {
                if window.kcgWindow.windowNumber == newWindow.kcgWindow.windowNumber {
                    stillExists = true
                    break
                }
                if window.app.processIdentifier == newWindow.app.processIdentifier {
                    appHasAnotherWindow = true
                }
            }
            
            if stillExists || window.app.isTerminated {
                continue
            }
            
            if appHasAnotherWindow {
                continue
            }
            
            window.isClosed = true
            if i < newWindowList.count {
                newWindowList.insert(window, at: i == 0 ? 1 : i)
            } else {
                newWindowList.append(window)
            }
        }
        
        windowList = newWindowList
        updateRender()
    }

    func updateRender() {
        for subview in applicationView.subviews {
            subview.removeFromSuperview()
        }

        let screenWidth = NSScreen.main!.frame.width
        var xOffset: CGFloat = mainPadding
        let cellWidth: CGFloat = PreferencesStore.shared.getValue(.previewSize)
        let breakAfter = Int((screenWidth - 500) / cellWidth)
        for (index, fullWindow) in windowList.enumerated() {
            if index % breakAfter == 0 {
                xOffset = mainPadding
            }

            let row = index / breakAfter
            let maxRow = (windowList.count - 1) / breakAfter
            let yOffset = CGFloat(maxRow - row) * (cellWidth + cellMargin * 2) + cellMargin // appPreview.frame.height
            let offset = NSMakePoint(xOffset, yOffset)
            let appPreview = NSView(frame: NSRect(origin: offset, size: NSMakeSize(cellWidth, cellWidth)))
            appPreview.wantsLayer = true
            appPreview.layer?.masksToBounds = false
            
            let nameLabel = NSLabel(text: fullWindow.kcgWindow.windowName ?? fullWindow.app.localizedName!)
            nameLabel.preferredMaxLayoutWidth = cellWidth
            nameLabel.lineBreakMode = .byTruncatingTail
            nameLabel.font = .systemFont(ofSize: 12, weight: .bold)
            nameLabel.alignment = .center
            nameLabel.setFrameSize(NSMakeSize(cellWidth, nameLabel.frame.height))
            nameLabel.setFrameOrigin(NSMakePoint(0, 3))
            appPreview.addSubview(nameLabel)
//
//            let appLabel = NSLabel(text: fullWindow.app.localizedName!)
//            appLabel.preferredMaxLayoutWidth = cellWidth
//            appLabel.lineBreakMode = .byTruncatingTail
//            appLabel.font = .systemFont(ofSize: 9, weight: .ultraLight)
//            appLabel.setFrameOrigin(NSMakePoint(5, nameLabel.frame.height - 5))
//            appLabel.textColor = .gray
//            appPreview.addSubview(appLabel)
            
            let imageView = NSImageView(frame: NSMakeRect(
                0,
                nameLabel.frame.height + 15,
                cellWidth,
                cellWidth * 10 / 16)
            )
            if fullWindow.isHidden {
                imageView.alphaValue = 0.4
            }
            
            appPreview.addSubview(imageView)

            imageView.image = fullWindow.app.icon!
            imageView.image!.size = NSMakeSize(75, 75)
            
            let showPreviews: Bool = PreferencesStore.shared.getValue(.showPreviews)
            if showPreviews {
                DispatchQueue.main.async {
                    let screenshot = self.captureWindow(fullWindow.kcgWindow.windowNumber) ?? fullWindow.screenshot
                    if screenshot != nil {
                        let imgSize = NSMakeSize(CGFloat(screenshot!.width), CGFloat(screenshot!.height))
                        let ssImage = NSImage(cgImage: screenshot!, size: imgSize)
                        imageView.image = ssImage
                        fullWindow.screenshot = screenshot
    
                        let iconSize: CGFloat = cellWidth * 0.3
                        let iconView = NSImageView(frame: NSMakeRect(
                            cellWidth - iconSize / 2 - 10,
                            appPreview.frame.height - iconSize - 10 * ((cellWidth - 75) / 75),
                            iconSize,
                            iconSize)
                        )
                        iconView.image = fullWindow.app.icon!
                        iconView.image!.size = NSMakeSize(iconSize, iconSize)
                        
                        appPreview.addSubview(iconView)
                        let iconShadow = Shadow(0.6, .black, NSMakeSize(0, -2), 3)
                        iconView.addShadow(iconShadow)
                    }
                }
            }
            if fullWindow.isClosed {
                appPreview.alphaValue = 0.6
            }
            let shadow = Shadow(0.5, .black, NSMakeSize(0, -3), 7)
            imageView.addShadow(shadow)
            
            applicationView.addSubview(appPreview)
            xOffset += appPreview.frame.width + cellMargin + selectionPadding * 2
        }

        self.moveSelection(toIndex: 0)
        self.closeButton.setFrameY(0)
        mainView!.resize(exclude: selectionView)
        let x = NSScreen.main!.frame.width / 2 - mainView!.frame.width / 2
        let y = NSScreen.main!.frame.height / 2 - mainView!.frame.height / 2

        let newFrame = CGRect(origin: NSMakePoint(x, y), size: mainView!.frame.size)
        self.window.resize(newFrame)
    }
}
