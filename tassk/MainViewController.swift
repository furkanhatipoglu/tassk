import Cocoa


let lastCheckDateKey = "lastCheckDateKey"
let updateIsAvailableKey = "updateIsAvalibleKey"


class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate {

    enum buttonStatusEnum {
      case about
      case downloadApp
      case downloading
    }
  
    var notes = [String]()
    let notesDiscKey = "notesDiscKey"
    @IBOutlet weak var listTableView: NSTableView!
    @IBOutlet weak var noteTextField: NSTextField!
    @IBOutlet weak var updateButton: CustomButton!
    @IBOutlet weak var activityIndicator: NSProgressIndicator!
  
    let updateAvailableText = "New update is available!"
    let aboutText = "About"
  
    var buttonStatus = buttonStatusEnum.about
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let notesForUserDefaults = UserDefaults.standard.array(forKey: notesDiscKey) as? [String] {
      notes = notesForUserDefaults
    }
    
    listTableView.delegate = self
    listTableView.dataSource = self
    listTableView.selectionHighlightStyle = .none
    
    noteTextField.delegate = self
    activityIndicator.isDisplayedWhenStopped = false
  
    setButtonTitle(text: aboutText)
  }
  
  override func viewWillAppear() {
    NSApp.activate(ignoringOtherApps: true)
    noteTextField.becomeFirstResponder()
  }
  
  override func viewDidAppear() {
    checkUpdates()
  }

  func setButtonTitle (text: String) {
    let pstyle = NSMutableParagraphStyle()
    pstyle.alignment = .left
    updateButton.attributedTitle = NSAttributedString(string: text, attributes: [ NSAttributedStringKey.foregroundColor: NSColor.gray, NSAttributedStringKey.paragraphStyle: pstyle])
  }
  
  func checkUpdates () {
    
    if AppUpdateFunctions().getUpdateStatusFromDisc() {
      buttonStatus = .downloadApp
      setButtonTitle(text: updateAvailableText)
      return
    }
    
    let lastCheckDate = AppUpdateFunctions().getLastCheckDateFromDisc()
    let currentDate = Helper().getCurrentDateWithString()
    
    // checking once a day is enough
    if lastCheckDate == currentDate {
      return
    }
    
    UserDefaults.standard.set(currentDate, forKey: lastCheckDateKey)
    
    AppUpdateFunctions().getUpdateDataFromRemote { (data) in
      if let storeVersion =  AppUpdateFunctions().parseUpdateJsonData(data: data), let currentVersion = Helper().getAppVersion() {
        let updateAvailabilityResult = AppUpdateFunctions().compareVersionStrings(storeVersion: String(storeVersion), currentVersion: currentVersion)
        
        if updateAvailabilityResult {
          
          DispatchQueue.main.async {
            // Update ui on the main thread
            self.buttonStatus = .downloadApp
            self.setButtonTitle(text: self.updateAvailableText)
            UserDefaults.standard.set(true, forKey: updateIsAvailableKey)
          }
        }
      }
    }
  }


  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    
    let cellIdentifier = NSUserInterfaceItemIdentifier("cellIdentifier")
    
    if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? ListTableViewCell {
      cell.titleLabel.stringValue = notes[row]
      cell.checkButton.tag = 1000 + row
      cell.checkButton.action = #selector(checkButtonPressed)
      
      return cell
    }
    
    return nil
  }
  

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 30
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return notes.count
  }
  
  override func controlTextDidEndEditing(_ obj: Notification) {
    updateListValues()
  }
  
  @objc func checkButtonPressed(sender: NSButton) {

    let id = sender.tag
    notes.remove(at: id - 1000)
    listTableView.reloadData()
    updateDiscData()
    
    }
  
  func updateDiscData () {
    UserDefaults.standard.set(notes, forKey: notesDiscKey)
    
  }
  
  func updateListValues () {
    if noteTextField.stringValue != "" {
      notes.insert(noteTextField.stringValue, at: 0)
      noteTextField.stringValue = ""
      listTableView.reloadData()
      updateDiscData()
    }
  }
  
    
    @IBAction func updateButtonPressed(_ sender: NSButton) {
      
      switch buttonStatus {
      case .downloadApp:
        UserDefaults.standard.set(false, forKey: updateIsAvailableKey)
        setButtonTitle(text: aboutText)
        downloadNewSetupFile()
        break
      case .about:
        launchGithubLink()
        break
      case .downloading:
        break
      }
    }
    
  func launchGithubLink () {
    if let url = URL(string: "https://github.com/furkanhatipoglu/tassk"), NSWorkspace.shared.open(url) {
      
    }
  }
  
  
  func downloadNewSetupFile () {

    let errorTitle = "An error occurred"
    let errorOccured = "While downloading the new version, an error occured."
    
    
    let tasskAppDownloadUrl = URL(string:  "http://web.itu.edu.tr/hatipoglufu/tassk/tassk.zip")
    
    // check url is ok.
    if tasskAppDownloadUrl == nil {
      _ = self.createAlertView(question: errorTitle, text: errorOccured)
      return
    }
    
   self.setDownloadingProperties()
   
    URLSession.shared.dataTask(with: tasskAppDownloadUrl!, completionHandler: { (responseData, response, error) in
      // check response data is nil or not.
      if responseData == nil {
        _ = self.createAlertView(question: errorTitle, text: errorOccured)
      } else {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)[0];
        let filePathUrl = URL(fileURLWithPath: "\(documentsPath)/tassk.zip")
        
        DispatchQueue.main.async {
          
          self.setNotDownladingProperties()
          
          // write to downloads folder
          do {
            try responseData?.write(to: filePathUrl, options: .atomic)
            _ = self.createAlertView(question: "The download is complete.", text: "New version of tassk app is saved to downloads folder. Just click it.")
          } catch {
            _ = self.createAlertView(question: errorTitle, text: errorOccured)
          }
        }
      }
    }).resume()
  }
  
  func setDownloadingProperties () {
    activityIndicator.startAnimation(self)
    buttonStatus = .downloading
    setButtonTitle(text: "Downloading")
    updateButton.frame = NSRect(x: updateButton.frame.minX + 20, y: updateButton.frame.minY, width: updateButton.bounds.width, height: updateButton.bounds.height)
  }
  
  func setNotDownladingProperties () {
    self.activityIndicator.stopAnimation(self)
    self.buttonStatus = .about
    self.setButtonTitle(text: "About")
    self.updateButton.frame = NSRect(x: self.updateButton.frame.minX - 20, y: self.updateButton.frame.minY, width: self.updateButton.bounds.width, height: self.updateButton.bounds.height)
  }
  
  func createAlertView(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    return alert.runModal() == .alertFirstButtonReturn
  }
  
  static func freshController() -> MainViewController {
    let storyboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil)
    let identifier = NSStoryboard.SceneIdentifier(rawValue: "MainViewController")
    guard let viewcontroller = storyboard.instantiateController(withIdentifier: identifier) as? MainViewController else {
      fatalError("Why cant i find MainViewController? - Check Main.storyboard")
    }
    return viewcontroller
  }

}
