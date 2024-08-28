//
//  ToDoRecord.swift
//  ToDoListMVC
//
//  Created by SIARHEI LUKYANAU on 26.08.2024.
//

import Foundation

struct ToDoRecord: Codable, Equatable {
    
    var id: Int?
    var todo: String?
    var description: String?
    var date: Date?
    var completed: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case todo
        case description
        case date
        case completed
    }
    
    static func == (lhs: ToDoRecord, rhs: ToDoRecord) -> Bool {
        if lhs.id == rhs.id, lhs.todo == rhs.todo, lhs.description == rhs.description, lhs.date == rhs.date, lhs.completed == rhs.completed {
            return true
        }
        return false
    }
}

struct ToDoAnswer: Codable, Equatable {
    
    var todos: [ToDoRecord]?
    
    private enum CodingKeys: String, CodingKey {
        case todos
    }
    
    static func == (lhs: ToDoAnswer, rhs: ToDoAnswer) -> Bool {
        if lhs.todos == rhs.todos {
            return true
        }
        return false
    }
}
