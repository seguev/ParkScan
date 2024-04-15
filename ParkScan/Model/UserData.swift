//
//  UserData.swift
//  ParkingGang
//
//  Created by segev perets on 26/01/2024.
//

import Foundation
struct UserData {
    private init(){}
    static var shared = UserData()
    
    var today: String {
        let days = Calendar.current.weekdaySymbols
        let dayIndex = Calendar.current.component(.weekday, from: Date()) - 1
        return days[dayIndex]
    }
    
    let nowFormatted = Date().formatted(date: .omitted, time: .shortened)
    
    lazy var areaAllowanceString: String = if parkingNum > 0 {
        "Parking area number " + parkingNum.description
    } else {
        "No area allowance number"
    }
    
    var parkingNum: Int {
        get {
            UserDefaults.standard.integer(forKey: Constants.UserDefaultKeys.parkingNum)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.UserDefaultKeys.parkingNum)
            Logger.log("saved \(newValue)")
        }
    }
    
}
