import UIKit
import Vision

enum ImageSubjectCutter {
    static func cutForegroundSubject(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
                guard let result = request.results?.first else {
                    completion(nil)
                    return
                }

                // Generate mask pixel buffer using standard VNInstanceMaskObservation API
                let pixelBuffer = try result.generateScaledMaskForImage(
                    forInstances: result.allInstances,
                    from: handler
                )

                let maskCI = CIImage(cvPixelBuffer: pixelBuffer)
                let originalCI = CIImage(cgImage: cgImage)

                // Blend original image using mask as alpha map
                let filter = CIFilter(name: "CIBlendWithMask")
                filter?.setValue(originalCI, forKey: kCIInputImageKey)
                filter?.setValue(maskCI, forKey: kCIInputMaskImageKey)

                guard let outputCI = filter?.outputImage else {
                    completion(nil)
                    return
                }

                let context = CIContext(options: nil)
                if let finalCGImage = context.createCGImage(outputCI, from: originalCI.extent) {
                    let croppedImage = UIImage(cgImage: finalCGImage, scale: image.scale, orientation: image.imageOrientation)
                    completion(croppedImage)
                } else {
                    completion(nil)
                }
            } catch {
                print("Failed to perform foreground instance cutout request: \(error)")
                completion(nil)
            }
        }
    }
}
