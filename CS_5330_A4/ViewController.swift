//
//  ViewController.swift
//  CS_5330_A4
//
//  Created by Kyle Zimmerman on 1/29/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var BackgroundImage: UIImageView!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var DatePicker: UIDatePicker!
    @IBOutlet weak var TimeRemaining: UILabel!
    @IBOutlet weak var TimerMusicButton: UIButton!
    
    var timer: Timer?
    var countdownTimer: Timer?
    var remainingSeconds: Int = 0
    var audioPlayer: AVAudioPlayer?
    var isTimerActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    func setup() {
        prepareAudioPlayer()
        TimerMusicButton.setTitle("Start Timer", for: .normal)
        dateTimeLabel.text = ""
        TimeRemaining.text = ""
        setBackgroundImage()
        startClock()
    }
    
    func startClock() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateDateTimeLabel), userInfo: nil, repeats: true)
    }
    
    @objc func updateDateTimeLabel() {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateTimeLabel.text = formatter.string(from: currentDateTime)
        setBackgroundImage()
    }
        
    func setBackgroundImage() {
        let hourFormatter = DateFormatter()
        hourFormatter.dateFormat = "a"
        let hourString = hourFormatter.string(from: Date());
        if hourString == "AM" { // here you can mock PM and AM by changing the comparison to see the background image update
            BackgroundImage.image = UIImage(named: "am-image")
        } else {
            BackgroundImage.image = UIImage(named: "pm-image")
        }
    }
    
    @IBAction func TimerMusicBtnPressed(_ sender: UIButton) {
        if(!isTimerActive && audioPlayer?.isPlaying == false) {
            startCountDown()
            remainingSeconds = Int(DatePicker.countDownDuration)
        }
        
        if(isTimerActive && audioPlayer?.isPlaying == false) {
            isTimerActive = false
            startCountDown()
            remainingSeconds = Int(DatePicker.countDownDuration)
        }
        
        if(!isTimerActive && audioPlayer?.isPlaying == true) {
            audioPlayer?.stop()
            audioPlayer?.currentTime = 0
            TimeRemaining.text = ""
        }
        
        if(audioPlayer?.isPlaying == false) {
            TimerMusicButton.setTitle("Start Timer", for: .normal)
        } else {
            TimerMusicButton.setTitle("Stop Music", for: .normal)
        }
    }
    
    func startCountDown() {
        countdownTimer?.invalidate() // Invalidates existing timer
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimeRemaining), userInfo: nil, repeats: true)
        isTimerActive = true
    }
    
    @objc func updateTimeRemaining() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            let hours = remainingSeconds / 3600
            let minutes = (remainingSeconds % 3600) / 60
            let seconds = remainingSeconds % 60
            TimeRemaining.text = "Time Remaining: " + String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            // Timer completes
            countdownTimer?.invalidate()
            countdownTimer = nil
            TimeRemaining.text = "Time's up!"
            TimerMusicButton.setTitle("Stop Music", for: .normal)
            if !(audioPlayer?.isPlaying ?? false) {
                audioPlayer?.play() // Start playing music if not already playing
            }
            isTimerActive = false
        }
    }
    
    func prepareAudioPlayer() {
        guard let audioURL = Bundle.main.url(forResource: "alarm_timer", withExtension: "mp3") else {
            print("Audio file not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1
        } catch {
            print("Error initializing the audio player: \(error)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
           print("Failed to set audio session category: \(error)")
        }
    }
    
   
    // used to invalidate the timer when the view controller is deallocated this is a best practice to prvent memory leaks.
    deinit {
        timer?.invalidate()
        countdownTimer?.invalidate()
        audioPlayer?.stop()
        audioPlayer = nil
    }
}

