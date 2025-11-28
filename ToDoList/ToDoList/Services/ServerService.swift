//
//  ServerService.swift
//  ToDoList
//
//  Created by Siarhei Lukyanau on 17.08.25.
//  telegram: @LSN777, email: LSN21@YA.RU
//

import Foundation

protocol ServerServiceProtocol: AnyObject {
    func fetchToDoData(from urlString: String) async throws -> ToDoAnswer?
}

actor ServerService: ServerServiceProtocol {
    
    static let shared = ServerService()

    private init() {}

    func fetchToDoData(from urlString: String) async throws -> ToDoAnswer? {
        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            return nil
        }
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Проверяем, является ли ответ успешным
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Server error: \(response)")
                return nil
            }
            // Декодируем данные
            let decoder = JSONDecoder()
            let answer = try decoder.decode(ToDoAnswer.self, from: data)
            return answer
            
        } catch {
            print("Error fetching or decoding data: \(error)")
            return nil
        }
    }
}
