//
//  NSView.swift
//  vechseler
//
//  Created by Björn Friedrichs on 30/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class Shadow: NSObject {
  var opacity: Float
  var color: CGColor
  var offset: CGSize
  var radius: CGFloat

  init(
    _ opacity: Float = 1.0, _ color: CGColor = .black, _ offset: CGSize = NSMakeSize(0, 0),
    _ radius: CGFloat = 5.0
  ) {
    self.opacity = opacity
    self.color = color
    self.offset = offset
    self.radius = radius
  }
}

extension NSView {
  func addShadow(opacity: Float, color: CGColor, offset: CGSize, radius: CGFloat) {
    self.addShadow(Shadow(opacity, color, offset, radius))
  }

  func addShadow(_ shadow: Shadow) {
    self.shadow = NSShadow()
    self.shadow?.shadowOffset = shadow.offset
    self.shadow?.shadowColor = NSColor(cgColor: shadow.color)?.withAlphaComponent(
      CGFloat(shadow.opacity))
    self.shadow?.shadowBlurRadius = shadow.radius
  }
}
