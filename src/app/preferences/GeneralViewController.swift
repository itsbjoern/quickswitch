//
//  StyleViewController
//  quickswitcher
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

class GeneralViewController: NSViewController, PreferencePane {
  var preferenceTabTitle = "General"
  let preferenceTable = PreferenceTable()

  let defaults = UserDefaults.standard

  let sliderLabel = NSLabel(text: "00000")
  let resetPreviewButton = SequenceButton(
    title: "", target: self, action: #selector(resetPreview))

  class FlippedView: NSView {
    override var isFlipped: Bool {
      return true
    }
  }

  override func loadView() {
    let view = FlippedView(frame: NSMakeRect(0, 0, 400, 250))
    view.addSubview(preferenceTable)
    preferenceTable.setFrameSize(view.frame.size)

    self.view = view
  }

  func getSizeSlider() -> NSView {
    let iconSize: Int = PreferenceStore.shared.iconSize
    let view = ResizingView()
    let slider = NSSlider(
      value: Double(iconSize), minValue: 80, maxValue: 150, target: self,
      action: #selector(self.changeSliderValue))
    slider.numberOfTickMarks = 8
    slider.allowsTickMarkValuesOnly = true

    sliderLabel.stringValue = "\(iconSize)px"
    sliderLabel.setFrameX(slider.frame.width + 5)
    sliderLabel.setFrameY(9)

    view.addSubview(slider)
    view.addSubview(sliderLabel)
    return view
  }

  @objc func changeSliderValue(_ slider: NSSlider) {
    sliderLabel.stringValue = "\(slider.integerValue)px"
    PreferenceStore.shared.iconSize = slider.integerValue
  }

  func getPreviewResetButton() -> NSView {
    resetPreviewButton.title = "Reset"
    resetPreviewButton.sizeToFit()
    resetPreviewButton.needsDisplay = true
    resetPreviewButton.setFrameX(-5)

    return resetPreviewButton
  }

  @objc func resetPreview(_ button: SequenceButton) {
    PreferenceStore.shared.previewY = 0
  }

  override func viewDidLoad() {
    preferenceTable.addSubview(
      PreferencesCell(
        label:
          "Quick Switch is in active development, there may be bugs or possible instability. Please report any issues you find on GitHub."
      ))

    let githubLabel = NSLabel(text: "View on GitHub")
    githubLabel.isSelectable = true
    githubLabel.isEditable = false
    githubLabel.isBezeled = false
    githubLabel.drawsBackground = false
    githubLabel.textColor = NSColor.linkColor
    githubLabel.font = NSFont.systemFont(ofSize: 12, weight: .regular)
    githubLabel.allowsEditingTextAttributes = true

    let url = "https://github.com/itsbjoern/quickswitch"
    let attributedString = NSMutableAttributedString(string: "View on GitHub")
    attributedString.beginEditing()
    attributedString.addAttribute(
      .link, value: url, range: NSRange(location: 0, length: attributedString.length))
    attributedString.endEditing()
    githubLabel.attributedStringValue = attributedString

    preferenceTable.addSubview(
      PreferencesCell(
        labelView: githubLabel,
      ))

    preferenceTable.addSubview(
      PreferencesSeperator(text: "Preview Settings"))

    preferenceTable.addSubview(
      PreferencesCell(
        label: "Icon Size",
        tooltip: "Adjust icon size.",
        control: self.getSizeSlider()
      ))
    preferenceTable.addSubview(
      PreferencesCell(
        label: "Reset Preview Position",
        tooltip: "Reset the preview position.",
        control: getPreviewResetButton(),
        textOffset: 7
      ))
  }
}
