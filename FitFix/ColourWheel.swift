import UIKit
import CoreImage

// MARK: - ColorCategory Enum

enum ColorCategory: String, CaseIterable {
    case red, orange, yellow, lime, green, teal, cyan, skyBlue, blue, purple, magenta, pink, black, white, gray, multiColor
    
    var angleRange: (start: Int, end: Int)? {
        switch self {
        case .red: return (0, 30)
        case .orange: return (30, 60)
        case .yellow: return (60, 90)
        case .lime: return (90, 120)
        case .green: return (120, 150)
        case .teal: return (150, 180)
        case .cyan: return (180, 210)
        case .skyBlue: return (210, 240)
        case .blue: return (240, 270)
        case .purple: return (270, 300)
        case .magenta: return (300, 330)
        case .pink: return (330, 360)
        case .black: return (-1, -1) // Special range for black
        default: return nil // White, gray, multi-color
        }
    }
}

// MARK: - ColorWheel Class

class ColorWheel {
    // Extract dominant color from an image
    static func extractDominantColor(from image: UIImage) -> ColorCategory {
        guard let dominantColor = ColorExtractor.extractDominantColor(from: image) else {
            return .black // Fallback to a valid ColorCategory
        }
        return dominantColor.toColorCategory()
    }
    
    // Check if colors are harmonious
    static func isHarmonious(shirt: ColorCategory, pants: ColorCategory, shoes: ColorCategory) -> Bool {
        // Neutral colors (black, white, gray) are always harmonious
        if shirt == .black || pants == .black || shoes == .black {
            return true
        }
        
        // Get the hue angles for each color
        guard let shirtAngle = calculateColorAngle(for: shirt),
              let pantsAngle = calculateColorAngle(for: pants),
              let shoesAngle = calculateColorAngle(for: shoes) else {
            return false // Neutral colors are always harmonious
        }
        
        // Check for complementary colors (180° apart)
        if abs(shirtAngle - pantsAngle) == 180 {
            return true
        }
        
        // Check for triadic colors (120° apart)
        if abs(shirtAngle - pantsAngle) == 120 && abs(pantsAngle - shoesAngle) == 120 {
            return true
        }
        
        // Add more color harmony rules as needed
        
        return false
    }
    
    // Calculate the midpoint of the color's hue range
    private static func calculateColorAngle(for color: ColorCategory) -> Int? {
        guard let range = color.angleRange else { return nil }
        return (range.start + range.end) / 2 // Return the midpoint of the angle range
    }
}

// MARK: - ColorExtractor Class

class ColorExtractor {
    static func extractDominantColor(from image: UIImage) -> UIColor? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Create a CIImage from the CGImage
        let ciImage = CIImage(cgImage: cgImage)
        
        // Create a CIContext
        let context = CIContext(options: nil)
        
        // Create a histogram filter
        let filter = CIFilter(name: "CIAreaHistogram")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(CIVector(cgRect: ciImage.extent), forKey: kCIInputExtentKey)
        
        // Apply the filter
        guard let outputImage = filter.outputImage else { return nil }
        
        // Render the output image
        guard let histogramData = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        // Convert the histogram data to a pixel buffer
        let width = histogramData.width
        let height = histogramData.height
        let bitsPerComponent = 8
        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        let context2 = CGContext(data: &pixelData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)!
        context2.draw(histogramData, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // Find the dominant color
        var colorCounts = [UIColor: Int]()
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let r = CGFloat(pixelData[i]) / 255.0
            let g = CGFloat(pixelData[i + 1]) / 255.0
            let b = CGFloat(pixelData[i + 2]) / 255.0
            let a = CGFloat(pixelData[i + 3]) / 255.0
            
            let color = UIColor(red: r, green: g, blue: b, alpha: a)
            colorCounts[color] = (colorCounts[color] ?? 0) + 1
        }
        
        // Find the color with the highest count
        let dominantColor = colorCounts.max { $0.value < $1.value }?.key
        return dominantColor
    }
}

// MARK: - UIColor Extension
extension UIColor {
    func toColorCategory() -> ColorCategory {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert RGB to HSV
        let hsv = rgbToHsv(red: red, green: green, blue: blue)
        let hue = hsv.h * 360 // Convert hue to degrees
        
        // Map hue to a color category
        switch hue {
        case 0..<30: return .red
        case 30..<60: return .orange
        case 60..<90: return .yellow
        case 90..<120: return .lime
        case 120..<150: return .green
        case 150..<180: return .teal
        case 180..<210: return .cyan
        case 210..<240: return .skyBlue
        case 240..<270: return .blue
        case 270..<300: return .purple
        case 300..<330: return .magenta
        case 330..<360: return .pink
        default: return .black // Fallback for neutral colors
        }
    }
    
    private func rgbToHsv(red: CGFloat, green: CGFloat, blue: CGFloat) -> (h: CGFloat, s: CGFloat, v: CGFloat) {
        let minVal = min(red, green, blue)
        let maxVal = max(red, green, blue)
        let delta = maxVal - minVal
        
        var hue: CGFloat = 0
        if delta != 0 {
            if maxVal == red {
                hue = (green - blue) / delta
            } else if maxVal == green {
                hue = 2 + (blue - red) / delta
            } else {
                hue = 4 + (red - green) / delta
            }
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        
        let saturation = maxVal == 0 ? 0 : delta / maxVal
        let value = maxVal
        
        return (h: hue / 360, s: saturation, v: value)
    }
}
