//
//  Extensions.swift
//  CoreImageHelpers
//
//  Created by Mohamed El-Alfy on 3/21/16.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

extension CGAffineTransform {
    
    init(rotatingWithAngle angle: CGFloat) {
        let t = CGAffineTransformMakeRotation(angle)
        self.init(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        
    }
    init(scaleX sx: CGFloat, scaleY sy: CGFloat) {
        let t = CGAffineTransformMakeScale(sx, sy)
        self.init(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        
    }
    
    func scale(sx: CGFloat, sy: CGFloat) -> CGAffineTransform {
        return CGAffineTransformScale(self, sx, sy)
    }
    func rotate(angle: CGFloat) -> CGAffineTransform {
        return CGAffineTransformRotate(self, angle)
    }
}

extension CIImage {
    convenience init(buffer: CMSampleBuffer) {
        self.init(CVPixelBuffer: CMSampleBufferGetImageBuffer(buffer)!)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    func aspectFitInRect(target target: CGRect) -> CGRect
    {
        let scale: CGFloat =
        {
            let scale = target.width / self.width
            
            return self.height * scale <= target.height ?
                scale :
                target.height / self.height
        }()
        
        let width = self.width * scale
        let height = self.height * scale
        let x = target.midX - width / 2
        let y = target.midY - height / 2
        
        return CGRect(x: x,
            y: y,
            width: width,
            height: height)
    }
    
    
    func aspectFillInRect(target target: CGRect) -> CGRect
    {
        
        let fromAspectRatio = self.size.width / self.size.height;
        let toAspectRatio = target.size.width / target.size.height;
        
        var fillRect = target
        
        if (fromAspectRatio > toAspectRatio) {
            fillRect.size.width = target.size.height  * fromAspectRatio;
            fillRect.origin.x += (target.size.width - fillRect.size.width) * 0.5;
        } else {
            fillRect.size.height = target.size.width / fromAspectRatio;
            fillRect.origin.y += (target.size.height - fillRect.size.height) * 0.5;
        }
        
        return fillRect
    }
}

extension AVCaptureDevicePosition {
    var transform: CGAffineTransform {
        switch self {
        case .Front:
            return CGAffineTransform(rotatingWithAngle: -CGFloat(M_PI_2)).scale(1, sy: -1)
        case .Back:
            return CGAffineTransform(rotatingWithAngle: -CGFloat(M_PI_2))
        default:
            return CGAffineTransformIdentity
            
        }
    }
    
    var device: AVCaptureDevice? {
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).filter {
            $0.position == self
            }.first as? AVCaptureDevice
    }
}
