//
//  GradientView.swift
//  Sunrise & Sunset
//
//  Created by Angel Colon-Ramirez on 7/16/20.
//  Copyright © 2020 LetsHangLLC. All rights reserved.
//

import UIKit

@IBDesignable
class GradientView: UIView {

    @IBInspectable var FirstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var SecondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var DropShadow: Bool = false {
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
        layer.colors = [ FirstColor.cgColor, SecondColor.cgColor]
        layer.locations = [NSNumber(value: 0.5), NSNumber(value: 0.35)]
        
        if DropShadow {//Make a drop shadow

            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOpacity = 1
            layer.shadowOffset = CGSize(width: 4, height: 4)
            layer.shadowRadius = 3

            layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        }
    }
}
