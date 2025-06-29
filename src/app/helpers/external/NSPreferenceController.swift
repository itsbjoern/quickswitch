//
//  NSPreferenceController.swift
//
//  Created by Björn Friedrichs on 04/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

protocol PreferencePane: NSViewController {
    /// This title will be displayed in the tab switcher control.
    var preferenceTabTitle: String { get }
    /// Triggered right before the pane change animation (old pane is still visible).
    func paneWillAppear(inWindowController windowController: NSPreferenceController)
    /// Triggered right before the pane change animation (pane is still visible).
    func paneWillDisappear()
    /// Triggered once animation is complete and pane is visible.
    func paneDidAppear(inWindowController windowController: NSPreferenceController)
    /// Triggered once animation is complete and pane is not longer visible.
    func paneDidDisappear()
}

extension PreferencePane {
    func paneWillAppear(inWindowController windowController: NSPreferenceController) {}
    func paneWillDisappear() {}
    func paneDidAppear(inWindowController windowController: NSPreferenceController) {}
    func paneDidDisappear() {}
}

protocol PreferenceWindowDelegate {
    func preferenceWindowWillShow(withPane pane: PreferencePane)
    func preferenceWindowWillClose(withPane pane: PreferencePane)
}

class NSPreferenceController: NSWindowController, NSWindowDelegate, NSToolbarDelegate,
    PreferenceWindowDelegate
{
    fileprivate let panes: [PreferencePane]
    fileprivate let paneSizes: [NSSize]
    fileprivate var control: NSSegmentedControl?

    fileprivate var isAnimating = false
    fileprivate var _index = 0
    var index: Int {
        return _index
    }

    init(panes: [PreferencePane]) {
        self.panes = panes
        self.paneSizes = panes.map({ (pane) -> NSSize in
            pane.view.frame.size
        })

        let size = self.paneSizes[0]
        let origin = NSMakePoint(
            NSScreen.main!.frame.width / 2 - size.width / 2,
            NSScreen.main!.frame.height / 2 - size.height / 2
        )

        let window = NSWindow(
            contentRect: NSRect(origin: origin, size: size),
            styleMask: [.closable, .miniaturizable, .titled], backing: .buffered, defer: false)

        super.init(window: window)
        window.windowController = self
        window.delegate = self
        window.titleVisibility = .hidden
        window.toolbar = NSToolbar(identifier: "mainToolbar")
        window.toolbar!.delegate = self
        window.toolbar!.centeredItemIdentifier = NSToolbarItem.Identifier(rawValue: "mainItem")
        window.toolbar!.insertItem(
            withItemIdentifier: window.toolbar!.centeredItemIdentifier!, at: 0)

        self.contentViewController = self.panes[index]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override func showWindow(_ sender: Any?) {
        self.preferenceWindowWillShow(withPane: panes[index])
        self.panes[index].paneWillAppear(inWindowController: self)
        NSApp.activate(ignoringOtherApps: true)
        super.showWindow(sender)
        self.panes[index].paneDidAppear(inWindowController: self)
    }

    internal func windowWillClose(_ notification: Notification) {
        self.panes[index].paneWillDisappear()
        self.preferenceWindowWillClose(withPane: panes[index])
        self.panes[index].paneDidDisappear()
    }

    func preferenceWindowWillShow(withPane pane: PreferencePane) {}
    func preferenceWindowWillClose(withPane pane: PreferencePane) {}

    /// Set the current tab to the specified index.
    func setTab(index: Int, animated: Bool = true) {
        guard index < self.panes.count else {
            return
        }

        if !animated {
            let oldController = self.panes[_index]
            let newController = self.panes[index]

            oldController.paneWillDisappear()
            newController.paneWillAppear(inWindowController: self)

            let newFrame = getWindowRect(comparedTo: index)
            window!.setFrame(newFrame, display: true)

            control!.selectSegment(withTag: index)
            contentViewController = newController
            _index = index

            oldController.paneDidDisappear()
            newController.paneDidAppear(inWindowController: self)
        } else if !isAnimating {
            self.control!.selectSegment(withTag: index)
            self.changeTab(self.control!)
        }
    }

    internal func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        return [toolbar.centeredItemIdentifier!]
    }

    internal func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier]
    {
        return [toolbar.centeredItemIdentifier!]
    }

    internal func toolbar(
        _ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier,
        willBeInsertedIntoToolbar flag: Bool
    ) -> NSToolbarItem? {
        if itemIdentifier == toolbar.centeredItemIdentifier {
            let labels = self.panes.map({ (pane) -> String in
                return pane.preferenceTabTitle
            })

            let item = NSToolbarItem(itemIdentifier: itemIdentifier)
            let control = NSSegmentedControl(
                labels: labels, trackingMode: .selectOne, target: self,
                action: #selector(self.changeTab))
            control.selectSegment(withTag: index)
            item.view = control

            self.control = control
            return item
        }
        return nil
    }

    internal func getWindowRect(comparedTo otherIndex: Int) -> NSRect {
        let oldContentSize = self.paneSizes[otherIndex]
        let newContentSize = self.paneSizes[index]

        let frameSize = self.window!.frame.size
        let titleSize = NSMakeSize(
            frameSize.width - oldContentSize.width,
            frameSize.height - oldContentSize.height)
        let newFrameSize = NSMakeSize(
            titleSize.width + newContentSize.width,
            titleSize.height + newContentSize.height)
        let origin = NSMakePoint(
            self.window!.frame.origin.x,
            self.window!.frame.origin.y + oldContentSize.height - newContentSize.height
        )

        return NSRect(origin: origin, size: newFrameSize)
    }

    @objc internal func changeTab(_ control: NSSegmentedControl) {
        if index == control.indexOfSelectedItem {
            return
        }
        if isAnimating {
            control.selectSegment(withTag: index)
            return
        }
        let oldIndex = index
        self._index = control.indexOfSelectedItem
        isAnimating = true

        let oldController = self.panes[oldIndex]
        let newController = self.panes[index]

        oldController.paneWillDisappear()
        newController.paneWillAppear(inWindowController: self)

        NSAnimationContext.runAnimationGroup(
            { _ in
                NSAnimationContext.current.duration = 0.5
                window!.contentView = nil

                let newRect = getWindowRect(comparedTo: oldIndex)
                self.window!.animator().setFrame(newRect, display: true, animate: true)
            },
            completionHandler: {
                self._index = control.indexOfSelectedItem
                self.contentViewController = newController
                oldController.paneDidDisappear()
                newController.paneDidAppear(inWindowController: self)
                self.isAnimating = false
            })
    }
}
