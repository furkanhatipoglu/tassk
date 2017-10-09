//
//  CustomTableViewCell.swift
//  tassk
//
//  Created by Erstream on 28/09/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Cocoa

class ListTableViewCell: NSTableCellView {
  
  var titleLabel = NSTextField()
  var checkButton = NSButton()
  
  // custom table view cell
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    
    checkButton.setButtonType(.pushOnPushOff)
    checkButton.bezelStyle = .circular
    checkButton.image = NSImage(named: NSImage.Name(rawValue: "checkIcon"))
    checkButton.imagePosition = .imageOnly
    checkButton.isBordered = false
    checkButton.wantsLayer = true
    checkButton.layer?.backgroundColor = NSColor.clear.cgColor

    self.addSubview(checkButton)
    
    titleLabel.isBordered = false
    titleLabel.font = NSFont.systemFont(ofSize: 13)
    titleLabel.isEditable = false
    self.addSubview(titleLabel)
  }
  
  private var trackingArea: NSTrackingArea?
  
  override func viewWillMove(toWindow newWindow: NSWindow?) {
    trackingArea = NSTrackingArea(rect: checkButton.bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
    checkButton.addTrackingArea(trackingArea!)
  }

  override func mouseEntered(with theEvent: NSEvent) {
    checkButton.image = NSImage(named: NSImage.Name(rawValue: "checkIconRed"))
  }

  override func mouseExited(with theEvent: NSEvent) {
    checkButton.image = NSImage(named: NSImage.Name(rawValue: "checkIcon"))
  }
  
  override func updateTrackingAreas() {
  
    if let trackingArea = self.trackingArea {
      self.removeTrackingArea(trackingArea)
    }
    
    let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
    let trackingArea = NSTrackingArea(rect: self.checkButton.bounds, options: options, owner: self, userInfo: nil)
    self.addTrackingArea(trackingArea)
  }

  override func draw(_ dirtyRect: NSRect) {
    checkButton.frame =  NSRect(x: 0, y: 0, width: 50, height: self.bounds.height)
    checkButton.state = .offState
    checkButton.image = NSImage(named: NSImage.Name(rawValue: "checkIcon"))
    titleLabel.frame = NSRect(x: 50, y: 4.5, width: self.bounds.width - 50, height: 21) //while font size 13, a sing line height is 21
  }
  
}
