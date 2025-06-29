// //
// //  SwitcherViewController.swift
// //  quickswitcher
// //
// //  Created by Björn Friedrichs on 27/04/2019.
// //  Copyright © 2019 Björn Friedrichs. All rights reserved.
// //

// import Cocoa

// class SelectionView: NSView {
//   override func updateLayer() {
//     super.updateLayer()
//     self.layer!.backgroundColor = NSColor.textColor.withAlphaComponent(0.1).cgColor
//   }
// }

// class PreviewViewController: NSViewController {
//   let window: PreviewWindow

//   let mainPadding: CGFloat = 10
//   let cellPadding: CGFloat = 10
//   let selectionPadding: CGFloat = 10
//   let cellMargin: CGFloat = 10

//   var mainView: ResizingView?
//   let applicationView = ResizingView(withPadding: 10)
//   let selectionView = SelectionView()
//   var windowList: [QSWindow] = []
//   var selected = 0

//   init(_ window: PreviewWindow) {
//     self.window = window
//     super.init(nibName: nil, bundle: nil)

//     let view = ResizingView()
//     self.view = view
//     self.mainView = view

//     print("PreviewViewController init")
//     let effectView = NSVisualEffectView()
//     view.addSubview(effectView)
//     effectView.material = .underWindowBackground
//     effectView.blendingMode = .behindWindow
//     effectView.state = .active
//     effectView.autoresizingMask = [.width, .height]
//     // effectView.wantsLayer = true
//     // effectView.layer!.backgroundColor = .clear
//     // effectView.layer!.cornerRadius = 16
//     // effectView.layer!.opacity = 0.8

//     view.addSubview(applicationView)
//     let selectionShadow = Shadow(0.4, .black, NSMakeSize(0, -3), 6)
//     selectionView.addShadow(selectionShadow)

//     applicationView.wantsLayer = true
//     applicationView.layer?.masksToBounds = false

//     view.addSubview(selectionView)
//     selectionView.wantsLayer = true
//     selectionView.layer!.cornerRadius = 8

//     NSWorkspace.shared.notificationCenter.addObserver(
//       self, selector: #selector(self.spaceChanged),
//       name: NSWorkspace.activeSpaceDidChangeNotification, object: nil)
//     NSWorkspace.shared.notificationCenter.addObserver(
//       self, selector: #selector(self.hideWindow),
//       name: NSWorkspace.didHideApplicationNotification, object: nil)
//     NSWorkspace.shared.notificationCenter.addObserver(
//       self, selector: #selector(self.unhideWindow),
//       name: NSWorkspace.didUnhideApplicationNotification, object: nil)
//   }

//   override func loadView() {
//     // let view = ResizingView(withPadding: mainPadding)
//     // self.view = view
//     // self.mainView = view

//     // let effectView = NSVisualEffectView(frame: view.bounds)
//     // view.addSubview(effectView)
//     // effectView.material = .underWindowBackground
//     // effectView.blendingMode = .behindWindow
//     // effectView.state = .active
//     // effectView.wantsLayer = true
//     // effectView.layer!.backgroundColor = .clear
//     // effectView.layer!.cornerRadius = 16
//     // effectView.autoresizingMask = [.width, .height]

//     // view.addSubview(applicationView)
//     // let selectionShadow = Shadow(0.4, .black, NSMakeSize(0, -3), 6)
//     // selectionView.addShadow(selectionShadow)

//     // applicationView.wantsLayer = true
//     // applicationView.layer?.masksToBounds = false

//     // view.addSubview(selectionView)
//     // selectionView.wantsLayer = true
//     // selectionView.layer!.cornerRadius = 8
//   }

//   required init?(coder: NSCoder) {
//     fatalError("init(coder:) has not been implemented")
//   }

//   @objc func spaceChanged() {
//     self.windowList = []
//     selected = 0
//     self.window.hide(activate: false)
//   }

//   func changeWindowHiddenStatus(_ app: NSRunningApplication, isHidden: Bool) {
//     for win in self.windowList {
//       if win.app.processIdentifier == app.processIdentifier {
//         win.isHidden = isHidden
//       }
//     }
//   }

//   @objc func hideWindow(_ notification: NSNotification) {
//     let running: NSRunningApplication =
//       notification.userInfo![NSWorkspace.applicationUserInfoKey] as! NSRunningApplication
//     changeWindowHiddenStatus(running, isHidden: true)
//   }

//   @objc func unhideWindow(_ notification: NSNotification) {
//     let running: NSRunningApplication =
//       notification.userInfo![NSWorkspace.applicationUserInfoKey] as! NSRunningApplication
//     changeWindowHiddenStatus(running, isHidden: false)
//   }

//   func activateCurrent() {
//     print(windowList.count, selected)
//     let qsWindow = windowList[selected]
//     print("Activating \(qsWindow.cgWindow.windowName ?? qsWindow.app.localizedName!)")

//     qsWindow.focus()

//     if qsWindow.isClosed {
//       NSWorkspace.shared.launchApplication(
//         withBundleIdentifier: qsWindow.app.bundleIdentifier!, options: .default,
//         additionalEventParamDescriptor: nil, launchIdentifier: nil)
//     }

//     qsWindow.isClosed = false
//     qsWindow.isHidden = false

//     windowList.remove(at: selected)
//     windowList.insert(qsWindow, at: 0)
//   }

//   func mouseSelection(_ point: CGPoint) {
//     let mouseSelection: Bool = PreferenceStore.shared.enableMouseSelection

//     for (i, view) in self.applicationView.subviews.enumerated() {
//       let padded = view.frame
//         .insetBy(dx: -selectionPadding, dy: -selectionPadding * 2)
//         .offsetBy(dx: selectionPadding, dy: selectionPadding - 10)
//       if padded.contains(point) {
//         if mouseSelection {
//           self.moveSelection(toIndex: i)
//         }
//         break
//       }
//     }
//   }

//   func moveSelection(by offset: Int) {
//     moveSelection(toIndex: selected + offset)
//   }

//   func moveSelection(toIndex index: Int) {
//     let count = applicationView.subviews.count
//     if count == 0 {
//       return
//     }
//     selected = (index % count + count) % count
//     let subview = applicationView.subviews[selected]

//     let newSize = NSMakeSize(
//       subview.frame.size.width + selectionPadding * 2,
//       subview.frame.size.height + selectionPadding * 2)

//     let newOrigin = NSMakePoint(
//       subview.frame.origin.x - selectionPadding + mainPadding,
//       subview.frame.origin.y - selectionPadding + mainPadding)

//     selectionView.setFrameSize(newSize)
//     selectionView.setFrameOrigin(newOrigin)
//   }

//   func reloadApplications() {
//     let applications = NSWorkspace.shared.runningApplications

//     let orderedWindowsList = CGWindowListCopyWindowInfo(
//       [.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID)
//     let orderedWindowInfo = CGWindow.createArrayFromList(orderedWindowsList)
//     print(orderedWindowInfo.count, "windows found")

//     var appPIDMap: [Int32: (NSRunningApplication, [AXUIElement])] = [:]
//     for app in applications {
//       if app.activationPolicy != .regular { continue }

//       let axApp = AXUIElementCreateApplication(app.processIdentifier)
//       let windowPtr = UnsafeMutablePointer<AnyObject?>.allocate(capacity: 1)
//       AXUIElementCopyAttributeValue(axApp, kAXWindowsAttribute as CFString, windowPtr)
//       let axWindowList = windowPtr.pointee as? [AXUIElement] ?? []
//       windowPtr.deallocate()
//       appPIDMap[app.processIdentifier] = (app, axWindowList)
//     }

//     let filteredWindowInfo = orderedWindowInfo.filter { (window) -> Bool in
//       guard appPIDMap[window.processIdentifier] != nil else {
//         return false
//       }

//       // filter the garbage
//       if window.bounds.width < 23 || window.bounds.height < 23 {
//         return false
//       }

//       if window.windowName == "" {
//         return false
//       }

//       return true
//     }

//     var newWindowList = filteredWindowInfo.map { (window) -> QSWindow in
//       let axWindowList = appPIDMap[window.processIdentifier]!.1
//       var foundIndex: Int? = axWindowList.firstIndex(where: { axWindow in
//         let windowId = getWindowId(axWindow)
//         return windowId == window.windowNumber
//       })

//       var axWindowMatch: AXUIElement? = nil
//       if foundIndex != nil {
//         axWindowMatch = axWindowList[foundIndex!]
//         appPIDMap[window.processIdentifier]!.1.remove(at: foundIndex!)
//       }

//       let app = appPIDMap[window.processIdentifier]!.0
//       return QSWindow(cgWindow: window, axWindow: axWindowMatch, app: app)
//     }

//     for (i, window) in windowList.enumerated() {
//       if window.app.processIdentifier == ProcessInfo.processInfo.processIdentifier {
//         continue
//       }

//       var stillExists = false
//       var appHasAnotherWindow = false
//       for newWindow in newWindowList {
//         if window.cgWindow.windowNumber == newWindow.cgWindow.windowNumber {
//           stillExists = true
//           break
//         }
//         if window.app.processIdentifier == newWindow.app.processIdentifier {
//           appHasAnotherWindow = true
//         }
//       }

//       if stillExists || window.app.isTerminated {
//         continue
//       }

//       if appHasAnotherWindow {
//         continue
//       }

//       window.isClosed = true
//       if i < newWindowList.count {
//         newWindowList.insert(window, at: i == 0 ? 1 : i)
//       } else {
//         newWindowList.append(window)
//       }
//     }

//     windowList = newWindowList
//     updateRender()
//   }

//   func updateRender() {
//     for subview in applicationView.subviews {
//       subview.removeFromSuperview()
//     }

//     let screenWidth = NSScreen.main!.frame.width
//     var xOffset: CGFloat = mainPadding
//     let cellWidth: CGFloat = CGFloat.init(PreferenceStore.shared.previewSize)
//     let breakAfter = Int((screenWidth - 500) / cellWidth)
//     for (index, qsWindow) in windowList.enumerated() {
//       if index % breakAfter == 0 {
//         xOffset = mainPadding
//       }

//       let row = index / breakAfter
//       let maxRow = (windowList.count - 1) / breakAfter
//       let yOffset = CGFloat(maxRow - row) * (cellWidth + cellMargin * 2) + cellMargin  // appPreview.frame.height
//       let offset = NSMakePoint(xOffset, yOffset)
//       let appPreview = NSView(
//         frame: NSRect(origin: offset, size: NSMakeSize(cellWidth, cellWidth)))
//       appPreview.wantsLayer = true
//       appPreview.layer?.masksToBounds = false

//       let nameLabel = NSLabel(
//         text: (qsWindow.title())
//       )
//       nameLabel.preferredMaxLayoutWidth = cellWidth
//       nameLabel.lineBreakMode = .byTruncatingTail
//       nameLabel.font = .systemFont(ofSize: 12, weight: .bold)
//       nameLabel.alignment = .center
//       nameLabel.setFrameSize(NSMakeSize(cellWidth, nameLabel.frame.height))
//       nameLabel.setFrameOrigin(NSMakePoint(0, 3))
//       appPreview.addSubview(nameLabel)
//       //
//       //            let appLabel = NSLabel(text: qsWindow.app.localizedName!)
//       //            appLabel.preferredMaxLayoutWidth = cellWidth
//       //            appLabel.lineBreakMode = .byTruncatingTail
//       //            appLabel.font = .systemFont(ofSize: 9, weight: .ultraLight)
//       //            appLabel.setFrameOrigin(NSMakePoint(5, nameLabel.frame.height - 5))
//       //            appLabel.textColor = .gray
//       //            appPreview.addSubview(appLabel)

//       let imageView = NSImageView(
//         frame: NSMakeRect(
//           0,
//           nameLabel.frame.height + 15,
//           cellWidth,
//           cellWidth * 10 / 16)
//       )
//       if qsWindow.isHidden {
//         imageView.alphaValue = 0.4
//       }

//       appPreview.addSubview(imageView)

//       imageView.image = qsWindow.app.icon!
//       imageView.image!.size = NSMakeSize(75, 75)

//       if qsWindow.isClosed {
//         appPreview.alphaValue = 0.6
//       }
//       let shadow = Shadow(0.5, .black, NSMakeSize(0, -3), 7)
//       imageView.addShadow(shadow)

//       applicationView.addSubview(appPreview)
//       xOffset += appPreview.frame.width + cellMargin + selectionPadding * 2
//     }

//     self.moveSelection(toIndex: 0)
//     mainView!.resize(exclude: selectionView)
//     let x = NSScreen.main!.frame.width / 2 - mainView!.frame.width / 2
//     let y = NSScreen.main!.frame.height / 2 - mainView!.frame.height / 2

//     let newFrame = CGRect(origin: NSMakePoint(x, y), size: mainView!.frame.size)
//     self.window.resize(newFrame)
//   }
// }
