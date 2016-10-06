//
//  ContactImageProvider.swift
//  CompanyDirectory
//
//  Created by Brian Bernberg on 10/4/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit

final class ContactImageProvider {
    var contactsGettingFetched = Set<Contact>() // Used to ensure same image isn't fetched more than once
    var sessionConfig: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 3
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        return config
    }()
    
    func fetchImage(forContact contact: Contact, success: @escaping (_ image: UIImage) -> Void) {
        guard let photoURLPath = contact.photoURLPath,
            let url = URL(string: photoURLPath),
            self.contactsGettingFetched.contains(contact) == false
        else {
            return
        }
        self.contactsGettingFetched.insert(contact)
        let session = URLSession(configuration: self.sessionConfig)
        let task = session.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                self.contactsGettingFetched.remove(contact)
            }
            guard let data = data,
                let image = UIImage(data: data),
                error == nil else {
                    if let error = error {
                        print("\(error)")
                    }
                    return
            }
            DispatchQueue.main.async { success(image) }
        }
        task.resume()
    }
}
