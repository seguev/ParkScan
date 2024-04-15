//
//  Constants.swift
//  ParkingGang
//
//  Created by segev perets on 22/01/2024.
//

import Foundation
struct Constants {
    private init(){}
    
    static let gpt4VisionPreview = "gpt-4-vision-preview"
    
    struct UserDefaultKeys {
        private init(){}
        static let parkingNum = "parkingNum"
    }
    
    struct Prompt {
        private init(){}

        
        
        static var systemMessage: String = """
You are a Hebrew parking sign parser. Your task is to analyze parking sign images presented as matrices, where:
- The top row contains area allowance criteria: "no area allowance", "different area allowance", or "this area allowance".
- The rightmost column specifies time periods: "weekdays", "weekends", or a "catch-all" case.
- The cells represent parking rules: "Paid", "Forbidden", or "Free".
To provide the correct response:
1. Check if the image is clear and a Hebrew parking sign. If not, respond with "Unclear".
2. Identify the user's area allowance column.
3. Determine the current day and hour.
4. Find the intersection of the area allowance column and the day/hour row.
5. Output the corresponding parking rule: "Paid", "Forbidden", or "Free".
Your responses must be limited to only those three options or "Unclear" if the image is invalid, then add one sentence short explenation for your answer.
"""
        
        static var gptImagePrompt: String {
            let today = UserData.shared.today
            let time = UserData.shared.nowFormatted
            let areaAllowance = UserData.shared.areaAllowanceString
            
            let prompt = "Today is \(today), and its \(time). i have \(areaAllowance) parking allowance. can I park here right now?"
            
            Logger.log(prompt)
            return prompt
        }
        static let mockPrompt = "what do you see in the picture? with as little words as you can."
    }
    
    struct Segue {
        private init(){}
        static let continueSegue = "continueSegue"
    }
}

enum LottieType: String {
    case notFound = "404Animation"
    case free = "FreeAnimation"
    case forbidden = "ForbiddenAnimation"
    case paid = "PaidAnimation"
    case unclear = "UnclearAnimation"
}
