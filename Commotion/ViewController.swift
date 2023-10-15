//
//  ViewController.swift
//  Commotion
//
//  Created by Eric Larson on 9/6/16.
//  Copyright © 2016 Eric Larson. All rights reserved.
//
//  Lab Three: Core Motion, SpriteKit (CMSK)
//  Trevor Dohm, Alex Shockley, Will Landin, Ray Irani
//

// Import Statements
import UIKit
import CoreMotion

// Main View Controller (Front Page)
class ViewController: UIViewController {
    
    // MARK: Class Variables
    
    // Note: "Let" Used For Constants, "Var" For Variables
    
    // Obtain Core Motion Objects
    let activityManager = CMMotionActivityManager()
    let pedometer = CMPedometer()
    let motion = CMMotionManager()
    
    // Convenience Variable For Readability
    // Handles Persistence Across Restarts
    let defaults = UserDefaults.standard
    
    // Initialize Timer Here - Makes Deallocation Easier
    var stepUpdateTimer: Timer?
    
    // Note: "WillSet" Used When Method Does Not Need The Variable,
    // "DidSet" For When Method References Variable In It's Assignment
    
    // Initialize Steps Today
    var stepsToday: Int = 0 {
        willSet(newStepsToday) {
            
            // Whenever Steps Today Changes, Update View
            DispatchQueue.main.async {
                self.stepsTodayLabel.text = "Steps Today: \(newStepsToday)"
                self.updateGoalStatus()
            }
        }
    }
    
    // Initialize Steps Yesterday
    var stepsYesterday: Int = 0 {
        willSet(newStepsYesterday) {
            
            // Whenever Steps Yesterday Changes, Update View
            // Note: This Also Changes When The Day Changes (Midnight)
            DispatchQueue.main.async {
                self.stepsYesterdayLabel.text = "Steps Yesterday: \(Int(newStepsYesterday))"
            }
        }
    }
    
    // Initialize Daily Goal (10000 First Time Opening App)
    // CDC Recommends Most Adults To Get 10000 Steps! Are You
    // Getting 10000 Steps Eric? Because I'm Surely Not :3
    var dailyGoal: Int = 10000 {
        didSet {
            
            // Maintain Daily Goal
            if self.dailyGoal != 0 {
                defaults.set(self.dailyGoal, forKey: "DailyGoal")
            }
            
            // Update View (Like Above)
            DispatchQueue.main.async{
                self.updateGoalStatus()
            }
        }
    }
    
    // MARK: UI Elements
    
    @IBOutlet weak var goalSlider: UISlider!
    @IBOutlet weak var stepsTodayLabel: UILabel!
    @IBOutlet weak var activityLabel: UILabel!
    @IBOutlet weak var stepsYesterdayLabel: UILabel!
    @IBOutlet weak var stepsGoalLabel: UILabel!
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var viewInterface: ViewInterface!
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.dailyGoal = Int(sender.value)
    }
    
    // MARK: View Lifecycles
    
    // Run When View Loads (With Super Method)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pull Daily Goal From Previous Run
        if let savedGoal = defaults.value(forKey: "DailyGoal") as? Int {
            dailyGoal = savedGoal
        }
        
        // Update Goal Slider With Daily Goal
        goalSlider.value = Float(dailyGoal)
        
        // Start Activity Monitoring (Whatcha Doin?)
        self.startActivityMonitoring()
        
        // Fetch Pedometer Information Frequently
        stepUpdateTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self,
            selector: #selector(self.fetchSteps),
            userInfo: nil, repeats: true)
    }
    
    // Handle Timer Deallocation
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stepUpdateTimer?.invalidate()
        stepUpdateTimer = nil
    }
    
    // MARK: Activity Methods
    
    // Check Activity Availability, Update From Operation Queue (Not Main Queue)
    func startActivityMonitoring() {
        if CMMotionActivityManager.isActivityAvailable() {
            self.activityManager.startActivityUpdates(to: OperationQueue.main, withHandler: self.handleActivity)
        }
    }
    
    // Obtain Activity Type From Core Motion, Display With Relevant Emoji
    func handleActivity(_ activity: CMMotionActivity?) {
        if let unwrappedActivity = activity {
            DispatchQueue.main.async {
                self.activityLabel.text = "You're " + {
                    if unwrappedActivity.walking { return "Walking! 🚶‍♂️" }
                    if unwrappedActivity.stationary { return "Not Moving! 🛑" }
                    if unwrappedActivity.running { return "Running! 🏃‍♂️" }
                    if unwrappedActivity.cycling { return "Cycling! 🚴‍♂️" }
                    if unwrappedActivity.automotive { return "Driving! 🚗" }
                    return "Doing Something...? 🤔"
                }()
            }
        }
    }

    // MARK: Update Methods

    // Main Workhorse - Fetch Date Information, Query Pedometer With Said Information
    @objc func fetchSteps() {
        
        // Obtain Current Calendar (Today, Yesterday, Etc.)
        let calendar = Calendar.current
        
        // Get Start Of Today (12:00 AM = Midnight)
        let startOfToday = calendar.startOfDay(for: Date())
        
        // Get Start Of Yesterday (Above, Yesterday)
        guard let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: startOfToday) else { return }
        
        // Get End Of Yesterday (One Second Before Midnight Today)
        // Well, If We Are Being Exact This Is Correct... Just Saying...
        guard let endOfYesterday = calendar.date(byAdding: .second, value: -1, to: startOfToday) else { return }
        
        // Fetch Steps For Yesterday
        pedometer.queryPedometerData(from: startOfYesterday, to: endOfYesterday) { (data, error) in
            if let steps = data?.numberOfSteps {
                self.stepsYesterday = steps.intValue
            }
        }
        
        // Fetch Steps For Today
        pedometer.queryPedometerData(from: startOfToday, to: Date()) { (data, error) in
            if let steps = data?.numberOfSteps {
                self.stepsToday = steps.intValue
            }
        }
        //updateGoalStatus()
        
        // UPDATE VIEW HERE! (MAKE SURE TO CALL MAIN QUEUE)
        DispatchQueue.main.async{
//            self.viewInterface.setNeedsDisplay()
            self.viewInterface.showCircle(stepsToday: self.stepsToday, stepGoal: self.dailyGoal)
        }
        
    }
    
    // Update Goal Status - Need To Call From Main Queue
    func updateGoalStatus() {
        let remainingSteps = max(0, Int(self.dailyGoal) - Int(self.stepsYesterday))
        self.stepsGoalLabel.text = "Steps Remaining -> Goal: \(remainingSteps)"
        playGameButton.isHidden = remainingSteps > 0
    }
}
