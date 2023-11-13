import UIKit

class CircularProgressView: UIView {
    
    private var backgroundLayer: CAShapeLayer!
    private var progressLayer: CAShapeLayer!
    
    var progress: CGFloat = 0 {
        didSet {
            DispatchQueue.main.async {
                self.progressLayer.strokeEnd = self.progress
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
    
    private func createCircularPath() {
        let circularPath = UIBezierPath(arcCenter: center, radius: bounds.size.width / 2, startAngle: -CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: true)
        
        backgroundLayer = CAShapeLayer()
        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.strokeColor = UIColor.lightGray.cgColor
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineWidth = 10
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)
        
        progressLayer = CAShapeLayer()
        progressLayer.path = circularPath.cgPath
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 10
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }
}
