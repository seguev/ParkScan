//
//  GPTAnswerModel.swift
//  ParkingGang
//
//  Created by segev perets on 26/01/2024.
//

import Foundation
struct GPTAnswerModel: Decodable {
    let id: String?
    let object: String
    let created: Int
    let model: String
    let usage: Usage
    let choices: [Choice]
}

struct Usage: Decodable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
}

struct Choice: Decodable {
    let message: AnswerMessage
    let finish_reason: String
    let index: Int
}

struct AnswerMessage: Decodable {
    let role: Role
    let content: String
}

//{
//  "id": "chatcmpl-8lEGA1zNe9V7W9O5U8KSldAyabZzr",
//  "object": "chat.completion",
//  "created": 1706266922,
//  "model": "gpt-4-1106-vision-preview",
//  "usage": {
//    "prompt_tokens": 108,
//    "completion_tokens": 5,
//    "total_tokens": 113
//  },
//  "choices": [
//    {
//      "message": {
//        "role": "assistant",
//        "content": "Blurred coffee mug."
//      },
//      "finish_reason": "stop",
//      "index": 0
//    }
//  ]
//}
