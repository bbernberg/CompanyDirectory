//
//  Contact.swift
//  CompanyDirectory
//
//  Created by Brian Bernberg on 10/3/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit

class Contact: NSObject {
    var firstName: String?
    var lastName: String?
    var title: String?
    var emails: [String: String]
    var website: String?
    var social: [String: String]
    var birthday: Date?
    var photoURLPath: String?
    var phoneNumbers: [String: String]
    var photo: UIImage?
    
    var displayName: String {
        if let firstName = self.firstName, let lastName = self.lastName {
            return "\(firstName) \(lastName)"
        } else if let firstName = self.firstName {
            return firstName
        } else {
            return self.lastName ?? String()
        }
    }
    
    var sortingName: String {
        if let lastName = self.lastName {
            return lastName.uppercased()
        } else {
            return self.displayName.uppercased()
        }
    }
    
    
    init(firstName: String? = nil,
         lastName: String? = nil,
         title: String? = nil,
         emails: [String: String],
         website: String? = nil,
         social: [String: String],
         birthday: Date? = nil,
         photoURLPath: String? = nil,
         phoneNumbers: [String: String]) {
        self.firstName = firstName
        self.lastName = lastName
        self.title = title
        self.emails = emails
        self.website = website
        self.social = social
        self.birthday = birthday
        self.photoURLPath = photoURLPath
        self.phoneNumbers = phoneNumbers
    }
        
    static func == (left: Contact, right: Contact) -> Bool {
        return left.firstName == right.firstName &&
            left.lastName == right.lastName &&
            left.title == right.title &&
            left.emails == right.emails &&
            left.website == right.website &&
            left.social == right.social &&
            left.birthday == right.birthday &&
            left.photoURLPath == right.photoURLPath &&
            left.phoneNumbers == right.phoneNumbers
    }
}

