import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
  let popover = NSPopover()
  var eventMonitor: EventMonitor?

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    if let button = statusItem.button {
      button.image = NSImage(named: NSImage.Name(rawValue: "StatusBarButtonImage"))
      button.action = #selector(AppDelegate.togglePopover(_:))
    }
    
    hotKey = HotKey(keyCombo: KeyCombo(key: .t, modifiers: [.command, .option]))
    
    startApp()
    
  }
  
  
  func startApp () {
    
    popover.contentViewController = MainViewController.freshController()
    popover.animates = false
    
    eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
      if let strongSelf = self, strongSelf.popover.isShown {
        strongSelf.closePopover(sender: event)
      }
    }
  }

  
  @objc func togglePopover(_ sender: Any?) {
    if popover.isShown {
      closePopover(sender: sender)
    } else {
      showPopover(sender: sender)
    }
  }

  func showPopover(sender: Any?) {
    if let button = statusItem.button {
      popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      eventMonitor?.start()
    }
  }

  func closePopover(sender: Any?) {
    popover.performClose(sender)
    eventMonitor?.stop()
  }
  
  private var hotKey: HotKey? {
    didSet {
      guard let hotKey = hotKey else {
        print("Unregistered")
        return
      }
      
      hotKey.keyDownHandler = { [weak self] in
        
        if !(self?.popover.isShown ?? false) {
          NSRunningApplication.current.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
        }
        
        self?.togglePopover(self)
      }
    }
  }
}
