//
//  CustomButton.swift
//  tassk
//
//  Created by Erstream on 08/10/2017.
//  Copyright © 2017 Razeware LLC. All rights reserved.
//

import Foundation
import Cocoa

class CustomButton: NSButton {
  //custom button that changes the cursor icon when mouse is on the button
  
  private var trackingArea: NSTrackingArea?
  
  override func viewWillMove(toWindow newWindow: NSWindow?) {
    trackingArea = NSTrackingArea(rect: self.bounds, options: [NSTrackingArea.Options.mouseEnteredAndExited, NSTrackingArea.Options.activeAlways], owner: self, userInfo: nil)
    self.addTrackingArea(trackingArea!)
  }
  
  var attributes: NSAttributedString?
  
  override func mouseEntered(with theEvent: NSEvent) {
    super.mouseEntered(with: theEvent)
    NSCursor.pointingHand.set()
  }
  
  override func mouseExited(with theEvent: NSEvent) {
    super.mouseExited(with: theEvent)
    NSCursor.arrow.set()
    
  }
  
  override func updateTrackingAreas() {
    
    if let trackingArea = self.trackingArea {
      self.removeTrackingArea(trackingArea)
    }
    
    let options: NSTrackingArea.Options = [.mouseEnteredAndExited, .activeAlways]
    let trackingArea = NSTrackingArea(rect: self.bounds, options: options, owner: self, userInfo: nil)
    self.addTrackingArea(trackingArea)
  }

}
