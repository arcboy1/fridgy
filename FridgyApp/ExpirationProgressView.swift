//
//  ExpirationProgressView.swift
//  FridgyApp
//
//  Created by Noah Taggart on 2024-11-02.
//

import UIKit

class ExpirationProgressView: UIView {
    
    var startDate: Date?
    var expirationDate: Date?
    
    //line width for the circle
    private let lineWidth: CGFloat = 8.0
    //define max days for full freshness
    private let maxFreshnessDays = 30

    override func draw(_ rect: CGRect) {
        guard let expirationDate = expirationDate else { return }
        
        // calculate remaining days relative to the current date
        let calendar = Calendar.current
        let remainingDays = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        
        // calculate percentage based on max 30 days for full circle
        let percentage = max(min(CGFloat(remainingDays) / CGFloat(maxFreshnessDays), 1), 0) // range from 0 to 1

        // set color to transition from green to red based on percentage
        let color = UIColor(
            red: (1 - percentage), // increases red as expiration approaches
            green: percentage,     // decreases green as expiration approaches
            blue: 0,
            alpha: 1.0
        )
        // define circle parameters
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let radius = min(rect.width, rect.height) / 2 - lineWidth / 2
        
        // draw background circle (full circle in light gray)
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        UIColor.lightGray.setStroke()
        backgroundPath.lineWidth = lineWidth
        backgroundPath.stroke()
        
        // draw the progress arc
        let startAngle: CGFloat = -.pi / 2
        let endAngle: CGFloat = startAngle + (2 * .pi * percentage)
        let progressPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        color.setStroke()
        progressPath.lineWidth = lineWidth
        progressPath.stroke()
    }
}
