import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class EventManager {
    static let shared = EventManager()
    private let db = Firestore.firestore()
    var events: [Event] = []

    private init() {}

    /// Adds a new event for the current user with a generated ID and saves it to Firestore
    func addEvent(title: String, date: Date, imageName: String?) -> Event {
        guard let userId = Auth.auth().currentUser?.uid else {
            fatalError("User not logged in.")
        }
        // Generate a new document ID within the user's "events" subcollection.
        let id = db.collection("users")
                    .document(userId)
                    .collection("events")
                    .document().documentID
        let event = Event(id: id, title: title, date: date, imageName: imageName)
        events.append(event)
        saveEventToFirestore(event, forUser: userId)
        return event
    }

    /// Deletes an event at the specified index and removes it from Firestore
    func deleteEvent(at index: Int) {
        let event = events.remove(at: index)
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        deleteEventFromFirestore(event, forUser: userId)
    }

    /// Saves an event in the current user's "events" subcollection
    private func saveEventToFirestore(_ event: Event, forUser userId: String) {
        let data: [String: Any] = [
            "id": event.id,
            "title": event.title,
            "date": event.date,
            "imageName": event.imageName ?? ""
        ]
        db.collection("users")
          .document(userId)
          .collection("events")
          .document(event.id)
          .setData(data) { error in
              if let error = error {
                  print("Error saving event: \(error)")
              } else {
                  print("Event saved successfully")
              }
          }
    }

    /// Deletes an event from the current user's "events" subcollection
    private func deleteEventFromFirestore(_ event: Event, forUser userId: String) {
        db.collection("users")
          .document(userId)
          .collection("events")
          .document(event.id)
          .delete { error in
              if let error = error {
                  print("Error deleting event: \(error)")
              } else {
                  print("Event deleted successfully")
              }
          }
    }

    /// Loads all events from the current user's "events" subcollection
    func loadEvents(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        db.collection("users")
          .document(userId)
          .collection("events")
          .getDocuments { snapshot, error in
              if let error = error {
                  print("Error loading events: \(error)")
                  return
              }
              self.events = snapshot?.documents.compactMap { doc in
                  let data = doc.data()
                  return Event(
                      id: data["id"] as? String ?? "",
                      title: data["title"] as? String ?? "",
                      date: (data["date"] as? Timestamp)?.dateValue() ?? Date(),
                      imageName: data["imageName"] as? String
                  )
              } ?? []
              completion()
          }
    }
}
