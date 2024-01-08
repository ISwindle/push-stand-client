import UIKit

class SegmentedBar: UIView {

    var value: Int = 0 {
        didSet {
            updateBar()
        }
    }
    var maximum: Int = 10
    var segmentWidth: CGFloat = 25
    var segmentHeight: CGFloat = 0
    var spacing: CGFloat = 2
    var selectedColor: UIColor = .red
    var unselectedColor: UIColor = .darkGray

    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBar()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupBar()
    }
    
    private func setupBar() {
        addSubview(stackView)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = spacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        createSegments()
    }

    private func createSegments() {
        for _ in 0..<maximum {
            let segment = UIView()
            segment.backgroundColor = unselectedColor
            segment.layer.cornerRadius = (segmentHeight / 2)
            stackView.addArrangedSubview(segment)
            segment.widthAnchor.constraint(equalToConstant: segmentWidth).isActive = true
        }
        updateBar()
    }

    private func updateBar() {
        for (index, segment) in stackView.arrangedSubviews.enumerated() {
            segment.backgroundColor = index < value ? selectedColor : unselectedColor
        }
    }
}
