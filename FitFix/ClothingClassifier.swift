import CoreML
import Vision
import UIKit
import FirebaseFirestore

class ClothingClassifier {
    
    static let shared = ClothingClassifier() // Singleton Instance
    
    private var model: displayDailyRecommendation!
    
    private init() {
        do {
            self.model = try displayDailyRecommendation(configuration: MLModelConfiguration())
        } catch {
            print("Error loading CoreML model: \(error)")
        }
    }
    
    // Classify clothing item based on its category and image
    func classifyClothing(from image: UIImage, category: String, completion: @escaping (String?) -> Void) {
        guard let buffer = image.toCVPixelBuffer() else {
            completion(nil)
            return
        }

        // Map Firestore category to CoreML model input fields
        let (masterCategory, subCategory, articleType) = mapCategoryToModelInput(category: category)
        
        do {
            let input = try displayDailyRecommendationInput(
                gender: "Unisex", // Default value (can be customized based on user data)
                masterCategory: masterCategory,
                subCategory: subCategory,
                articleType: articleType,
                baseColour: "Blue", // Default value (can be extracted from image)
                season: "All Season", // Default value
                year: 2025, // Default value
                usage: "Casual", // Default value
                productDisplayName: "Basic Tee" // Default value
            )
            
            let output = try model.prediction(input: input)
            completion(String(output.id_))
            
        } catch {
            print("Error making prediction: \(error)")
            completion(nil)
        }
    }
    
    // Helper function to map Firestore category to CoreML model input fields
    private func mapCategoryToModelInput(category: String) -> (masterCategory: String, subCategory: String, articleType: String) {
        switch category {
        case "Top Wear":
            return ("Clothing", "Topwear", "T-shirt")
        case "Bottom Wear":
            return ("Clothing", "Bottomwear", "Jeans")
        case "Foot Wear":
            return ("Clothing", "Footwear", "Sneakers")
        default:
            return ("Clothing", "Other", "Other")
        }
    }
}
