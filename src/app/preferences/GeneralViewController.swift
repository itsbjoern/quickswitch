//
//  GeneralViewController.swift
//  vechseler
//
//  Created by Björn Friedrichs on 27/04/2019.
//  Copyright © 2019 Björn Friedrichs. All rights reserved.
//

import Cocoa

struct PreviewBoxSpec {
  let size: CGFloat
  let label: String
  let color = NSColor.systemBlue
}

class GeneralViewController: NSViewController, PreferencePane {
  var preferenceTabTitle = "General"
  let previewSizes = [
    PreviewBoxSpec(size: 75, label: "Small"), PreviewBoxSpec(size: 100, label: "Medium"),
    PreviewBoxSpec(size: 125, label: "Large"),
  ]

  let sliderLabel = NSLabel(text: "00000")
  let resetPreviewButton = NSButton(
    title: "", target: self, action: #selector(resetPreview))

  class FlippedView: NSView {
    override var isFlipped: Bool { true }
  }

  // Store references to preview boxes for selection highlighting
  var previewBoxes: [NSBox] = []

  override func loadView() {
    self.previewBoxes = []

    // Card-like container for the whole preferences pane
    let mainStack = NSStackView()
    mainStack.orientation = .vertical
    mainStack.spacing = 28
    mainStack.alignment = .leading
    mainStack.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    mainStack.translatesAutoresizingMaskIntoConstraints = false

    // Info label
    let infoLabel = NSLabel(
      text: "Vechsel is in active development. Please report any issues you find on GitHub."
    )
    infoLabel.lineBreakMode = .byWordWrapping
    infoLabel.maximumNumberOfLines = 3
    infoLabel.font = NSFont.systemFont(ofSize: 13, weight: .light)
    infoLabel.textColor = .secondaryLabelColor
    infoLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    infoLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    infoLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

    mainStack.addArrangedSubview(infoLabel)

    // GitHub link
    let githubLabel = NSLabel(text: "View on GitHub")
    githubLabel.isSelectable = true
    githubLabel.isEditable = false
    githubLabel.isBezeled = false
    githubLabel.drawsBackground = false
    githubLabel.textColor = NSColor.linkColor
    githubLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
    githubLabel.allowsEditingTextAttributes = true
    let url = "https://github.com/itsbjoern/vechsel"
    let attributedString = NSMutableAttributedString(string: "View on GitHub")
    attributedString.beginEditing()
    attributedString.addAttribute(
      .link, value: url, range: NSRange(location: 0, length: attributedString.length))
    attributedString.endEditing()
    githubLabel.attributedStringValue = attributedString
    mainStack.addArrangedSubview(githubLabel)

    // Section header with centered label and lines
    mainStack.addArrangedSubview(makeSectionHeader(title: "Icon Size"))

    let sizeStack = NSStackView(
      views: self.previewSizes.map { box in
        makePreviewBox(spec: box)
      })
    sizeStack.orientation = .horizontal
    sizeStack.spacing = 8
    sizeStack.alignment = .top
    sizeStack.distribution = .equalSpacing

    mainStack.addArrangedSubview(sizeStack)

    // Highlight the selected box
    highlightSelectedPreviewBox(selectedSize: PreferenceStore.shared.iconSize)

    mainStack.addArrangedSubview(makeSectionHeader(title: "Switcher Position"))

    let explainerLabel = NSLabel(
      text:
        "You can reset the position of the switcher preview to the top of your screen. This is useful if you have moved it around and want to restore the default position."
    )
    explainerLabel.lineBreakMode = .byWordWrapping
    explainerLabel.maximumNumberOfLines = 0
    explainerLabel.font = NSFont.systemFont(ofSize: 13, weight: .light)
    explainerLabel.textColor = .secondaryLabelColor
    explainerLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
    explainerLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
    explainerLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    mainStack.addArrangedSubview(explainerLabel)

    // Reset preview position
    let resetStack = NSStackView()
    resetStack.orientation = .horizontal
    resetStack.spacing = 12
    resetStack.alignment = .centerY

    let resetLabel = NSLabel(text: "Reset Position")
    resetLabel.font = NSFont.systemFont(ofSize: 13, weight: .medium)
    resetLabel.textColor = .labelColor
    resetStack.addArrangedSubview(resetLabel)
    resetStack.addArrangedSubview(getPreviewResetButton())
    mainStack.addArrangedSubview(resetStack)

    self.view = mainStack

    // Ensure mainStack fills its superview so edgeInsets are respected
    NSLayoutConstraint.activate([
      mainStack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      mainStack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      mainStack.topAnchor.constraint(equalTo: self.view.topAnchor),
      mainStack.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
    ])
  }

  // Preview size boxes
  func makePreviewBox(spec: PreviewBoxSpec) -> NSStackView {
    // Outer wrapper for alignment and background
    let wrapper = NSBox()
    wrapper.boxType = .custom
    wrapper.cornerRadius = 18
    wrapper.fillColor = spec.color.withAlphaComponent(0.09)
    wrapper.translatesAutoresizingMaskIntoConstraints = false
    wrapper.widthAnchor.constraint(equalToConstant: self.previewSizes.last!.size + 30).isActive =
      true
    wrapper.wantsLayer = true
    wrapper.layer?.borderWidth = 1
    wrapper.layer?.borderColor = spec.color.withAlphaComponent(0.18).cgColor
    wrapper.layer?.cornerRadius = 18

    // Animate highlight on selection
    wrapper.animator()
    self.previewBoxes.append(wrapper)

    // Add click gesture
    let clickGesture = NSClickGestureRecognizer(
      target: self, action: #selector(self.previewBoxClicked(_:)))
    wrapper.identifier = NSUserInterfaceItemIdentifier("\(Int(spec.size))")
    wrapper.addGestureRecognizer(clickGesture)

    // Centering stack inside wrapper
    let innerStack = NSStackView()
    innerStack.orientation = .vertical
    innerStack.alignment = .centerX
    innerStack.spacing = 16
    innerStack.edgeInsets = NSEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    innerStack.translatesAutoresizingMaskIntoConstraints = false

    let boxOuter = NSBox()
    boxOuter.boxType = .custom
    boxOuter.fillColor = .clear
    boxOuter.borderColor = .clear
    boxOuter.widthAnchor.constraint(equalToConstant: self.previewSizes.last!.size).isActive = true
    boxOuter.heightAnchor.constraint(equalToConstant: self.previewSizes.last!.size).isActive = true

    // The preview box itself
    let box = NSBox()
    box.boxType = .custom
    box.cornerRadius = 14
    box.fillColor = spec.color.withAlphaComponent(0.18)
    box.borderColor = .clear
    box.translatesAutoresizingMaskIntoConstraints = false

    boxOuter.addSubview(box)
    box.widthAnchor.constraint(equalToConstant: spec.size).isActive = true
    box.heightAnchor.constraint(equalToConstant: spec.size).isActive = true
    box.centerXAnchor.constraint(
      equalTo: boxOuter.centerXAnchor
    ).isActive = true
    box.centerYAnchor.constraint(
      equalTo: boxOuter.centerYAnchor
    ).isActive = true

    // Store the intended size in the box's identifier for later retrieval
    box.wantsLayer = true
    box.layer?.cornerRadius = 14
    box.layer?.backgroundColor = spec.color.withAlphaComponent(0.10).cgColor

    let textLabel = NSLabel(text: spec.label)
    textLabel.alignment = .center
    textLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
    textLabel.textColor = .secondaryLabelColor

    let pxLabel = NSLabel(text: "\(Int(spec.size)) px")
    pxLabel.alignment = .center
    pxLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
    pxLabel.textColor = .tertiaryLabelColor

    let labelStack = NSStackView(views: [textLabel, pxLabel])
    labelStack.orientation = .vertical
    labelStack.alignment = .centerX
    labelStack.spacing = 1

    innerStack.addArrangedSubview(boxOuter)
    innerStack.addArrangedSubview(labelStack)
    wrapper.contentView?.addSubview(innerStack)

    NSLayoutConstraint.activate([
      innerStack.centerXAnchor.constraint(equalTo: wrapper.contentView!.centerXAnchor),
      innerStack.centerYAnchor.constraint(equalTo: wrapper.contentView!.centerYAnchor),
      innerStack.leadingAnchor.constraint(
        greaterThanOrEqualTo: wrapper.contentView!.leadingAnchor, constant: 0),
      innerStack.trailingAnchor.constraint(
        lessThanOrEqualTo: wrapper.contentView!.trailingAnchor, constant: 0),
      innerStack.topAnchor.constraint(
        greaterThanOrEqualTo: wrapper.contentView!.topAnchor, constant: 0),
      innerStack.bottomAnchor.constraint(
        lessThanOrEqualTo: wrapper.contentView!.bottomAnchor, constant: 0),
    ])

    // Return as a stack for compatibility with the rest of the code
    let stack = NSStackView(views: [wrapper])
    stack.orientation = .vertical
    stack.alignment = .leading
    stack.spacing = 0
    return stack
  }

  // Highlight the selected preview box with animation and shadow
  func highlightSelectedPreviewBox(selectedSize: Int) {
    for box in self.previewBoxes {
      if let id = box.identifier?.rawValue, Int(id) == selectedSize {
        NSAnimationContext.runAnimationGroup { context in
          context.duration = 0.18
          box.layer?.borderColor = NSColor.controlAccentColor.cgColor
          box.layer?.shadowColor = NSColor.controlAccentColor.withAlphaComponent(0.18).cgColor
          box.layer?.shadowOpacity = 1
          box.layer?.shadowRadius = 8
          box.layer?.shadowOffset = CGSize(width: 0, height: 2)
        }
      } else {
        NSAnimationContext.runAnimationGroup { context in
          context.duration = 0.18
          box.layer?.borderColor = NSColor.clear.cgColor
          box.layer?.shadowOpacity = 0
        }
      }
    }
  }

  // Handle preview box click
  @objc func previewBoxClicked(_ gesture: NSClickGestureRecognizer) {
    guard let box = gesture.view as? NSBox,
      let id = box.identifier?.rawValue,
      let size = Int(id)
    else { return }
    PreferenceStore.shared.iconSize = size
    highlightSelectedPreviewBox(selectedSize: size)
  }

  func getPreviewResetButton() -> NSView {
    resetPreviewButton.title = "Reset"
    resetPreviewButton.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
    resetPreviewButton.bezelStyle = .rounded
    resetPreviewButton.contentTintColor = .controlAccentColor
    resetPreviewButton.sizeToFit()
    resetPreviewButton.needsDisplay = true
    resetPreviewButton.setFrameX(-5)
    return resetPreviewButton
  }

  @objc func resetPreview(_ button: NSButton) {
    PreferenceStore.shared.previewY = 0
  }
}
