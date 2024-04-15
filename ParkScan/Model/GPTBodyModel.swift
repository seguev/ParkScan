//
//  GPTBodyModel.swift
//  ParkingGang
//
//  Created by segev perets on 22/01/2024.
//

import Foundation

struct GPTBodyModel: Codable {
    let model: Model
    let messages: [QueryMessage]
    let max_tokens: Int
    let temperature: Float
    let top_p: Float
    let frequency_penalty: Float
    let presence_penalty: Float
    
    enum Model: String, Codable {
        
        case gpt4VisionPreview = "gpt-4-vision-preview"
        case gpt_4_turbo_preview = "gpt-4-turbo-preview"
    }
}

struct SystemMessage: Codable {
    let role: Role
    let content: String
}

struct QueryMessage: Codable {
    let role: Role
    let content: [Content]
}

enum Role: String, Codable {
    case user = "user"
    case assistant = "assistant"
}

struct Content: Codable {
    ///text -> enter text, imageUrl -> insert image. NOT BOTH!
    let type: ContentType
    let text: String?
    let image_url: ImageUrlType?
    
    enum ContentType: String, Codable {
        case text = "text"
        case imageUrl = "image_url"
    }
    
}

struct ImageUrlType: Codable {
    let url: String
    let detail: Detail
    
    enum Detail: String, Codable {
        case high = "high"
        case low = "low"
    }
}

//{
//  "messages": [
//    {
//      "role": "user",
//      "content": [
//        {
//          "type": "text",
//          "text": "what do you see in the picture? with as little words as you can."
//        },
//        {
//          "type": "image_url",
//          "image_url": {
//            "url": "data:image/jpeg;base64,abcdefg1234567890",
//            "detail": "low"
//          }
//        }
//      ]
//    }
//  ],
//  "max_tokens": 500,
//  "model": "gpt-4-vision-preview"
//}


