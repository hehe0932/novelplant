//
//  Extension+UIImage.swift
//  Moyi
//
//  Created by hehehe on 2023/4/14.
//

import Foundation
import UIKit

extension UIImage {
    /**
     *  重设图片大小
     */
    func reSizeImage(reSize: CGSize ) -> UIImage  {
        UIGraphicsBeginImageContextWithOptions (reSize, false , 0.0);
        draw(in: CGRectMake (0, 0, reSize.width, reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext () ?? UIImage()
        UIGraphicsEndImageContext()
        return  reSizeImage
    }
    
    /**
     *  等比率缩放
     */
    func scaleImage(scaleSize: CGFloat )-> UIImage  {
        let reSize =  CGSizeMake ( self .size.width * scaleSize,  self .size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
    /// 压缩到最大宽高 和指定大小 byte
    func compressToDataWith(maxWH:CGFloat, maxSize:Int) -> UIImage{
        var wh = maxWH
        if maxWH <= 0{
            wh = 2048
        }
        
        var newSize = self.size
        let tmpH = newSize.height/wh
        let tmpW = newSize.width/wh
        if tmpH > 0 && tmpW > tmpH{
            newSize = CGSize(width: self.size.width/tmpW, height: self.size.height/tmpW)
        }else if tmpH > 1.0 && tmpW < tmpH{
            newSize = CGSize(width: self.size.width/tmpH, height: self.size.height/tmpH)
        }
        UIGraphicsBeginImageContext(newSize)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImg = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let img = newImg?.compressImageMidToImg(maxLength: maxSize){
            return img
        }
        
        return self
    }
    
    /// 二分压缩法图片 img
    func compressImageMidToImg(maxLength: Int) -> UIImage {
        if let data = self.compressImageMid(maxLength: maxLength), let img = UIImage(data: data){
            return img
        }
        return self
    }
    /// 二分压缩法图片 data
    func compressImageMid(maxLength: Int) -> Data? {
        var compression: CGFloat = 1
        guard var data = self.jpegData(compressionQuality: 1) else { return nil }
        print("压缩前kb: \( Double((data.count)/1024))")
        if data.count < maxLength {
            return data
        }
        print("压缩前kb", data.count / 1024, "KB")
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = self.jpegData(compressionQuality: compression)!
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        if data.count < maxLength {
            print("压缩后kb", data.count / 1024, "KB")
            return data
        }
        print("压缩后kb", data.count / 1024, "KB")
        return data
    }
    
    /// 压缩图片
    /// - Parameter maxLength: 最大字节数 如：需要500kb 传0.5
    /// - Returns: 压缩后的图片data
    func compressWithMaxLength(maxLength: Float) -> Data? {
        let maxValue:Int = Int(maxLength * 1024 * 1024)//最大字节数
        var compressionQuality:CGFloat = 1
        var compressData:Data? = self.jpegData(compressionQuality: compressionQuality)
        var max:CGFloat = 1
        var min:CGFloat = 0
        if let data = compressData, data.count < maxValue{
            return compressData//原图大小少于所需大小直接返回
        }
        for _ in 0 ... 6 {
            compressionQuality = (max + min) * 0.5
            if let data:Data = self.jpegData(compressionQuality: compressionQuality){
                compressData = data
                if Float(data.count) < Float(maxValue) * 0.9 {
                    min = compressionQuality  // 缩小压缩比例
                }else if data.count > maxValue {
                    max = compressionQuality  // 扩大压缩比例
                }else{
                    break
                }
            }
        }
        
        if let data = compressData, data.count > maxValue{//压缩质量后大小还是不符合再进行尺寸压缩
            var resultImage: UIImage = self
            var resultData: NSData = NSData(data: data)
            var lastLength: Int = 0
            //条件：生成的图片大小是否满足所需大小
            while resultData.length > maxValue, resultData.length != lastLength{
                lastLength = resultData.length
                let route: CGFloat = CGFloat(maxValue) / CGFloat(lastLength)
                let width: CGFloat = resultImage.size.width * CGFloat(sqrtf(Float(route)))
                let height: CGFloat = resultImage.size.height * CGFloat(sqrtf(Float(route)))
                let size: CGSize = CGSize(width: width, height: height)
                //压缩尺寸并生成新的图片
                UIGraphicsBeginImageContext(size)
                resultImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
                resultImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage.init()
                UIGraphicsEndImageContext()
                if let data = resultImage.jpegData(compressionQuality: 1) {
                    resultData = NSData(data: data)
                }
            }
            return resultData as Data
        }else{
            //压缩质量后大小符合 直接返回
            return compressData
        }
    }
    
    var mostProminentColor: UIColor? {
        guard let cgImage = cgImage else { return nil } // 确保有有效的 CGImage
        
        // 设置颜色空间为 sRGB，用于后续的颜色提取
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // 选择采样点数量和位置，这里假设取图片中心点作为代表色
        let sampleCount = 1
        let sampleRect = CGRect(x: Int(size.width / 2), y: Int(size.height / 2), width: 1, height: 1)
        
        // 创建像素数据缓冲区
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * Int(sampleRect.width)
        let bitmapByteCount = bytesPerRow * Int(sampleRect.height)
        let bitmapData = UnsafeMutablePointer<UInt8>.allocate(capacity: bitmapByteCount)
        defer { bitmapData.deallocate() }
        
        // 将图片数据复制到缓冲区
        let context = CGContext(data: bitmapData,
                                width: Int(sampleRect.width),
                                height: Int(sampleRect.height),
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        context?.draw(cgImage, in: CGRect(origin: CGPoint.zero, size: size))
        
        // 解析缓冲区中的颜色数据
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 1.0
        for i in 0..<sampleCount {
            let offset = bytesPerPixel * (i * bytesPerRow)
            red += CGFloat(bitmapData[offset]) / 255.0
            green += CGFloat(bitmapData[offset + 1]) / 255.0
            blue += CGFloat(bitmapData[offset + 2]) / 255.0
            alpha += CGFloat(bitmapData[offset + 3]) / 255.0
        }
        red /= CGFloat(sampleCount)
        green /= CGFloat(sampleCount)
        blue /= CGFloat(sampleCount)
        alpha /= CGFloat(sampleCount)
        
        // 返回 UIColor 对象
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
}
