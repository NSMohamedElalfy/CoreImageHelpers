//
//  ViewController.swift
//  CoreImageHelpers
//
//  Created by Simon Gladman on 09/01/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CameraCaptureHelperDelegate
{
    let imageView = OpenGLImageView() //  MetalImageView()

    let cameraCaptureHelper = CameraCaptureHelper(cameraPosition: .Front)
    
    let halftone = CIFilter(name: "CICMYKHalftone",
        withInputParameters: nil)!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
     
        // this is default value of content mode
        //self.imageView.openGLImageViewContentMode = .AspectFill
        
        // or
        //self.imageView.openGLImageViewContentMode = .AspectFit
        
        view.addSubview(imageView)

        cameraCaptureHelper.delegate = self
    }
    
    override func viewDidLayoutSubviews()
    {
        imageView.frame = view.bounds
    }

    
    func newCameraImage(cameraCaptureHelper: CameraCaptureHelper, image: CIImage)
    {
        let inputImage = image.imageByApplyingTransform(cameraCaptureHelper.cameraPosition.transform)
        
        halftone.setValue(inputImage, forKey: kCIInputImageKey)
        
        imageView.image = halftone.outputImage
    }
}

