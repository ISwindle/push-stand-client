import UIKit

class CircularProgressBar: UIView {


    
    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var isAnimating = false
    
    var progress: CGFloat = 0.0 {
        didSet {
            if progress != oldValue { // Check if progress value has changed
                animateProgress(to: progress)
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Call createCircularPath again to update the path based on the updated frame
        // THIS FIXED THE ISSUE WE'VE BEEN HAVING!
        createCircularPath()
    }
//  Old code for dash and gap aesthetics
//    private func createCircularPath() {
//
//        self.backgroundColor = .clear
//        // This will adjust how long each dash (lineWidth) is depending on circle dimensions
//        // So smaller phones should have shorter lineWidth
//        let lineWidth = min(bounds.width, bounds.height) * 0.1
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.height / 2.0), startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
//        
//        // Track layer
//        trackLayer.path = circlePath.cgPath
//        trackLayer.fillColor = UIColor.clear.cgColor
//        trackLayer.strokeColor = UIColor.darkGray.cgColor
//        trackLayer.lineWidth = lineWidth
//        trackLayer.lineDashPattern = [3.0,4.0]
//        trackLayer.strokeEnd = 1.0
//        layer.addSublayer(trackLayer)
//        
//        // Progress layer
//        progressLayer.path = circlePath.cgPath
//        progressLayer.fillColor = UIColor.clear.cgColor
//        progressLayer.strokeColor = UIColor.white.cgColor
//        progressLayer.lineWidth = lineWidth
//        progressLayer.lineDashPattern = [3.0,4.0]
//        progressLayer.strokeEnd = 0.0 // Initially set to 0
//        layer.addSublayer(progressLayer)
//        
//    }
   //   new code for dash and gap aesthetics
    private func createCircularPath() {
        self.backgroundColor = .clear
        let radius = min(bounds.width, bounds.height) / 2.0
        let circumference = 2 * CGFloat.pi * radius
        let totalDashPatternLength = circumference / 100
        let dashLength = totalDashPatternLength * 0.3 // 30% dash, 70% gap
        let gapLength = totalDashPatternLength - dashLength

        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0),
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: 1.5 * CGFloat.pi,
            clockwise: true
        )
        
        let lineWidth = min(bounds.width, bounds.height) * 0.1
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.darkGray.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineDashPattern = [dashLength as NSNumber, gapLength as NSNumber]
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineDashPattern = [dashLength as NSNumber, gapLength as NSNumber]
        progressLayer.strokeEnd = 0.0 // Initially set to 0
        layer.addSublayer(progressLayer)
    }
    
    private func animateProgress(to value: CGFloat) {
        
        isAnimating = true
        
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2.75 // Total duration of the animation
        animationGroup.fillMode = .forwards // Freeze at the end
        animationGroup.isRemovedOnCompletion = false // Keep the final state
        animationGroup.beginTime = CACurrentMediaTime() + 1.0 //Delay animation start 1.0 seconds
        
        // Animation 1: Start from 0 and go to 1
        let animation1 = CABasicAnimation(keyPath: "strokeEnd")
        animation1.fromValue = 0.0
        animation1.toValue = 1.0
        animation1.duration = 0.75
        animation1.timingFunction = CAMediaTimingFunction(name: .easeIn)
        
        // Animation 2: Come back to the progress value
        let animation2 = CABasicAnimation(keyPath: "strokeEnd")
        animation2.fromValue = 1.0
        animation2.toValue = value
        animation2.beginTime = 0.75 // Start after the first animation
        animation2.duration = 2.0 // Use remaining duration
        animation2.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // Additional Animation: Toggle stroke color
        // If daily goal is met, the circular bar's color will appear and disappear repeatedly
        if value >= 1.0 {
            let colorAnimation = CAKeyframeAnimation(keyPath: "strokeColor")
            colorAnimation.values = [UIColor.white.cgColor, UIColor.red.cgColor, UIColor.white.cgColor]
            colorAnimation.keyTimes = [0, 0.5, 1] // Control the timing of color change
            colorAnimation.duration = 2.75 // Duration for one cycle of color transition
            colorAnimation.beginTime = CACurrentMediaTime() + 2.75 // Delay color animation until both progress animations are complete
            colorAnimation.repeatCount = .infinity // Repeat indefinitely
            
            animationGroup.animations = [animation1, animation2]
            progressLayer.add(animationGroup, forKey: "progressAnimationGroup")
            progressLayer.add(colorAnimation, forKey: "colorAnimation")
        } else {
            animationGroup.animations = [animation1, animation2]
            progressLayer.add(animationGroup, forKey: "progressAnimationGroup")
        }
    }
    // Method to animate quick color change when refreshing
    func animateQuickColorChange() {
        // Immediately hide the progress layer
        progressLayer.isHidden = true
        
        // Create a new layer for the inside white fade
        let insideLayer = CAShapeLayer()
        insideLayer.path = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.height / 2.0) - progressLayer.lineWidth / 2, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true).cgPath
        insideLayer.fillColor = UIColor.clear.cgColor
        insideLayer.strokeColor = UIColor.clear.cgColor
        insideLayer.lineWidth = 0
        layer.addSublayer(insideLayer)
        
        // Animate the fill color of the inside layer to white with 0.5 alpha and then back to clear
        let fillColorAnimation = CAKeyframeAnimation(keyPath: "fillColor")
        fillColorAnimation.values = [UIColor.clear.cgColor, UIColor.systemRed.withAlphaComponent(0.4).cgColor, UIColor.clear.cgColor]
        fillColorAnimation.keyTimes = [0, NSNumber(value: 0.05 / 0.8), 0.85] // Adjust timing to achieve 0.2s appearance and 1s fade out
        fillColorAnimation.duration = 0.85
        fillColorAnimation.fillMode = .forwards
        fillColorAnimation.isRemovedOnCompletion = false
        insideLayer.add(fillColorAnimation, forKey: "fillColorAnimation")
        
        // Remove the inside layer after the animation is complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.85) {
            insideLayer.removeFromSuperlayer()
            
            // Ensure progressLayer is visible before starting the progress animation
            self.progressLayer.isHidden = false
            
            // Trigger animateProgress after quick color change animation is complete
            self.animateProgress(to: self.progress)
        }
    }
}
