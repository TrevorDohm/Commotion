//
//  ViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    // MARK: Class Variables
    
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    
    var totalSteps: Float = 0.0 {
        willSet(newtotalSteps) {
            DispatchQueue.main.async {
                self.stepsLabel.text = "Steps Today: \(newtotalSteps)"
                self.checkGoalStatus()
            }
        }
    }
    
    var stepsYesterday: Float = 0.0 {
        willSet(newStepsYesterday) {
            DispatchQueue.main.async {
                self.stepsYesterdayLabel.text = "Steps Yesterday: \(newStepsYesterday)"
            }
        }
    }
    
    var dailyGoal: Float = 10000.0 {
        didSet {
            if dailyGoal != 0 {
                UserDefaults.standard.set(dailyGoal, forKey: "DailyGoal")
            }
            DispatchQueue.main.async{
                self.stepsGoalLabel.text = "Steps to Goal: \(Int(self.dailyGoal) - Int(self.totalSteps))"
            }
        }
    }

    
    // MARK: UI Elements
    
    @IBOutlet weak var stepsSlider: UISlider!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var isWalking: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var playGameButton: UIButton!
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.dailyGoal = sender.value
    }
    
    // MARK: View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedGoal = UserDefaults.standard.value(forKey: "DailyGoal") as? Float {
            dailyGoal = savedGoal
        } else {
            dailyGoal = 10000.0
        }
        
        stepsSlider.value = dailyGoal
        
        self.totalSteps = 0.0
        self.startActivityMonitoring()
        self.startPedometerMonitoring()
//        self.startMotionUpdates()
        self.fetchStepsForYesterday()
    }

    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        if let savedGoal = UserDefaults.standard.float(forKey: "DailyGoal")
//        self.totalSteps = 0.0
//
//        // Start monitoring
//        self.startActivityMonitoring()
//        self.startPedometerMonitoring()
//        self.startMotionUpdates()
//        self.fetchStepsForYesterday()
//    }
    
    // MARK: Raw Motion Functions
    
    func startMotionUpdates(){
        if self.motion.isDeviceMotionAvailable {
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion)
        }
    }
    
//    // MARK: =====Raw Motion Functions=====
//    func startMotionUpdates(){
//        // some internal inconsistency here: we need to ask the device manager for device
//
//        // TODO: should we be doing this from the MAIN queue? You will need to fix that!!!....
//        if self.motion.isDeviceMotionAvailable{
//            self.motion.startDeviceMotionUpdates(to: OperationQueue.main,
//                                                 withHandler: self.handleMotion)
//        }
//    }
    
    func handleMotion(_ motionData: CMDeviceMotion?, error: Error?) {
        if let gravity = motionData?.gravity {
            let rotation = atan2(gravity.x, gravity.y) - Double.pi
            DispatchQueue.main.async {
                self.isWalking.transform = CGAffineTransform(rotationAngle: CGFloat(rotation))
            }
        }
    }
    
    // MARK: Activity Methods
    
    func startActivityMonitoring(){
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
    }
    
//    // MARK: =====Activity Methods=====
//    func startActivityMonitoring(){
//        // is activity is available
//        if CMMotionActivityManager.isActivityAvailable(){
//            // update from this queue (should we use the MAIN queue here??.... )
//            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
//        }
//
//    }
    
    func handleActivity(_ activity: CMMotionActivity?) {
        if let unwrappedActivity = activity {
            let activityStatus = activityDescription(activity: unwrappedActivity)
            DispatchQueue.main.async {
                self.isWalking.text = activityStatus
            }
        }
    }
    
    //    func handleActivity(_ activity:CMMotionActivity?)->Void{
    //        // unwrap the activity and disp
    //        if let unwrappedActivity = activity {
    //            DispatchQueue.main.async{
    //                self.isWalking.text = "Walking: \(unwrappedActivity.walking)\n Still: \(unwrappedActivity.stationary)"
    //            }
    //        }
    //    }
    //
    
    func activityDescription(activity: CMMotionActivity) -> String {
        if activity.walking { return "Walking" }
        if activity.stationary { return "Still" }
        if activity.running { return "Running" }
        if activity.cycling { return "Cycling" }
        if activity.automotive { return "Driving" }
        return "Unknown"
    }
    
    // MARK: Pedometer Methods
    
    func startPedometerMonitoring() {
        if CMPedometer.isStepCountingAvailable() {
            pedometer.startUpdates(from: Date(), withHandler: handlePedometer)
        }
    }
    
    func handlePedometer(_ pedData: CMPedometerData?, error: Error?) {
        if let steps = pedData?.numberOfSteps {
            self.totalSteps = steps.floatValue
        }
    }
    
    func fetchStepsForYesterday() {
        let calendar = Calendar.current
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())) else { return }
        pedometer.queryPedometerData(from: yesterday, to: Date()) { (data, error) in
            if let steps = data?.numberOfSteps {
                self.stepsYesterday = steps.floatValue
            }
        }
    }
    
    func checkGoalStatus() {
        if self.totalSteps >= self.dailyGoal {
            playGameButton.isHidden = false
        } else {
            playGameButton.isHidden = true
        }
    }
}
