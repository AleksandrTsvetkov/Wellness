//
//  DateVAlueFormatter.swift
//  Wellness-iOS
//
//  Created by Andrey Atroshchenko on 30.06.2020.
//  Copyright © 2020 Wellness. All rights reserved.
//

import Foundation
import Charts

public class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    
    override init() {
        super.init()
        dateFormatter.dateFormat = "E"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: value))
    }
}
