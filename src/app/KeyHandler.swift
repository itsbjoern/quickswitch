//
//  KeyHandler.swift
//  quickswitcher
//
//  Created by Björn Friedrichs on 01/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

func tapCallback(
  proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
  guard let ptr = refcon else {
    print("Could not pass delegate pointer")
    exit(0)
  }
  let delegate = Unmanaged<KeyHandler>.fromOpaque(ptr).takeUnretainedValue()
  let evt = delegate.keyHandler(type: type, evt: event)

  if evt == nil {
    return nil
  }

  return Unmanaged.passRetained(event)
}

func invalidation(_ port: CFMachPort?, _ info: UnsafeMutableRawPointer?) {
  print(port, info)
}

class KeyHandler: NSObject {
  typealias Callback = (KeyHandler.Event) -> Bool

  struct Event {
    let flags: CGEventFlags
    let keyCode: Int64
    let sequence: [Int64]

    enum EventType { case main, mainReverse, secondary, secondaryReverse, close, block }
  }
  typealias KeySequence = [Int64]
  enum FlagAsInt: Int64, CaseIterable {
    case command = 57344
    case shift, alt, control, fn, capslock

    static func contains(key: Int64) -> Bool {
      guard let flag = KeyHandler.FlagAsInt(rawValue: key) else {
        return false
      }
      return FlagAsInt.allCases.contains(flag)
    }

    func asString() -> String {
      switch self {
      case .command:
        return "⌘"
      case .control:
        return "^"
      case .alt:
        return "⌥"
      case .shift:
        return "⇧"
      case .capslock:
        return "⇪"
      case .fn:
        return "fn"
      }
    }
  }
  func fromFlag(_ flag: CGEventFlags) -> FlagAsInt? {
    switch flag {
    case .maskCommand:
      return .command
    case .maskShift:
      return .shift
    case .maskControl:
      return .control
    case .maskAlternate:
      return .alt
    case .maskSecondaryFn:
      return .fn
    case .maskAlphaShift:
      return .capslock
    default:
      return nil
    }
  }

  typealias EventTuple = (
    key: KeyHandler.Event.EventType, sequence: KeySequence, cb: KeyHandler.Callback
  )
  var registeredEvents:
    [KeyHandler.Event.EventType: [(sequence: KeySequence, cb: KeyHandler.Callback)]] = [:]

  typealias RecordCallback = ([Int64]) -> Void
  fileprivate var isRecording = false
  fileprivate var recordCallback: RecordCallback?
  fileprivate var recordedSequence = [Int64]()

  override init() {
    super.init()

    let eventMask: CGEventMask =
      (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.keyUp.rawValue)
      | (1 << CGEventType.flagsChanged.rawValue)
    let selfPointer = Unmanaged.passUnretained(self).toOpaque()
    guard
      let eventTap = CGEvent.tapCreate(
        tap: .cgSessionEventTap, place: .headInsertEventTap, options: .defaultTap,
        eventsOfInterest: eventMask, callback: tapCallback, userInfo: selfPointer)
    else {
      print("failed to create event tap")
      exit(1)
    }
    let src = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), src, CFRunLoopMode.commonModes)
    CFMachPortSetInvalidationCallBack(eventTap, invalidation)
  }

  var currSequence = [Int64]()
  var lastSequenceTriggered: [Int64]? = nil

  func checkKey(_ key: Int64, down: Bool) -> EventTuple? {
    let allPairs = registeredEvents.map { (pair) -> [EventTuple] in
      return pair.value.map({ (tuple) -> EventTuple in
        return (pair.key, tuple.sequence, tuple.cb)
      })
    }.flatMap({ $0 })

    if down {
      let nextSequence = currSequence + [key]
      let contains = currSequence.contains(key)
      if !contains || currSequence.last == key {
        if !contains && self.lastSequenceTriggered != nextSequence {
          currSequence = nextSequence
        }

        for pair in allPairs {
          if pair.sequence == currSequence {
            self.lastSequenceTriggered = currSequence
            return pair
          }
        }
      }
    } else {
      self.lastSequenceTriggered = nil
      let ind = currSequence.firstIndex(of: key)
      guard let safeIndex = ind else {
        return nil
      }

      currSequence.removeLast(currSequence.count - safeIndex)
      if currSequence == [] {
        for pair in allPairs {
          if pair.sequence == currSequence {
            return pair
          }
        }
      }
    }
    self.lastSequenceTriggered = nil
    return nil
  }

  func keyHandler(type: CGEventType, evt: CGEvent) -> CGEvent? {
    let keyCode = evt.getIntegerValueField(.keyboardEventKeycode)

    if type == .flagsChanged {
      let checkedFlags: [CGEventFlags] = [
        .maskCommand, .maskShift, .maskAlternate, .maskControl, .maskSecondaryFn,
        .maskAlphaShift,
      ]
      for flag in checkedFlags {
        guard let intVal = fromFlag(flag)?.rawValue else {
          continue
        }
        let down = evt.flags.contains(flag)

        if isRecording {
          let contains = recordedSequence.contains(intVal)
          if down && !contains {
            recordedSequence.append(intVal)
            return nil
          } else if !down && contains {
            let ind = recordedSequence.firstIndex(of: intVal)!
            recordedSequence.remove(at: ind)
            return nil
          }
          continue
        }

        let contains = currSequence.contains(intVal)
        let changed = down && !contains || !down && contains
        if !changed {
          continue
        }
        let evtTuple = checkKey(intVal, down: down)
        let keyEvent = KeyHandler.Event(
          flags: evt.flags, keyCode: keyCode, sequence: currSequence)

        if self.trigger(tuple: evtTuple, keyEvent) {
          return nil
        }
      }
    } else {
      if isRecording {
        if type == .keyDown {
          recordedSequence.append(keyCode)
        } else if type == .keyUp {
          recordCallback!(recordedSequence)
          recordedSequence.removeAll()
          isRecording = false
        }

        return nil
      }

      let evtTuple = checkKey(keyCode, down: type == .keyDown)
      let keyEvent = KeyHandler.Event(
        flags: evt.flags, keyCode: keyCode, sequence: currSequence)

      if self.trigger(tuple: evtTuple, keyEvent) {
        return nil
      }
    }

    evt.setIntegerValueField(.keyboardEventKeycode, value: keyCode)
    return evt
  }

  func trigger(tuple: EventTuple?, _ keyEvent: KeyHandler.Event) -> Bool {
    guard let evtTuple = tuple else {
      return false
    }

    return evtTuple.cb(keyEvent)
  }

  /// Adds the specified event listener. The callbacks return value determines if the event should be captured.
  func addEventListener(
    key: KeyHandler.Event.EventType, sequence: KeySequence, _ cb: @escaping KeyHandler.Callback
  ) {
    self.registeredEvents[key, default: []].append((sequence, cb))
  }

  func removeEventListeners(key: KeyHandler.Event.EventType, sequence: KeySequence? = nil) {
    if sequence != nil {
      self.registeredEvents[key]?.removeAll(where: { (pair) -> Bool in
        return pair.sequence == sequence
      })
    } else {
      self.registeredEvents[key]?.removeAll()
    }
  }

  func recordSequence(_ cb: @escaping ([Int64]) -> Void) {
    isRecording = true
    recordCallback = cb
  }

  func stopRecording() {
    isRecording = false
    recordCallback = nil
    recordedSequence = []
  }
}
