import UIKit

class SegmentedProgressBar: UIView {
    
    private var segmentCount: Int = 5
    private var progress: CGFloat = 0.0
    private let segmentSpacing: CGFloat = 5.0
    
    func setSegments(count: Int) {
        self.segmentCount = count
        setNeedsDisplay()
    }
    
    func setProgress(_ progress: CGFloat) {
        self.progress = progress
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let segmentWidth = (rect.width - segmentSpacing * CGFloat(segmentCount - 1)) / CGFloat(segmentCount)
        let activeSegments = Int(progress * CGFloat(segmentCount))
        
        for i in 0..<segmentCount {
            let x = CGFloat(i) * (segmentWidth + segmentSpacing)
            
            if i < activeSegments {
                context.setFillColor(UIColor.blue.cgColor)
            } else {
                context.setFillColor(UIColor.gray.cgColor)
            }
            
            let segmentRect = CGRect(x: x, y: 0, width: segmentWidth, height: rect.height)
            context.fill(segmentRect)
        }
    }
}
