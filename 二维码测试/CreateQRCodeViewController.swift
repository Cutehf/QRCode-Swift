//
//  CreateQRCodeViewController.swift
//  二维码测试
//
//  Created by 黄飞 on 16/4/26.
//  Copyright © 2016年 黄飞. All rights reserved.


import UIKit

class CreateQRCodeViewController: UIViewController {

    
    private var codeImageView:UIImageView = {
        let codeImageView = UIImageView()
        codeImageView.frame=CGRect(x: 0, y: 0, width: 300, height: 300)
//        codeImageView.center = self.view.center
        return codeImageView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        let btn = UIButton(frame: CGRect(x: 30, y: 100, width: 100, height: 50))
        view.addSubview(btn)
        btn.backgroundColor=UIColor.redColor()
        btn.addTarget(self, action: "btnClick", forControlEvents: UIControlEvents.TouchUpInside)
        
            
        
        view.addSubview(codeImageView)
        codeImageView.center=view.center
        
          let myCodeImage = self.createQRCodeImageWithString("http://mp.weixin.qq.com/s?__biz=MzAxMzE2Mjc2Ng==&mid=402254522&idx=1&sn=1b617b8fd5ec4b5bc2d9ec77d669f3b1&scene=23&srcid=0316Cge6L2bpSZBalBc6D0Ut#rd", qrLogo: nil, size: 200.0, backColor: UIColor.whiteColor(), foreColor: UIColor.blackColor())
        codeImageView.image=myCodeImage
    }
    
    
    
        /**
         *  @brief  生成二维码图片
         *
         *  @param  生成二维码需要的字符串，文字或者网址
         *  @param  嵌套在二维码内的图标
         *  @param  二维码大小
         *  @param  二维码背景色
         *  @param  二维码前景色
         *
         *  @return 生成的二维码图片
         */
        func createQRCodeImageWithString(qrString: String?, qrLogo: UIImage?, size: CGFloat, backColor: UIColor, foreColor: UIColor) -> UIImage? {
            
            if let qrStr = qrString {
                let stringData = qrStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
                // 创建一个二维码滤镜
                let qrFiler = CIFilter(name: "CIQRCodeGenerator")
                qrFiler?.setValue(stringData, forKey: "inputMessage")
                // inputCorrectionLevel 容错级别
                // default: M  L: 7% M: 15% Q: 25% H: 30%
                qrFiler?.setValue("M", forKey: "inputCorrectionLevel")
                
                let qrCIImage = qrFiler?.outputImage
                // 创建颜色滤镜，黑白色
                let colorFilter = CIFilter(name: "CIFalseColor")
                colorFilter?.setDefaults()
                colorFilter?.setValue(qrCIImage, forKey: "inputImage")
                // 前景色
                colorFilter?.setValue(CIColor(color: foreColor), forKey: "inputColor0")
                // 背景色
                colorFilter?.setValue(CIColor(color: backColor), forKey: "inputColor1")
                
                let extent = CGRectIntegral(qrCIImage!.extent)
                let scale = (size / CGRectGetWidth(extent)) < (size / CGRectGetHeight(extent)) ? (size / CGRectGetWidth(extent)) : (size / CGRectGetHeight(extent))
                
                // 返回二维码图片
                let codeImage = UIImage(CIImage: (colorFilter?.outputImage!.imageByApplyingTransform(CGAffineTransformMakeScale(scale, scale)))!)
                
                // 给二维码图片添加logo
                if let logoImage = qrLogo {
                    let rect = CGRectMake(0, 0, codeImage.size.width, codeImage.size.height)
                    UIGraphicsBeginImageContext(rect.size)
                    codeImage.drawInRect(rect)
                    let logoSize = CGSizeMake(rect.size.width * 0.5, rect.size.height * 0.5)
                    logoImage.drawInRect(CGRectMake((rect.width - logoSize.width) * 0.5, (rect.height - logoSize.height) * 0.5, logoSize.width, logoSize.height))
                    let resultImage = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    
                    return resultImage
                }
                
                return codeImage
            }
            
            return nil
        }
   

    
    
    func btnClick(){
        dismissViewControllerAnimated(true, completion: nil)
    }
}
