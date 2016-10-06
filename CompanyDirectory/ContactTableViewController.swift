//
//  ContactTableViewController.swift
//  CompanyDirectory
//
//  Created by Brian Bernberg on 10/3/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {

    var contact: Contact?
    fileprivate var contactEntries = [ContactEntry]()
    fileprivate let contactProfileIdentifier = "ContactProfileCell"
    fileprivate let contactEntryIdentifier = "ContactEntryCell"
    fileprivate let photoHeight: CGFloat = 60.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 80        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let contact = self.contact else {
            return
        }
        self.contactEntries = self.contactEntries(forContact: contact)
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactEntries.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return self.profileCell(forTableView: tableView, indexPath: indexPath)
        } else {
            return self.contactCell(forTableView: tableView, indexPath: indexPath)
        }
    }
    
    fileprivate func profileCell(forTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let contact = self.contact else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: self.contactProfileIdentifier, for: indexPath) as! ContactProfileCell
        let attrString = NSMutableAttributedString()
        let attrName = NSAttributedString(string: contact.displayName,
                                      attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 20.0)])
        attrString.append(attrName)
        if let title = contact.title {
            let attrTitle = NSAttributedString(string: "\n\(title)",
                                               attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)])
            attrString.append(attrTitle)
        }
        cell.nameTitleLabel.attributedText = attrString
        if let photo = contact.photo {
            cell.profileImageView.image = photo
            cell.imageViewHeightConstraint.constant = self.photoHeight
        } else {
            cell.imageViewHeightConstraint.constant = 0.0
        }
        
        return cell
    }
    
    fileprivate func contactCell(forTableView tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.contactEntryIdentifier, for: indexPath) as! ContactEntryTableViewCell
        let contactEntry = self.contactEntry(forIndex: indexPath.row)
        cell.headlineLabel.text = contactEntry.headline
        cell.detailLabel.text = contactEntry.detail
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contactEntry = self.contactEntry(forIndex: indexPath.row)
        contactEntry.doAction()
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard indexPath.row != 0 else {
            return nil
        }
        return indexPath
    }
    
    
    // MARK: Contact entry functions
    fileprivate func contactEntry(forIndex index: Int) -> ContactEntry {
        return self.contactEntries[index - 1]
    }
    
    fileprivate func contactEntries(forContact contact: Contact) -> [ContactEntry] {
        var result = [ContactEntry]()
        for (label, number) in contact.phoneNumbers {
            let entry = ContactEntry(headline: label.capitalized + " Phone", detail: number, action: .PhoneNumber)
            result.append(entry)
        }
        for (label, email) in contact.emails {
            let entry = ContactEntry(headline: label.capitalized + " Email", detail: email, action: .Email)
            result.append(entry)
        }
        if let website = contact.website {
            let entry = ContactEntry(headline: "Homepage", detail: website, action: .URL)
            result.append(entry)
        }
        if let birthday = contact.birthday {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            let entry = ContactEntry(headline: "Birthday",
                                     detail: dateFormatter.string(from: birthday),
                                     action: .Calendar)
            result.append(entry)
        }
        if let facebook = contact.social["facebook"] {
            let entry = ContactEntry(headline: "Facebook", detail: facebook, action: .Facebook)
            result.append(entry)
        }
        if let twitter = contact.social["twitter"] {
            let entry = ContactEntry(headline: "Twitter", detail: twitter, action: .Twitter)
            result.append(entry)
        }
        
        return result
    }
}
