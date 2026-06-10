//
//  CIImage+Extension.swift
//  CaregiverApp
//
//  Created by Christopher Jonathan on 10/06/26.
//

import CoreImage

extension CIImage {
    
    var cgImage: CGImage? {
        let ciContext = CIContext()
        
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else {
            return nil
        }
        
        return cgImage
    }
    
}
