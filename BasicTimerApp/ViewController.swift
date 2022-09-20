//
//  ViewController.swift
//  BasicTimerApp
//
//  Created by Paul Lee on 2022/09/20.
//

import UIKit
import AudioToolbox

enum currentTimeState {
    case finished
    case started
    case paused
}

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var startToggleButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var duration: Int = 60
    var currentSeconds = 0
    
    var timer: DispatchSourceTimer?
    var currentStatus: currentTimeState = .finished
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInitialView()
    }

    @IBAction func tapStartButton(_ sender: UIButton) {
        duration = Int(datePicker.countDownDuration)
        
        switch currentStatus {
        case .finished:
            currentSeconds = duration
            timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            timer?.schedule(deadline: .now(), repeating: 1)
            timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let min = (self.currentSeconds % 3600) / 60
                let sec = (self.currentSeconds % 3600) % 60
                self.timeLabel.text = String(format: "%02d:%02d:%02d", hour, min, sec)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                }
                
                UIView.animate(withDuration: 0.5) {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                }
            })
            timer?.resume()
            currentStatus = .started
            
            UIView.animate(withDuration: 0.5) {
                self.configureStartedView()
            }
        case .started:
            timer?.suspend()
            currentStatus = .paused
            startToggleButton.isSelected = false
        case .paused:
            timer?.resume()
            currentStatus = .started
            startToggleButton.isSelected = true
        }
        
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        stopTimer()
    }
    
    func stopTimer() {
        if let currentTimer = timer {
            if currentStatus == .paused {
                currentTimer.resume()
            }
            currentTimer.cancel()
        }
        
        timer = nil
        currentStatus = .finished
        
        UIView.animate(withDuration: 0.5) {
            self.configureInitialView()
        }
    }
}

extension ViewController {
    private func configureInitialView() {
        timeLabel.alpha = 0.0
        progressView.alpha = 0.0
        datePicker.alpha = 1.0
        
        startToggleButton.setTitle("시작", for: .normal)
        startToggleButton.setTitle("일시정지", for: .selected)
        
        cancelButton.isEnabled = false
        startToggleButton.isSelected = false
        
        imageView.transform = CGAffineTransform.identity
    }
    
    private func configureStartedView() {
        timeLabel.alpha = 1.0
        progressView.alpha = 1.0
        datePicker.alpha = 0.0
        
        cancelButton.isEnabled = true
        startToggleButton.isSelected = true
    }
}
