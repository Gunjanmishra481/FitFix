

import UIKit

struct Event {
    var title: String
    var date: Date
    var image: UIImage?

    init(title: String, date: Date, image: UIImage? = nil) {
        self.title = title
        self.date = date
        self.image = image
    }

    var displayImage: UIImage {
        return image ?? UIImage(named: "birthday")! // Replace with your default image asset name
    }
}
class DataModel4 {
    static var events: [Event] = [
        Event(title: "friends birthday", date: Date(), image: UIImage(named: "birthday")),  // Use Date() for now
        Event(title: "friends marriage", date: Date(),  image: UIImage(named: "marriage"))
    ]
}
