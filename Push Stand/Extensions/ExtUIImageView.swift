//
//  ExtUIImageView.swift
//  Push Stand
//
//  Created by Isaac Swindle on 1/20/24.
//

import UIKit

extension UIImageView {
    func convertToBlackAndWhite(image: UIImage) -> UIImage? {
            let context = CIContext(options: nil)
            if let filter = CIFilter(name: "CIColorControls") {
                filter.setValue(CIImage(image: image), forKey: kCIInputImageKey)
                filter.setValue(0.0, forKey: kCIInputSaturationKey) // Set saturation to 0 for black and white
                if let outputImage = filter.outputImage {
                    if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                        return UIImage(cgImage: cgImage)
                    }
                }
            }
            return nil
        }
}
