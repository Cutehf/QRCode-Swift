//
//  CustomButton.swift
//  二维码测试
//
//  Created by 黄飞 on 16/4/26.
//  Copyright © 2016年 黄飞. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let frame = self.frame
        let path = UIBezierPath(arcCenter: CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5), radius: frame.size.width * 0.5, startAngle: 0, endAngle: CGFloat(M_PI * 2.0), clockwise: true)
        let layer = CAShapeLayer()
        layer.lineWidth = 1.0
        layer.fillColor = UIColor.clearColor().CGColor
        layer.strokeColor = UIColor.whiteColor().CGColor
        layer.path = path.CGPath
        self.layer.addSublayer(layer)
    }
}
