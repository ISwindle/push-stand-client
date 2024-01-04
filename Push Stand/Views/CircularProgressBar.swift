import UIKit

class CircularProgressBar: UIView {

    private var progressLayer = CAShapeLayer()
    private var trackLayer = CAShapeLayer()
    private var blurLayer = CAShapeLayer()

    var progress: CGFloat = 0.25 {
        didSet {
            progressLayer.strokeEnd = progress
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
        trackLayer.lineWidth = 22.0
        trackLayer.lineDashPattern = [3,4.5] //100 lines
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)

        // Blurred layer - would be cool to have it rev to 100 then go back down to progress spot
        blurLayer.path = circlePath.cgPath
        blurLayer.fillColor = UIColor.clear.cgColor
        blurLayer.strokeColor = UIColor.blue.cgColor
        blurLayer.lineWidth = 22.0
        blurLayer.lineDashPattern = [3,4.5] //100 (blurred) lines behind progress layer
        blurLayer.strokeEnd = progress
        layer.addSublayer(blurLayer)
        //.blur I can't make work here, keep trying other ways.  Maybe you know the secret?
        
        // Progress layer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = 22.0
        progressLayer.lineDashPattern = [3,4.5] //100 lines
        progressLayer.strokeEnd = progress
        layer.addSublayer(progressLayer)
        
        
    }

}
