//
//  KeyCodes.swift
//  vechseler
//
//  Created by Björn Friedrichs on 12/05/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

struct KeyCode {
  let key: String
  let code: Int64

  init(_ key: String, _ code: Int64) {
    self.key = key
    self.code = code
  }
}

let KeyCodes: [Int64: KeyCode] = [
  00: KeyCode("A", 00),
  01: KeyCode("S", 01),
  02: KeyCode("D", 02),
  03: KeyCode("F", 03),
  04: KeyCode("H", 04),
  05: KeyCode("G", 05),
  06: KeyCode("Z", 06),
  07: KeyCode("X", 07),
  08: KeyCode("C", 08),
  09: KeyCode("V", 09),
  10: KeyCode("§", 10),
  11: KeyCode("B", 11),
  12: KeyCode("Q", 12),
  13: KeyCode("W", 13),
  14: KeyCode("E", 14),
  15: KeyCode("R", 15),
  16: KeyCode("Y", 16),
  17: KeyCode("T", 17),
  18: KeyCode("1", 18),
  19: KeyCode("2", 19),
  20: KeyCode("3", 20),
  22: KeyCode("6", 22),
  21: KeyCode("4", 21),
  23: KeyCode("5", 23),
  24: KeyCode("=", 24),
  25: KeyCode("9", 25),
  26: KeyCode("7", 26),
  27: KeyCode("-", 27),
  28: KeyCode("8", 28),
  29: KeyCode("0", 29),
  30: KeyCode("]", 30),
  31: KeyCode("O", 31),
  32: KeyCode("U", 32),
  33: KeyCode("[", 33),
  34: KeyCode("I", 34),
  35: KeyCode("P", 35),
  37: KeyCode("L", 37),
  38: KeyCode("J", 38),
  39: KeyCode("'", 39),
  40: KeyCode("K", 40),
  41: KeyCode(";", 41),
  42: KeyCode("\\", 42),
  43: KeyCode(",", 43),
  44: KeyCode("/", 44),
  45: KeyCode("N", 45),
  46: KeyCode("M", 46),
  47: KeyCode(".", 47),
  48: KeyCode("↹", 48),
  50: KeyCode("`", 50),
  51: KeyCode("⌫", 51),
  53: KeyCode("⎋", 53),
  123: KeyCode("←", 123),
  124: KeyCode("→", 124),
  125: KeyCode("↓", 125),
  126: KeyCode("↑", 126),
]
