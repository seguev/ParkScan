//
//  String + Ext.swift
//  ParkScan
//
//  Created by segev perets on 15/03/2024.
//

import Foundation

extension String {
    var isValidObservation: Bool {
        return self.contains(where: {$0.isLetter})
    }
}
