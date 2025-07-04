//
//  ComboBox.swift
//  vechseler
//
//  Created by Björn Friedrichs on 02/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class ComboBox<T>: NSComboBox, NSComboBoxDelegate, NSComboBoxDataSource {
  typealias Item = (label: String, value: T)

  var registeredHandlers: [(Item) -> Void] = []
  var specialHandlers: [String: [(Item) -> Void]] = [:]

  let items: [Item]

  func keys() -> [String] {
    return self.items.map({ (e) -> String in
      return e.label
    })
  }

  func numberOfItems(in comboBox: NSComboBox) -> Int {
    return self.items.count
  }

  func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
    return self.items[index].label
  }

  func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
    for (i, e) in items.enumerated() {
      if string == e.label {
        return i
      }
    }
    return -1
  }

  init(items: [Item]) {
    self.items = items
    super.init(frame: NSMakeRect(0, 0, 100, 100))

    self.usesDataSource = true
    self.delegate = self
    self.dataSource = self
    self.selectItem(at: 0)

    didInit()
  }

  func didInit() {
    self.sizeToFit()
    self.setFrameSize(NSMakeSize(150, self.frame.height))
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func comboBoxSelectionDidChange(_ notification: Notification) {
    for cb in registeredHandlers {
      cb(items[indexOfSelectedItem])
    }
  }

  func addEventListener(_ cb: @escaping (Item) -> Void) {
    self.registeredHandlers.append(cb)
  }

  func addEventListener(_ cb: @escaping (Item) -> Void, forKey key: String) {
    guard self.keys().contains(key) else {
      print("Key does not exist")
      return
    }
    self.specialHandlers[key, default: []].append(cb)
  }
}
