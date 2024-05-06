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
    
    private func createCircularPath() {

        self.backgroundColor = .clear
        // This will adjust how long each dash (lineWidth) is depending on circle dimensions
        // So smaller phones should have shorter lineWidth
        let lineWidth = min(bounds.width, bounds.height) * 0.1
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.height / 2.0), startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        // Track layer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.darkGray.cgColor
        trackLayer.lineWidth = lineWidth
        trackLayer.lineDashPattern = [3.0,4.0]
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // Progress layer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.white.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineDashPattern = [3.0,4.0]
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
}
