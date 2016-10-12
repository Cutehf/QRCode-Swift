//
//  ViewController.swift
//  二维码测试
//
//  Created by 黄飞 on 16/4/25.
//  Copyright © 2016年 黄飞. All rights reserved.
//

import UIKit
import AVFoundation


let bottomViewHeight: CGFloat = 100.0
let bottomBtnSize: CGFloat = 60.0
let bottomBtnTag: Int = 4000


class ViewController: UIViewController {

    
    /// 扫描视图
    var scanView:ScanView!
    
    let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)

    
    // MARK: - 懒加载
    private lazy var input: AVCaptureDeviceInput? = {
//        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        return try? AVCaptureDeviceInput(device: self.device)
    }()
    // 会话
    private lazy var session : AVCaptureSession = AVCaptureSession()
    // 创建预览图层
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.frame = UIScreen.mainScreen().bounds
        return layer
    }()
    
    private lazy var output:AVCaptureMetadataOutput = {
      
        let out = AVCaptureMetadataOutput()
        
        let viewRect = self.view.frame
        // 扫描区域 （也是扫描框的frame）
        let scanRect = self.scanView.scanCenterView?.frame
        
        let x = scanRect!.origin.y / viewRect.height;
        let y = scanRect!.origin.x / viewRect.width;
        let width = scanRect!.height / viewRect.height;
        let height = scanRect!.width / viewRect.width;
        // 设置可探测区域
        // rectOfInterset设置： CGRectMake(扫描区域y的起点/屏幕的高度, 扫描区域的x/屏幕的宽度, 扫描区域的高/屏幕的高, 扫描区域的宽度/屏幕的宽度)
        out.rectOfInterest = CGRect(x: x, y: y, width: width, height: height)
        
        return out
    }()

    private lazy var containerLayer:CALayer = CALayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.


        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterBack", name: UIApplicationWillResignActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "enterForeground", name: UIApplicationDidBecomeActiveNotification, object: nil)
//
        scanView = ScanView(frame:view.frame)
        scanView.addSubview(UIView())
        scanView.backgroundColor=UIColor.clearColor()
        view.addSubview(scanView)
        
        setupBottomButton()
        
        scanQRCode()
        
}
    
    /// 设置底部的按钮
    func setupBottomButton() {
        
        let bottomView = UIView(frame: CGRectMake(0, view.frame.height - bottomViewHeight, view.frame.width, bottomViewHeight))
        bottomView.backgroundColor = UIColor.redColor()
        view.addSubview(bottomView)
        
        // 底部button
        let borderX = (view.frame.size.width - bottomBtnSize * 3.0) / 4.0
        let titleArray: [String] = ["相册", "开灯", "二维码"]
        
        for i in 0..<3 {
            let cusBtn = CustomButton()
            cusBtn.frame = CGRectMake(borderX + CGFloat(i) * (borderX + bottomBtnSize), (bottomView.frame.height - bottomBtnSize) * 0.5, bottomBtnSize, bottomBtnSize)
            cusBtn.tag = bottomBtnTag + i
            cusBtn.setTitle(titleArray[i], forState: UIControlState.Normal)
            cusBtn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            cusBtn.titleLabel?.textAlignment = NSTextAlignment.Center
            cusBtn.titleLabel?.font = UIFont.systemFontOfSize(16.0)
            cusBtn.addTarget(self, action: "bottomButtonClick:", forControlEvents: .TouchUpInside)
            bottomView.addSubview(cusBtn)
        }
    }

    func bottomButtonClick(button: CustomButton) {
        switch button.tag - bottomBtnTag {
        case 0:
            self.openAlbum()
        case 1:
            self.openLight()
        case 2:
            self.createMyQRCode()
        default:
            break
        }
    }
    
    // 打开相册
    func openAlbum() {
        let queue = NSOperationQueue.mainQueue()
        queue.addOperationWithBlock { [weak self]() -> Void in
            if let weakSelf = self {
                weakSelf.openAlbumWithQueue()
            }
        }
    }
    
    // 打开相册
    func openAlbumWithQueue() {
        // 判断是否支持图片库
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing=true
            self.presentViewController(imagePicker, animated: true, completion: { () -> Void in
                
            })
        }else {
            print("读取相册错误!")
        }
    }

    
    func isGetFlash()->Bool
    {
        if (device != nil &&  device!.hasFlash && device!.hasTorch)
        {
            return true
        }
        return false
    }

    
    // 打开闪光灯
    func openLight() {
        
        if isGetFlash()
        {
            do
            {
                try input?.device.lockForConfiguration()
                
                var torch = false
                
                if input?.device.torchMode == AVCaptureTorchMode.On
                {
                    torch = false
                }
                else if input?.device.torchMode == AVCaptureTorchMode.Off
                {
                    torch = true
                }
                
                input?.device.torchMode = torch ? AVCaptureTorchMode.On : AVCaptureTorchMode.Off
                
                input?.device.unlockForConfiguration()
            }
            catch let error as NSError {
                print("device.lockForConfiguration(): \(error)")
                
            }
        }
    }
    
    
    
    func createMyQRCode(){
            presentViewController(CreateQRCodeViewController(), animated: true, completion: nil)
    }

    /**
        进入后台
     */
    func enterBack(){
        session.stopRunning()
        scanView.stopAnimation()
    }
    
    /**
        进入前台
     */
    func enterForeground(){
        
        session.startRunning()
        scanView.startLineAnimation()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        session.startRunning()
        scanView.startLineAnimation()
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        session.stopRunning()
        scanView.stopAnimation()
    }
    
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
         初始化二维码
     */
    private func scanQRCode(){
        
        // 1.判断输入能否添加到会话中
        if !session.canAddInput(input){
            return
        }
        
        // 2.判断输出能够添加到会话中
        if !session.canAddOutput(output)
        {
            return
        }
        // 3.添加输入和输出到会话中
        session.addInput(input)
        session.addOutput(output)
        
        
        // 4.设置输出能够解析的数据类型
        // 注意点: 设置数据类型一定要在输出对象添加到会话之后才能设置
//        output.metadataObjectTypes =
//            [AVMetadataObjectTypeQRCode,
//                AVMetadataObjectTypeCode39Code,
//                AVMetadataObjectTypeCode128Code,
//                AVMetadataObjectTypeCode93Code,
//                AVMetadataObjectTypeCode39Mod43Code,
//                AVMetadataObjectTypeEAN8Code,
//                AVMetadataObjectTypeEAN13Code]
        output.metadataObjectTypes = output.availableMetadataObjectTypes
        
        // 5.设置监听监听输出解析到的数据
        output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
        
        // 6.添加预览图层
        view.layer.insertSublayer(previewLayer, atIndex: 0)
        previewLayer.frame = view.bounds
        
        // 7.添加容器图层
        view.layer.addSublayer(containerLayer)
        containerLayer.frame = view.bounds
        
        // 8.开始扫描
        session.startRunning()
        
    }
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ViewController : AVCaptureMetadataOutputObjectsDelegate{
    /// 只要扫描到结果就会调用
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        // 1.显示结果

        print("-----扫描到的------");
        let alertView = UIAlertView(title:"", message: "", delegate: self, cancelButtonTitle: "确定")
        if metadataObjects.count>0 {
            let metadataObject = metadataObjects.last
            
            if metadataObject!.isKindOfClass(AVMetadataMachineReadableCodeObject) {
                
                let code = metadataObject as! AVMetadataMachineReadableCodeObject
                
                print(code)
                //码类型  Code128  QRCode
                print("码类型\(code.type)")
                //码内容
                print("码内容\(code.stringValue)")
                
                alertView.message=code.stringValue
                alertView.show()
                
                 //4个字典，分别 左上角-右上角-右下角-左下角的 坐标百分百，可以使用这个比例抠出码的图像  code.corners
                
//                UIApplication.sharedApplication().openURL(NSURL(string: code.stringValue)!)
                scanView.stopAnimation()
                session.stopRunning()
               
            }
        }
        
//        customLabel.text =  metadataObjects.last?.stringValue
       /*
        clearLayers()
        
        // 2.拿到扫描到的数据
        guard let metadata = metadataObjects.last as? AVMetadataObject else
        {
            return
        }
        // 通过预览图层将corners值转换为我们能识别的类型
        let objc = previewLayer.transformedMetadataObjectForMetadataObject(metadata)
        // 2.对扫描到的二维码进行描边
        drawLines(objc as! AVMetadataMachineReadableCodeObject)
    }
    
    /// 绘制描边
    private func drawLines(objc: AVMetadataMachineReadableCodeObject)
    {
        
        // 0.安全校验
        guard let array = objc.corners else
        {
            return
        }
        
        // 1.创建图层, 用于保存绘制的矩形
        let layer = CAShapeLayer()
        layer.lineWidth = 2
        layer.strokeColor = UIColor.greenColor().CGColor
        layer.fillColor = UIColor.clearColor().CGColor
        
        // 2.创建UIBezierPath, 绘制矩形
        let path = UIBezierPath()
        var point = CGPointZero
        var index = 0
        CGPointMakeWithDictionaryRepresentation((array[index++] as! CFDictionary), &point)
        
        // 2.1将起点移动到某一个点
        path.moveToPoint(point)
        
        // 2.2连接其它线段
        while index < array.count
        {
            CGPointMakeWithDictionaryRepresentation((array[index++] as! CFDictionary), &point)
            path.addLineToPoint(point)
        }
        // 2.3关闭路径
        path.closePath()
        
        layer.path = path.CGPath
        // 3.将用于保存矩形的图层添加到界面上
        containerLayer.addSublayer(layer)
    }
    
    /// 清空描边
    private func clearLayers()
    {
        guard let subLayers = containerLayer.sublayers else
        {
            return
        }
        for layer in subLayers
        {
            layer.removeFromSuperlayer()
        }
        */
        
    }

}

////MARK:- UITabBarDelegate
//extension ViewController:UITabBarDelegate
//{
//   
//    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        //扫描边框的frame动画变化
//        if (tabBar.selectedItem == scanTabBar.items?.first){
//            UIView.animateWithDuration(0.5) { () -> Void in
//                self.scanBoard?.frame = self.scanView!.frame
//                self.scanBoard?.center = self.view.center;
//                self.scanImageView?.image = UIImage(named: "qrcode_scanline_qrcode")
//            }
//        }else{
//            UIView.animateWithDuration(0.5) { () -> Void in
//                self.scanBoard?.frame = CGRectMake(self.scanBoard!.frame.origin.x, self.scanBoard!.frame.origin.y, self.scanBoard!.frame.size.width, self.scanBoard!.frame.size.width/2)
//                self.scanBoard?.center = self.view.center;
//                self.scanImageView?.image = UIImage(named: "qrcode_scanline_barcode")
//                
//            }
//        }
//    }
//}

 //MARK: -----相册选择图片识别二维码 （条形码没有找到系统方法）
extension ViewController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
//        picker.dismissViewControllerAnimated(true, completion: nil)
        
        var image:UIImage? = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if (image == nil )
        {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }

        
        if(image != nil)
        {
            // 读取二维码
            let ciImage = CIImage(image: image!)
            let context = CIContext(options: nil)
            let detector: CIDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
            let features:[CIFeature]? = detector.featuresInImage(ciImage!)
            
            //        var messageArr = [String]()
            
            // 关闭图片选择控制器
            picker.dismissViewControllerAnimated(true) { () -> Void in
                
            }
            
            let alertView = UIAlertView(title:"", message: "", delegate: nil, cancelButtonTitle: "确定")
            if( features != nil && features?.count > 0){
                
                let feature = features![0]
                
                
                if feature.isKindOfClass(CIQRCodeFeature){
                    
                    let featureTmp:CIQRCodeFeature = feature as! CIQRCodeFeature
                    let message = featureTmp.messageString
                    
                    alertView.message=message
                    alertView.show()
                    // 判断是否是网址
//                    if message.hasPrefix("http://") || message.hasPrefix("https://") {
//                        // 浏览器打开网址
//                        UIApplication.sharedApplication().openURL(NSURL(string: message)!)
//                    }
                }
            }else{
            
                alertView.message="未识别"
                alertView.show()
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // 取消照片选择
        picker.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
}



extension ViewController:UIAlertViewDelegate{
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        session.startRunning()
    }
}

