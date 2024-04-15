//
//  GPTLogic.swift
//  ParkingGang
//
//  Created by segev perets on 22/01/2024.
//

import Foundation
struct GPTLogic {
    func formQuery(question:String,imageDataString image:String) -> Data? {
        
        let fixedImageString = "data:image/jpeg;base64,\(image)"
        
        let system = Content(type: .text,
                               text: Constants.Prompt.systemMessage,
                               image_url: nil)
        
        let question = Content(type: .text,
                               text: question,
                               image_url: nil)
        
        let image = Content(type: .imageUrl,
                            text: nil,
                            image_url: .init(url: fixedImageString,
                                             detail: .high))
        
        
        let userMessage = QueryMessage(role: .user, content: [system,question,image])
        
        let query = GPTBodyModel(
            model: .gpt4VisionPreview,
            messages: [userMessage],
            max_tokens: 300,
            temperature: 0,
            top_p: 0,
            frequency_penalty: 0,
            presence_penalty: 0
        )
        
        do {
            let jsonQuery = try JSONEncoder().encode(query)
            return jsonQuery
        } catch {
            Logger.log(error)
            return nil
        }
    }
}
