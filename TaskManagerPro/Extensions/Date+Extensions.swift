//
//  Date+Extensions.swift
//  TaskManagerPro
//
//  Created by Nazarbek on 19.03.2026.
//
import Foundation

extension Date {
    var formattedShort: String {
        formatted(date: .abbreviated, time: .shortened)
    }
}
