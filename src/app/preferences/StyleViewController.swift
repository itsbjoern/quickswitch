//
//  StyleViewController
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class StyleViewController: NSViewController, PreferencePane {
  var preferenceTabTitle = "Style"
  let preferenceTable = PreferenceTable()

  let defaults = UserDefaults.standard

  let sliderLabel = NSLabel(text: "00000")

  class FlippedView: NSView {
    override var isFlipped: Bool {
      return true
    }
  }

  override func loadView() {
    let view = FlippedView(frame: NSMakeRect(0, 0, 400, 150))
    view.addSubview(preferenceTable)
    preferenceTable.setFrameSize(view.frame.size)
    self.view = view
  }

  func getSizeSlider() -> NSView {
    let previewSize: Int = PreferenceStore.shared.previewSize
    let view = ResizingView()
    let slider = NSSlider(
      value: Double(previewSize), minValue: 80, maxValue: 150, target: self,
      action: #selector(self.changeSliderValue))
    slider.numberOfTickMarks = 8
    slider.allowsTickMarkValuesOnly = true

    sliderLabel.stringValue = "\(previewSize)px"
    sliderLabel.setFrameX(slider.frame.width + 5)
    sliderLabel.setFrameY(3)

    view.addSubview(slider)
    view.addSubview(sliderLabel)
    return view
  }

  @objc func changeSliderValue(_ slider: NSSlider) {
    sliderLabel.stringValue = "\(slider.integerValue)px"
    PreferenceStore.shared.previewSize = slider.integerValue
  }

  override func viewDidLoad() {
    preferenceTable.addSubview(
      PreferencesCell(
        label: "Preview Size",
        tooltip: "Adjust preview size.",
        control: self.getSizeSlider()
      ))
  }
}
