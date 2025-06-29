//
//  PreferenceController.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 28/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class PreferenceController: NSPreferenceController {
    var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))

    init() {
        super.init(panes: [
            StyleViewController(),
            ConfigViewController(),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func preferenceWindowWillShow(withPane pane: PreferencePane) {
        let state = ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
        TransformProcessType(&self.psn, state)
        self.window!.makeKeyAndOrderFront(nil)
        self.window!.orderFrontRegardless()
    }

    override func preferenceWindowWillClose(withPane pane: PreferencePane) {
        let state = ProcessApplicationTransformState(kProcessTransformToUIElementApplication)
        TransformProcessType(&self.psn, state)
    }
}
