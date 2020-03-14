//
//  ShadowView.swift
//  Sunrise & Sunset
//
//  Created by Carl Burnham on 3/14/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit

class ShadowView: UIView {
    
    var shadowLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addShadow()
    }
    
    func addShadow() {
        shadowLayer?.removeFromSuperlayer()
        let shadowLayer = CAShapeLayer()
        shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.shadowColor = UIColor.black.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        shadowLayer.shadowOpacity = 0.2
        shadowLayer.shadowRadius = 2
        layer.insertSublayer(shadowLayer, at: 0)
        self.shadowLayer = shadowLayer
    }
}
