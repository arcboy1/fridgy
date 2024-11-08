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

        // determine color based on remaining days
        let color: UIColor
        switch remainingDays {
        case 15...:
            color = UIColor.green // fresh
        case 8..<15:
            color = UIColor.yellow // approaching expiry
        case 4..<8:
            color = UIColor.orange // warning expiry
        default:
            color = UIColor.red // almost expired
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
        
        if remainingDays < 0 {
            drawExclamationMark(at: center, in: rect)
        }
    }
    private func drawExclamationMark(at center: CGPoint, in rect: CGRect) {
        guard let image = UIImage(systemName: "exclamationmark.triangle.fill")?.withTintColor(.red) else { return }
        
        let imageSize = CGSize(width: 25, height: 25) // size of the symbol
        let imageOrigin = CGPoint(x: center.x - imageSize.width / 2, y: center.y - imageSize.height / 2)

        // draw the symbol in the context
        image.draw(in: CGRect(origin: imageOrigin, size: imageSize))
    }
}
