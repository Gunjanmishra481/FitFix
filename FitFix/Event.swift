//
//
//import UIKit
//
//struct Event {
//    var title: String
//    var date: Date
//    var image: UIImage?
//
//    init(title: String, date: Date, image: UIImage? = nil) {
//        self.title = title
//        self.date = date
//        self.image = image
//    }
//
//    var displayImage: UIImage {
//        return image ?? UIImage(named: "birthday")! // Replace with your default image asset name
//    }
//}
//class DataModel4 {
//    static var events: [Event] = [
//        Event(title: "friends birthday", date: Date(), image: UIImage(named: "birthday")),  // Use Date() for now
//        Event(title: "friends marriage", date: Date(),  image: UIImage(named: "marriage"))
//    ]
//}
import UIKit

struct Event {
    var id: String
    var title: String
    var date: Date
    var imageName: String?

    init(id: String, title: String, date: Date, imageName: String? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.imageName = imageName
    }

    var displayImage: UIImage {
        return UIImage(named: imageName ?? "birthday")!
    }
}
class DataModel4 {
    static var events: [Event] = [
        Event(id: "1", title: "friends birthday", date: Date(), imageName: "birthday"),
        Event(id: "2", title: "friends marriage", date: Date(), imageName: "marriage")
    ]
}
