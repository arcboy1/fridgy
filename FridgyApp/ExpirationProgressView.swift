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
    //define max days for full freshness (30 days)
    private let maxFreshnessDays = 30

    override func draw(_ rect: CGRect) {
        guard let expirationDate = expirationDate else { return }
        
        // calculate remaining days relative to the current date
        let calendar = Calendar.current
        let remainingDays = calendar.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        
        // calculate percentage based on max 30 days for full circle
        let percentage = max(min(CGFloat(remainingDays) / CGFloat(maxFreshnessDays), 1), 0) // range from 0 to 1

        // determine color based on two stages: green to yellow, then yellow to red
        let color: UIColor
        if percentage > 0.5 {
            // green to yellow transition (30 to 15 days)
            let greenToYellow = (percentage - 0.5) * 2 // scale to range 0 to 1
            color = UIColor(
                red: 1 - greenToYellow, // increasing red as it approaches yellow
                green: 1.0,             // fully green at start, decreases as red increases
                blue: 0,
                alpha: 1.0
            )
        } else {
            // yellow to red transition (15 to 0 days)
            let yellowToRed = percentage * 2 // scale to range 0 to 1
            color = UIColor(
                red: 1.0,                  // fully red
                green: yellowToRed,        // decrease green towards red
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
