//
//  Network.swift
//  ParkingGang
//
//  Created by segev perets on 22/01/2024.
//

import Foundation
struct Network {
    private init() {}
    static let shared = Network()

    func postRequest(_ api:GptApi,queryData:Data) async throws -> Data? {
        guard let apiKey = Secrets.ChatGPT.apiKey else {
            throw NetworkError.noApiKey
        }
        guard let url = URL(string: api.rawValue) else {fatalError("Wrong url")}
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer " + apiKey, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = queryData
        
        let (data,res) = try await URLSession.shared.data(for: request)
        guard let response = res as? HTTPURLResponse else {fatalError()}
        
        Logger.log("Status Code:",response.statusCode)
        
        guard response.statusCode == 200 else {
            let parsedData = try? JSONSerialization.jsonObject(with: data) as? [String:[String:Any]]
            let message = parsedData?["error"]?["message"] as? String
            throw NetworkError.invalidData(description: message ?? "")
        }
        
        
        return data
    }
    
}

enum GptApi: String {
    case completions = "https://api.openai.com/v1/chat/completions"
}

enum NetworkError: Error {
    case invalidData(description:String), noApiKey
    var detail: String {
        switch self {
        case .invalidData(let description):
            return description
        case .noApiKey:
            return "No Api Key"
        }
    }
}
