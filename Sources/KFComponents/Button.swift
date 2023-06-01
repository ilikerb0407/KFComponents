//
//  File.swift
//  
//
//  Created by TWINB00591630 on 2023/6/1.
//

import UIKit

internal class Checkbox: UIButton {
    private let size: CGFloat = 30
    var callBack: (() -> Void)?

    var isOn: Bool = false {
        didSet {
            if #available(iOS 13.0, *) {
                self.setBackgroundImage(isOn ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    func setup() {
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: size),
            self.heightAnchor.constraint(equalToConstant: size),
        ])
        self.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        if #available(iOS 13.0, *) {
            self.setBackgroundImage(isOn ? UIImage(systemName: "checkmark.square.fill") : UIImage(systemName: "square"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
    }

    @objc
    func handleTap(_: UIButton) {
        isOn.toggle()
        callBack?()
    }
}
