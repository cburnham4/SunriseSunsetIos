//
//  GradientView.swift
//  Sunrise & Sunset
//
//  Created by Angel Colon-Ramirez on 7/16/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit


class GradientView: UIView {
    
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.startPoint = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        layer.colors = [ firstColor.cgColor, secondColor.cgColor]
        layer.locations = [NSNumber(value: 0.5), NSNumber(value: 0.35)]
        self.dropShadow()
    }
}

extension GradientView {
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowRadius = 0.0
        
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        
    }
}
