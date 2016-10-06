//
//  ContactEntry.swift
//  CompanyDirectory
//
//  Created by Brian Bernberg on 10/3/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit

enum ContactActions {
    case PhoneNumber
    case Email
    case URL
    case Calendar
    case Facebook
    case Twitter
    case None
}

struct ContactEntry {
    let headline: String
    let detail: String
    let action: ContactActions
    
    func doAction() {
        switch self.action {
        case .PhoneNumber:
            if let url = URL(string: "tel://\(self.detail)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .Email:
            if let url = URL(string: "mailto:\(self.detail)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .URL:
            if let url = URL(string: self.detail) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .Facebook:
            let fbPath = "https://facebook.com/\(self.detail)"
            if let url = URL(string: fbPath) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .Twitter:
            let twitterPath = "https://twitter.com/\(self.detail)"
            if let url = URL(string: twitterPath) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .Calendar:
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            guard let birthday = dateFormatter.date(from: self.detail) else {
                return
            }
            var birthdayComponents = Calendar.current.dateComponents([.day, .month], from: birthday)
            let nowComponents = Calendar.current.dateComponents([.year], from: Date())
            birthdayComponents.year = nowComponents.year!
            guard let currentBirthday = Calendar.current.date(from: birthdayComponents) else {
                return
            }
            
            if let url = URL(string: "calshow:\(currentBirthday.timeIntervalSinceReferenceDate)") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        default:
            break
        }
    }
}
