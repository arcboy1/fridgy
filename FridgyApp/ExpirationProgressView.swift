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
    
    override func draw(_ rect: CGRect) {
        guard let startDate = startDate, let expirationDate = expirationDate else { return }
        
        // calculate total days and remaining days
        let calendar = Calendar.current
        let totalDays = calendar.dateComponents([.day], from: startDate, to: expirationDate).day ?? 0
        let remainingDays = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        
        // determine the percentage and color based on urgency level
        let percentage: CGFloat
        let color: UIColor
        
        if remainingDays <= 3 {
            // less than 3 days remaining: show urgent
            percentage = 0.1 
            color = UIColor.red
        } else if remainingDays <= 7 {
            // between 3 and 7 days: show warning
            percentage = 0.5
            color = UIColor.yellow
        } else {
            // more than 7 days remaining: calculate normally
            percentage = max(min(CGFloat(remainingDays) / CGFloat(totalDays), 1), 0) // percentage between 0 and 1
            color = UIColor(
                red: (1 - percentage),
                green: percentage,
                blue: 0,
                alpha: 1.0
            )
        }
        
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
