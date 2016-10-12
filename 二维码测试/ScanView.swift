//
//  ScanView.swift
//  二维码测试
//
//  Created by 黄飞 on 16/4/26.
//  Copyright © 2016年 黄飞. All rights reserved.
//

import UIKit

class ScanView: UIView {

    /// 扫描的区域的宽度
    var scanWidth:CGFloat = 300
    /// 扫描区域
    var scanCenterView:UIView?
    /// 扫描背景边框
    var scanBoard:UIImageView?
    /// 扫描的动态图片
    var scanImageView:UIImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        //-------------------------- 扫描区域的视图---------------------
        //添加扫描区域
        scanCenterView = UIView(frame: CGRect(x: 0, y: 0, width: scanWidth, height: scanWidth))
        scanCenterView?.center=center
        //超出部分剪去
        scanCenterView?.clipsToBounds=true
        addSubview(scanCenterView!)
        
        //扫描边框
        scanBoard=UIImageView(frame: CGRectMake(scanCenterView!.frame.origin.x-2, scanCenterView!.frame.origin.y-2, scanCenterView!.frame.size.width+3, scanCenterView!.frame.size.height+3))
//        scanBoard?.backgroundColor=UIColor.redColor()
        scanBoard?.image=UIImage(named: "qrcode_border")
        //超出部分剪去
        scanBoard?.clipsToBounds=true
        addSubview(scanBoard!)

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        //得到图形上下文
        let context=UIGraphicsGetCurrentContext()
        ///非扫码区域半透明
        CGContextSetRGBFillColor(context, 0, 0, 0, 0.5)
        
        let leftMargin = (frame.size.width-scanWidth)/2
        let topMargin = (frame.size.height-scanWidth)/2
        //填充矩形
        //扫码区域上面填充
        var rect = CGRectMake(0, 0, frame.size.width, topMargin)
        CGContextFillRect(context, rect)
        
        //扫码区域左边填充
        rect=CGRectMake(0, topMargin, leftMargin, frame.size.height-topMargin*2)
        CGContextFillRect(context, rect)
        
        //扫码区域右边填充
        rect=CGRectMake(leftMargin+scanWidth, topMargin, leftMargin, frame.size.height-topMargin*2)
        CGContextFillRect(context, rect)
        
        //扫码区域下面填充
        rect = CGRectMake(0, topMargin+scanWidth, frame.size.width,topMargin)
        CGContextFillRect(context, rect)
        //执行绘画
        CGContextStrokePath(context)
        
        
    }
    
    
    func startLineAnimation(){
        //扫描的图片背景
        scanImageView=UIImageView(frame: CGRect(x: 0, y: 0-scanCenterView!.frame.size.height, width: (scanCenterView?.frame.size.width)!, height: (scanCenterView?.frame.size.height)!))
        scanImageView?.image=UIImage(named: "qrcode_scanline_qrcode")
        //        scanImageView?.backgroundColor=UIColor.redColor()
        scanCenterView?.addSubview(scanImageView!)
        //
        startAnimation()
    }
    
    /**
     开始动画
     */
    private func startAnimation(){
        UIView.animateWithDuration(1.3) { () -> Void in
            
            UIView.setAnimationRepeatCount(MAXFLOAT)
            self.scanImageView?.frame=CGRectMake(self.scanImageView!.frame.origin.x, self.scanImageView!.frame.origin.y+self.scanCenterView!.frame.size.height+100, (self.scanImageView?.frame.size.width)!, (self.scanImageView?.frame.size.height)!)
            
        }
    }
    
    /**
     停止动画
     */
    func stopAnimation()
    {

        scanImageView?.removeFromSuperview()
    }

}
