import UIKit

extension UIImageView {
    /// Converts the given image to black and white.
    /// - Parameter image: The image to be converted.
    /// - Returns: A new UIImage in black and white, or nil if the conversion fails.
    static func convertToBlackAndWhite(image: UIImage) -> UIImage? {
        let context = CIContext(options: nil)
        guard let filter = CIFilter(name: "CIColorControls"),
              let ciImage = CIImage(image: image) else {
            return nil
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(0.0, forKey: kCIInputSaturationKey) // Set saturation to 0 for black and white
        
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}
