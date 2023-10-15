//
//  ViewInterface.swift
//  Commotion
//
//  Created by Trevor Dohm on 10/14/23.
//  Copyright © 2023 Eric Larson. All rights reserved.
//

import UIKit

let shape = CAShapeLayer()
let myInt = 12
class ViewInterface: UIView {
    let shape = CAShapeLayer()
    
    let goalLabel: UILabel = {
        let goalLabel = UILabel()
        goalLabel.textAlignment = .center
        goalLabel.text = String(myInt)
        return goalLabel
    }()

    func showCircle(stepsToday : Int, stepGoal : Int){
        let progress = min(1.0, Double(stepsToday) / Double(stepGoal))

        let trackCirclePath = UIBezierPath(
            arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
            radius: 150,
            startAngle: -(.pi / 2),
            endAngle: .pi * 2,
            clockwise: true
        )
        
        let trackShape = CAShapeLayer()
        trackShape.path = trackCirclePath.cgPath
        trackShape.fillColor = UIColor.clear.cgColor
        trackShape.lineWidth = 15
        trackShape.strokeColor = UIColor.lightGray.cgColor
        self.layer.addSublayer(trackShape)
        
        let endAngle = 2 * .pi * progress - .pi/2

            let circlePath = UIBezierPath(
                arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY),
                radius: 150,
                startAngle: -(.pi / 2),
                endAngle: CGFloat(endAngle),
                clockwise: true
            )

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
        
        
        ///////////////////////
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: self.bounds.midX, y: self.bounds.midY), radius: 150, startAngle: -(.pi/2) , endAngle: .pi * 2, clockwise: true)
//
//        goalLabel.sizeToFit()
//        self.addSubview(goalLabel)
//        goalLabel.center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
//
//        let trackShape = CAShapeLayer()
//        trackShape.path = circlePath.cgPath
//        trackShape.fillColor = UIColor.clear.cgColor
//        trackShape.lineWidth = 15
//        trackShape.strokeColor = UIColor.lightGray.cgColor
//        self.layer.addSublayer(trackShape)
//
//
//
//        shape.path = circlePath.cgPath
//        shape.lineWidth = 15
//        shape.strokeColor = UIColor.green.cgColor
//        shape.fillColor = UIColor.clear.cgColor
//        shape.strokeEnd = 0
//        self.layer.addSublayer(shape)
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.toValue = 1
//        animation.duration = 3
//        shape.add(animation, forKey: "animation")
        
    }
    
}
