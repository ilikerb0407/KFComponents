//
//  File.swift
//  
//
//  Created by TWINB00591630 on 2023/6/9.
//

import UIKit

protocol DiscreteSliderDelegate: AnyObject {
    func discreteSlider(_ slider: DiscreteSlider, didSelectItemAtIndex index: Int)
}

class DiscreteSlider: UIControl {
    weak var delegate: DiscreteSliderDelegate?

    var options: [Int] = [] {
        didSet {
            updateTrackTicks()
            updateHandlePosition()
        }
    }

    var selectedItemIndex: Int = 0 {
        didSet {
            updateHandlePosition()
        }
    }

    private lazy var trackView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 4.0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var handleView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15.0
        view.layer.borderWidth = 2.0
        view.layer.borderColor = UIColor.systemBlue.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var trackTicks: [UIView] = []

    private var handlePositionConstraint: NSLayoutConstraint?

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 24.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        [trackView, handleView].forEach {
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            trackView.heightAnchor.constraint(equalToConstant: 8.0),

            handleView.widthAnchor.constraint(equalToConstant: 30.0),
            handleView.heightAnchor.constraint(equalToConstant: 30.0),
            handleView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        handleView.addGestureRecognizer(panGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateTrackTicks()
        updateHandlePosition()
    }

    private func updateTrackTicks() {
        trackTicks.forEach { $0.removeFromSuperview() }
        trackTicks.removeAll()

        let tickWidth: CGFloat = 14.0
        let trackWidth = bounds.width - handleView.bounds.width + 16

        for (index, _) in options.enumerated() {
            let tickView = UIView()
            tickView.backgroundColor = .lightGray
            tickView.translatesAutoresizingMaskIntoConstraints = false
            tickView.layer.cornerRadius = 7.0

            addSubview(tickView)

            NSLayoutConstraint.activate([
                tickView.widthAnchor.constraint(equalToConstant: tickWidth),
                tickView.heightAnchor.constraint(equalToConstant: tickWidth),
                tickView.centerYAnchor.constraint(equalTo: centerYAnchor),
                tickView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: (CGFloat(index) / CGFloat(options.count - 1)) * trackWidth),
            ])
            trackTicks.append(tickView)
        }
    }

    private func updateHandlePosition() {
        let trackWidth = bounds.width - handleView.bounds.width
        let position = (CGFloat(selectedItemIndex) / CGFloat(options.count - 1)) * trackWidth

        handlePositionConstraint?.isActive = false
        handlePositionConstraint = handleView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: position)
        handlePositionConstraint?.isActive = true

        sendActions(for: .valueChanged)
    }

    @objc
    private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let trackWidth = bounds.width - handleView.bounds.width
        let position = handleView.frame.origin.x + translation.x
        let clampedPosition = max(0, min(position, trackWidth))

        let step = trackWidth / CGFloat(options.count - 1)
        let index = Int(round(clampedPosition / step))

        if index != selectedItemIndex {
            selectedItemIndex = index
            delegate?.discreteSlider(self, didSelectItemAtIndex: index)
        }

        handleView.frame.origin.x = clampedPosition
        gesture.setTranslation(.zero, in: self)

        if gesture.state == .ended || gesture.state == .cancelled {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            feedbackGenerator.selectionChanged()

            // Animate handle view to the nearest tick view
            let nearestTickPosition = CGFloat(selectedItemIndex) * step
            UIView.animate(withDuration: 0.3) {
                self.handleView.frame.origin.x = nearestTickPosition
            }
        }
    }
}

