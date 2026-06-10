//
//  CMSampleBuffer+Extension.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 10/06/26.
//

import AVFoundation
import CoreImage

extension CMSampleBuffer {
    
    var cgImage: CGImage? {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(self)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return nil
        }
        
        return CIImage(cvPixelBuffer: imagePixelBuffer).cgImage
    }
    
}

