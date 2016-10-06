//
//  ContactListProvider.swift
//  CompanyDirectory
//
//  Created by Brian Bernberg on 10/3/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import Foundation

class ContactListProvider {
    fileprivate var contacts: [(String, [Contact])]
    let contactsURLPath = "https://s3-us-west-2.amazonaws.com/confide-media/interview/employees.json"
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // MARK: Init functions
    convenience init() {
        self.init(contacts: [])
    }
    
    init(contacts: [(String, [Contact])]) {
        self.contacts = contacts
    }
    
    // MARK: Public functions
    func sectionCount() -> Int {
        return self.contacts.count
    }
    
    func sectionTitles() -> [String] {
        return self.contacts.map { $0.0 }
    }
    
    func contactCount(forSection section: Int) -> Int {
        return self.contacts[section].1.count
    }
    
    func contact(forIndexPath indexPath: IndexPath) -> Contact? {
        return (self.contacts[indexPath.section].1)[indexPath.row]
    }
    
    func index(forContact contact: Contact) -> Int {
        guard let letterChar = contact.sortingName.characters.first else {
            return 0
        }
        let letter = String(letterChar)
        for (index, contactsTuple) in self.contacts.enumerated() {
            if letter == contactsTuple.0 {
                return index
            }
        }
        return 0
    }
    
    func store(contact: Contact) {
        self.contacts[self.index(forContact: contact)].1.append(contact)
    }
    
    func fetchContacts(completion: @escaping (_ success: Bool) -> Void) {
        guard let url = URL(string: self.contactsURLPath) else {
            completion(false)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                if let error = error {
                    print("\(error)")
                }
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error)
                completion(false)
            }
            
            guard let employees = json["employees"] as? [ [String: Any] ] else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            self.contacts = self.emptyContacts()
            
            for employee in employees {
                let contact = Contact(firstName: employee["first_name"] as? String,
                                      lastName: employee["last_name"] as? String,
                                      title: employee["title"] as? String,
                                      emails: self.dictionary(fromEmployee: employee, forKey: "emails"),
                                      website: employee["website"] as? String,
                                      social: self.dictionary(fromEmployee: employee, forKey: "social"),
                                      birthday: self.birthday(fromEmployee: employee),
                                      photoURLPath: employee["photo_url"] as? String,
                                      phoneNumbers: self.dictionary(fromEmployee: employee, forKey: "phones"))
                self.store(contact: contact)
            }
            
            self.sortContacts()
            
            DispatchQueue.main.async { completion(true) }
        }
        
        task.resume()
        
    }
    
    // MARK: Helper functions
    fileprivate func emptyContacts() -> [(String, [Contact])] {
        var result = [(String, [Contact])]()
        for char in "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters {
            let element: (String, [Contact]) = (String(char), [])
            result.append(element)
        }
        return result
    }
    
    fileprivate func sortContacts() {
        var result = [(String, [Contact])]()
        for contactsTuple in self.contacts {
            let contacts = contactsTuple.1.sorted { $0.sortingName < $1.sortingName }
            result.append( (contactsTuple.0, contacts) )
        }
        self.contacts = result
    }
    
    fileprivate func dictionary(fromEmployee employee: [String: Any],forKey key: String) -> [String: String] {
        var result = [String: String]()
        if let dictionary = employee[key] as? [String: Any] {
            result = self.removeNSNulls(fromDictionary: dictionary)
        }
        return result
    }
    
    fileprivate func removeNSNulls(fromDictionary dictionary: [String: Any]) -> [String: String] {
        var result = [String: String]()
        for (key, value) in dictionary {
            if let stringValue = value as? String {
                result[key] = stringValue
            }
        }
        return result
    }
    
    fileprivate func birthday(fromEmployee employee: [String: Any]) -> Date? {
        var result: Date?
        if let date = employee["birthday"] as? String {
            result = self.dateFormatter.date(from: date)
        }
        return result
    }
}
