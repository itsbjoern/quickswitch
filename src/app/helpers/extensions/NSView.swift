//
//  NSView.swift
//  vechseler
//
//  Created by Björn Friedrichs on 02/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

extension NSView {
  func setFrameWidth(_ width: CGFloat) {
    self.setFrameSize(NSMakeSize(width, self.frame.height))
  }

  func setFrameHeight(_ height: CGFloat) {
    self.setFrameSize(NSMakeSize(self.frame.width, height))
  }

  func setFrameX(_ x: CGFloat) {
    self.setFrameOrigin(NSMakePoint(x, self.frame.origin.y))
  }

  func setFrameY(_ y: CGFloat) {
    self.setFrameOrigin(NSMakePoint(self.frame.origin.x, y))
  }
}
