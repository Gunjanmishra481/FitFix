//
//  EventManager.swift
//  calendareminder
//
//  Created by user@79 on 08/11/24.
//
import Foundation

class EventManager {
    static let shared = EventManager()
    private init() {}

//    var events: [Event] = []
    var events = DataModel4.events
    
    func addEvent(_ event: Event) {
        events.append(event)
    }
    func deleteEvent(at index: Int) {
        events.remove(at: index)
    }
}

