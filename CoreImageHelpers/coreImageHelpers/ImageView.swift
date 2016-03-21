//
//  ImageView.swift
//  CoreImageHelpers
//
//  Created by Simon Gladman on 09/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import GLKit
import UIKit
import MetalKit // Don't worry this error is because MetalKit is just available on real device ;)

/// `MetalImageView` extends an `MTKView` and exposes an `image` property of type `CIImage` to
/// simplify Metal based rendering of Core Image filters.

class MetalImageView: MTKView
{
    let colorSpace = CGColorSpaceCreateDeviceRGB()!
    
    lazy var commandQueue: MTLCommandQueue =
    {
        [unowned self] in
        
        return self.device!.newCommandQueue()
    }()
    
    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(MTLDevice: self.device!)
    }()
    
    override init(frame frameRect: CGRect, device: MTLDevice?)
    {
        super.init(frame: frameRect,
            device: device ?? MTLCreateSystemDefaultDevice())

        if super.device == nil
        {
            fatalError("Device doesn't support Metal")
        }
        
        framebufferOnly = false
    }

    required init(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The image to display
    var image: CIImage?
    {
        didSet
        {
            renderImage()
        }
    }
    
    func renderImage()
    {
        guard let
            image = image,
            targetTexture = currentDrawable?.texture else
        {
            return
        }
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let bounds = CGRect(origin: CGPointZero, size: drawableSize)
        
        let originX = image.extent.origin.x
        let originY = image.extent.origin.y
        
        let scaleX = drawableSize.width / image.extent.width
        let scaleY = drawableSize.height / image.extent.height
        let scale = min(scaleX, scaleY)
        
        let scaledImage = image
            .imageByApplyingTransform(CGAffineTransformMakeTranslation(-originX, -originY))
            .imageByApplyingTransform(CGAffineTransformMakeScale(scale, scale))
        
        ciContext.render(scaledImage,
            toMTLTexture: targetTexture,
            commandBuffer: commandBuffer,
            bounds: bounds,
            colorSpace: colorSpace)
        
        commandBuffer.presentDrawable(currentDrawable!)
        
        commandBuffer.commit()
    }
}

/// `OpenGLImageView` wraps up a `GLKView` and its delegate into a single class to simplify the
/// display of `CIImage`.
///
/// `OpenGLImageView` is hardcoded to simulate ScaleAspectFit: images are sized to retain their
/// aspect ratio and fit within the available bounds.
///
/// `OpenGLImageView` also respects `backgroundColor` for opaque colors

class OpenGLImageView: GLKView
{
    let eaglContext = EAGLContext(API: .OpenGLES2)
    
    lazy var ciContext: CIContext =
    {
        [unowned self] in
        
        return CIContext(EAGLContext: self.eaglContext,
            options: [kCIContextWorkingColorSpace: NSNull()])
    }()
    
    
    var openGLImageViewContentMode:OpenGLImageViewContentMode!
    
    override init(frame: CGRect)
    {
        super.init(frame: frame, context: eaglContext)
    
        context = self.eaglContext
        delegate = self
        openGLImageViewContentMode = OpenGLImageViewContentMode.AspectFill
    }

    override init(frame: CGRect, context: EAGLContext)
    {
        fatalError("init(frame:, context:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The image to display
    var image: CIImage?
    {
        didSet
        {
            setNeedsDisplay()
        }
    }
}

extension OpenGLImageView: GLKViewDelegate
{
    func glkView(view: GLKView, drawInRect rect: CGRect)
    {
        guard let image = image else
        {
            return
        }
   
        var targetRect:CGRect!
        switch self.openGLImageViewContentMode! {
        case .AspectFill :
            targetRect = image.extent.aspectFillInRect(
                target: CGRect(origin: CGPointZero,
                    size: CGSize(width: drawableWidth,
                        height: drawableHeight)))
        case .AspectFit:
            targetRect = image.extent.aspectFitInRect(
                target: CGRect(origin: CGPointZero,
                    size: CGSize(width: drawableWidth,
                        height: drawableHeight)))
        }
        
        let ciBackgroundColor = CIColor(
            color: backgroundColor ?? UIColor.whiteColor())
        
        ciContext.drawImage(CIImage(color: ciBackgroundColor),
            inRect: CGRect(x: 0,
                y: 0,
                width: drawableWidth,
                height: drawableHeight),
            fromRect: CGRect(x: 0,
                y: 0,
                width: drawableWidth,
                height: drawableHeight))
        
        ciContext.drawImage(image,
            inRect: targetRect,
            fromRect: image.extent)
    }
}

public enum OpenGLImageViewContentMode : Int {
    case AspectFill = 0
    case AspectFit = 1
}

