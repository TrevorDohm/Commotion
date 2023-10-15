//
//  ViewInterface.swift
//  Commotion
//
//  Created by Will Landin on 10/14/23.
//  Copyright © 2023 Eric Larson. All rights reserved.


// CODE CREDITATION: Followed tutorial of Circle creation from this youtube video: https://www.youtube.com/watch?v=gAHYXM2e5E0

import UIKit

let shape = CAShapeLayer()

class ViewInterface: UIView {
    
    //Shape is what our circle is, it is called outside the function so that it can be used in multiple functions
    let shape = CAShapeLayer()
    //Same as shape the goal label is used in multiple functions so it is outside.
    let goalLabel: UILabel = {
        let goalLabel = UILabel()
        goalLabel.textAlignment = .center
        return goalLabel
    }()
    
    func createCircle(stepsToday : Int, stepGoal : Int){
        let progress = min(1.0, Double(stepsToday) / Double(stepGoal))

        let trackCirclePath = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: 150,
            startAngle: -(.pi / 2),
            endAngle: .pi * 2,
            clockwise: true
        )
        
        //Draw a gray circle outline. This will get overrlapped by the green progress circle.
        let trackShape = CAShapeLayer()
        trackShape.path = trackCirclePath.cgPath
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.lineWidth = 15
        trackShape.strokeColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(trackShape)
        
        let endAngle = 2 * .pi * progress - .pi/2

        //Draw initial green progress circle.
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: 150,
            startAngle: -(.pi / 2),
            endAngle: CGFloat(endAngle),
            clockwise: true
        )

        //Creates initial shape and goal text which will be updated in the below section
            goalLabel.text = "\(stepsToday) Out of  \(stepGoal) Steps "
            goalLabel.sizeToFit()
            self.addSubview(goalLabel)
            goalLabel.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

            shape.path = circlePath.cgPath
            shape.lineWidth = 15
            shape.strokeColor = UIColor.green.cgColor
            shape.fillColor = UIColor.clear.cgColor
            shape.strokeEnd = CGFloat(progress)
            self.layer.addSublayer(shape)
        
    }
    
    func updateCircle(stepsToday: Int, stepGoal: Int) {
        let progress = min(1.0, Double(stepsToday) / Double(stepGoal))
        
        // Update the progress of the shape layer
        shape.strokeEnd = CGFloat(progress)

        // Update the goal label
        goalLabel.text = "\(stepsToday) Out of \(stepGoal) Steps"
        goalLabel.sizeToFit()
        
        // Redraw the circle path to reflect the updated progress
        let endAngle = 2 * .pi * progress - .pi/2
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: 150,
            startAngle: -(.pi / 2),
            endAngle: CGFloat(endAngle),
            clockwise: true
        )
        
        // Update the shape layer path
        shape.path = circlePath.cgPath
    }
}
