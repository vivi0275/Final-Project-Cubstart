//
//  TaskParser.swift
//  Cubstart
//
//  Created on 18/11/2025.
//

import Foundation

struct ParsedTask {
    var title: String
    var description: String
    var category: TaskCategory
    var priority: TaskPriority
    var patientId: String?
    var dueTime: Date?
}

class TaskParser {
    static func parse(text: String) -> ParsedTask {
        let lowercased = text.lowercased()
        
        // Extract priority
        var priority: TaskPriority = .normal
        if lowercased.contains("urgent") || lowercased.contains("asap") || lowercased.contains("emergency") {
            priority = .urgent
        } else if lowercased.contains("important") || lowercased.contains("priority") {
            priority = .important
        }
        
        // Extract category
        var category: TaskCategory = .patientCare
        if lowercased.contains("medication") || lowercased.contains("medicine") || lowercased.contains("pill") || lowercased.contains("drug") {
            category = .medication
        } else if lowercased.contains("document") || lowercased.contains("chart") || lowercased.contains("note") || lowercased.contains("record") {
            category = .documentation
        } else if lowercased.contains("round") || lowercased.contains("check") || lowercased.contains("visit") {
            category = .rounds
        } else if lowercased.contains("emergency") || lowercased.contains("code") {
            category = .emergency
        } else if lowercased.contains("train") || lowercased.contains("learn") || lowercased.contains("education") {
            category = .training
        } else if lowercased.contains("admin") || lowercased.contains("paperwork") || lowercased.contains("administrative") {
            category = .administrative
        } else if lowercased.contains("meeting") || lowercased.contains("team") {
            category = .teamMeeting
        }
        
        // Extract patient ID
        var patientId: String? = nil
        let patterns = [
            "patient\\s+([A-Z0-9-]+)",
            "room\\s+(\\d+)",
            "patient\\s+(\\d+)",
            "P-?(\\d+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = lowercased as NSString
                let range = NSRange(location: 0, length: nsString.length)
                if let match = regex.firstMatch(in: lowercased, options: [], range: range),
                   match.numberOfRanges > 1 {
                    let patientRange = match.range(at: 1)
                    if patientRange.location != NSNotFound {
                        let extracted = nsString.substring(with: patientRange)
                        if extracted.allSatisfy({ $0.isNumber }) {
                            patientId = "P-\(extracted)"
                        } else {
                            patientId = extracted.uppercased()
                        }
                        break
                    }
                }
            }
        }
        
        // Extract time/date
        var dueTime: Date? = nil
        let calendar = Calendar.current
        let now = Date()
        
        // Check for "in X minutes/hours"
        if lowercased.contains("in ") {
            let timePattern = "in\\s+(\\d+)\\s+(minute|hour|day|min|hr)"
            if let regex = try? NSRegularExpression(pattern: timePattern, options: .caseInsensitive) {
                let nsString = lowercased as NSString
                let range = NSRange(location: 0, length: nsString.length)
                if let match = regex.firstMatch(in: lowercased, options: [], range: range),
                   match.numberOfRanges > 2 {
                    let numberRange = match.range(at: 1)
                    let unitRange = match.range(at: 2)
                    if numberRange.location != NSNotFound, unitRange.location != NSNotFound {
                        let numberStr = nsString.substring(with: numberRange)
                        let unit = nsString.substring(with: unitRange)
                        if let number = Int(numberStr) {
                            var components = DateComponents()
                            if unit.contains("minute") || unit.contains("min") {
                                components.minute = number
                            } else if unit.contains("hour") || unit.contains("hr") {
                                components.hour = number
                            } else if unit.contains("day") {
                                components.day = number
                            }
                            dueTime = calendar.date(byAdding: components, to: now)
                        }
                    }
                }
            }
        }
        
        // Check for "at X PM/AM"
        let timePattern = "at\\s+(\\d{1,2})\\s*(pm|am)?"
        if let regex = try? NSRegularExpression(pattern: timePattern, options: .caseInsensitive) {
            let nsString = lowercased as NSString
            let range = NSRange(location: 0, length: nsString.length)
            if let match = regex.firstMatch(in: lowercased, options: [], range: range),
               match.numberOfRanges > 1 {
                let hourRange = match.range(at: 1)
                if hourRange.location != NSNotFound {
                    let hourStr = nsString.substring(with: hourRange)
                    if let hour = Int(hourStr) {
                        var components = calendar.dateComponents([.year, .month, .day], from: now)
                        var finalHour = hour
                        
                        if match.numberOfRanges > 2 {
                            let ampmRange = match.range(at: 2)
                            if ampmRange.location != NSNotFound {
                                let ampm = nsString.substring(with: ampmRange).lowercased()
                                if ampm.contains("pm") && hour != 12 {
                                    finalHour = hour + 12
                                } else if ampm.contains("am") && hour == 12 {
                                    finalHour = 0
                                }
                            }
                        }
                        
                        components.hour = finalHour
                        components.minute = 0
                        dueTime = calendar.date(from: components)
                    }
                }
            }
        }
        
        // Extract title (first sentence)
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
        let title = sentences.first?.trimmingCharacters(in: .whitespaces) ?? String(text.prefix(50))
        
        // Description is the rest
        let description = sentences.count > 1 ? sentences.dropFirst().joined(separator: ". ").trimmingCharacters(in: .whitespaces) : ""
        
        return ParsedTask(
            title: title,
            description: description,
            category: category,
            priority: priority,
            patientId: patientId,
            dueTime: dueTime
        )
    }
}

