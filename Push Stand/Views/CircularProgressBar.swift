import UIKit

class CircularProgressBar: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()

    var progress: CGFloat = 0.0 {
        didSet {
            animateProgress(to: progress)
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

    private func createCircularPath() {
        self.backgroundColor = .clear
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.width - 1.5) / 2, startAngle: -CGFloat.pi / 2, endAngle: 1.5 * CGFloat.pi, clockwise: true)
        
        // Track layer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.darkGray.cgColor
        trackLayer.lineWidth = 20.0
        trackLayer.lineDashPattern = [2,4.0]
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)
        
        // Progress layer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = 20.0
        progressLayer.lineDashPattern = [2,4.0]
        progressLayer.strokeEnd = 0.0 // Initially set to 0
        layer.addSublayer(progressLayer)
        
        animateProgress(to: progress) // Start the animation when the view is loaded
    }
    
    private func animateProgress(to value: CGFloat) {
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
        
        animationGroup.animations = [animation1, animation2]
        progressLayer.add(animationGroup, forKey: "strokeEndAnimation")
        
    }
}
