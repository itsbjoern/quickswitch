//
//  main.swift
//  quickswitcher
//K
//  Created by Björn Friedrichs on 26/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

autoreleasepool {
  let app = NSApplication.shared
  let delegate = AppDelegate()
  app.delegate = delegate
  app.run()
}
