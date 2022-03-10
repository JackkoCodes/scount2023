//
//  ViewController.swift
//  scout2022
//
//  Coded by Nathan Blume w/ Eli Goreta during FRC 2019
//  Updated by Jack Wilds for the 2022 FRC season
//  Copyleft CC-BY SA 2019 THS Robotics
//

import UIKit
import CoreImage

class ViewController: UIViewController , UITextFieldDelegate{
    
    // buttons and fields get added here\
    
    @IBOutlet weak var saveMatchData: UIButton!
    
    @IBOutlet weak var QRCodeImageView: UIImageView!
    @IBOutlet weak var LogoImageView: UIImageView!
    
    @IBOutlet weak var matchNum: UITextField!
    @IBOutlet weak var teamNum: UITextField!
    @IBOutlet weak var scoutName: UITextField!
    @IBOutlet weak var comments: UITextView!
    
    @IBOutlet weak var autonLower: GMStepper!
    @IBOutlet weak var autonUpper: GMStepper!
    @IBOutlet weak var autonTarmac: UISwitch!
    
    @IBOutlet weak var teleLower: GMStepper!
    @IBOutlet weak var teleUpper: GMStepper!
    @IBOutlet weak var telePickup: UISwitch!
   
    @IBOutlet weak var disabledSwitch: UISwitch!
    @IBOutlet weak var timerStartStop: UIButton!
    @IBOutlet weak var timerReset: UIButton!
    
    @IBOutlet weak var climbTimerLabel: UILabel!
    
    
    var myUuid = ""
    var prevData = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scoutName.delegate = self
        teamNum.delegate = self
        matchNum.delegate = self
        myUuid = UUID().uuidString
        timerStartStop.setTitleColor(UIColor.green, for: .normal)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // only enable show button if team number has a value
    @IBAction func numChange(_ sender: Any) {
        if((teamNum.text?.isEmpty)! || (scoutName.text?.isEmpty)! || (matchNum.text?.isEmpty)!){
            saveMatchData.isEnabled = false
        }else{
            saveMatchData.isEnabled = true
        }
    }
    
    //beginning of timer hell
    var timer:Timer = Timer()
    var count:Int = 0
    var timerCounting:Bool = false
    
    //function for when reset button is tapped
    @IBAction func resetTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Reset timer?", message: "Are you sure you would like to reset the timer?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.count = 0
            self.timer.invalidate()
            self.climbTimerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            self.timerStartStop.setTitle("Start", for: .normal)
            self.timerStartStop.setTitleColor(UIColor.green, for: .normal)
            
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //function for when start/stop button is tapped
    @IBAction func startStopTapped(_ sender: Any) {
        if(timerCounting){
            timerCounting = false
            timer.invalidate()
            timerStartStop.setTitle("Start", for: .normal)
            timerStartStop.setTitleColor(UIColor.green, for: .normal)
        } else {
            timerCounting = true
            timerStartStop.setTitle("Stop", for: .normal)
            timerStartStop.setTitleColor(UIColor.red, for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func timerCounter() -> Void{
        count = count + 1
        let time = secondsToHoursMinutesSeconds(seconds: count)
        let timeString = makeTimeString(hours: time.0, minutes: time.1, seconds: time.2)
        climbTimerLabel.text! = timeString
    }
    //tbh at this point i have no idea what is going on, but it works
    func secondsToHoursMinutesSeconds(seconds: Int) -> (Int, Int, Int){
        return (seconds / 3600, (seconds % 3600) / 60, ((seconds % 3600) % 60))
    }
    
    func makeTimeString(hours: Int, minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        return timeString
    }
   
    var climbStatus = "N/A"
    //changes the value of climbStatus based on position of segmented control
    @IBAction func didChangeSegClimb(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            climbStatus = "N/A"
        } else if sender.selectedSegmentIndex == 1 {
            climbStatus = "Low"
        } else if sender.selectedSegmentIndex == 2 {
            climbStatus = "Mid"
        } else if sender.selectedSegmentIndex == 3 {
            climbStatus = "High"
        } else if sender.selectedSegmentIndex == 4 {
            climbStatus = "Traversal"
        }
    }
   
    var defenseVal = 0
    //changes the value of defenseVal based on position of segmented control
    @IBAction func didChangeSegDef(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            defenseVal = 0
        } else if sender.selectedSegmentIndex == 1 {
            defenseVal = 1
        } else if sender.selectedSegmentIndex == 2 {
            defenseVal = 2
        } else if sender.selectedSegmentIndex == 3 {
            defenseVal = 3
        } else if sender.selectedSegmentIndex == 4 {
            defenseVal = 4
        } else if sender.selectedSegmentIndex == 5 {
            defenseVal = 5
        }
    }
    // yes/no alert on reset, if yes set variables to 0
    @IBAction func clearForm(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "Clear form?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.matchNum.text = String((self.matchNum.text! as NSString).integerValue + 1)
            self.teamNum.text = ""
            self.comments.text = ""
            
            self.count = 0
            self.timer.invalidate()
            self.climbTimerLabel.text = self.makeTimeString(hours: 0, minutes: 0, seconds: 0)
            self.timerStartStop.setTitle("Start", for: .normal)
            self.timerStartStop.setTitleColor(UIColor.green, for: .normal)
            
            self.autonLower.value = 0.0
            self.autonUpper.value = 0.0
            self.autonTarmac.isOn = false
            
            self.teleLower.value = 0.0
            self.teleUpper.value = 0.0
            self.defenseVal = 0
            self.telePickup.isOn = false

            self.disabledSwitch.isOn = false
            
            self.QRCodeImageView.image = nil
            self.LogoImageView.isHidden = false
            
//            self.climbSuccess.isOn = false
//            self.climbAttempt.isOn = false
//
//            self.rotateSuccess.isOn = false
//            self.rotateAttempt.isOn = false
//
//            self.positionSuccess.isOn = false
//            self.positionAttempt.isOn = false
            // score calc form hide
            
            
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func createCode(_ sender: Any) {
        
        self.matchNum.endEditing(true)
        self.teamNum.endEditing(true)
        self.comments.endEditing(true)
        
        // create image filter
        var filter:CIFilter!
        
        // qr code function
        func generateQRCode(from string: String) -> UIImage? {
            let data = string.data(using: String.Encoding.ascii)
            
            if let filter = CIFilter(name: "CIQRCodeGenerator", withInputParameters: ["inputMessage" : data as Any, "inputCorrectionLevel":"M"]) { // changed line
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 3, y: 3)
                
                if let output = filter.outputImage?.transformed(by: transform) {
                    return UIImage(ciImage: output)
                }
            }
            return nil
        }
        
        // make a date/time string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let newDate = dateFormatter.string(from: Date())
        
        // set variables
        let autonLowerVal = autonLower.value
        let autonUpperVal = autonUpper.value
       
        let teleLowerVal = teleLower.value
        let teleUpperVal = teleUpper.value
        
        
        var commentText = comments?.text ?? ""
        commentText = commentText.replacingOccurrences(of: "\"", with: "\\\"")
        commentText = commentText.replacingOccurrences(of: ",", with: "&#44;")
        commentText = commentText.replacingOccurrences(of: "'|’", with: "&#39;", options: .regularExpression)
        
        let okayChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,./!? ")
        commentText = commentText.filter {okayChars.contains($0) }
    
        var matchText = matchNum?.text ?? ""
        matchText = matchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var teamText = teamNum?.text ?? ""
        teamText = teamText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var scoutText = scoutName?.text ?? ""
        scoutText = scoutText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        //dumps all variables into one string in order to generate a QR code
        var myData = "\(teamText),\(matchText),\(disabledSwitch.isOn),\(String(describing: climbTimerLabel.text)),\(climbStatus),\(autonTarmac.isOn),\(String(format: "%.0f",autonUpperVal)),\(String(format: "%.0f",autonLowerVal)),\(defenseVal),\(String(format: "%.0f",teleUpperVal)),\(String(format: "%.0f",teleLowerVal)),\(scoutText),\(commentText)"
        
        // change uuid if data changed and append uuid
        if(myData != prevData){
            myUuid = UUID().uuidString
            prevData = myData
            myData = myData + "," + myUuid
        }else{
            myData = myData + "," + myUuid
        }
        
       
        // create qr code image
        let image = generateQRCode(from: String(describing: myData))
        
        // set view image to qr code and hide logo
        self.LogoImageView.isHidden = true
        // show "showscore" viewcontroller
        QRCodeImageView.image = image
        print(String(describing: myData))
    }
    

}

