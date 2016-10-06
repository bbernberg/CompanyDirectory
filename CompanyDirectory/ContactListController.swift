//
//  ContactListController.swift
//  CompanyDirectory
//
//  Created by Brian Bernberg on 10/3/16.
//  Copyright © 2016 Shared. All rights reserved.
//

import UIKit

class ContactListViewController: UITableViewController {

    fileprivate let cellIdentifier = "ContactListCell"
    fileprivate let contactListProvider: ContactListProvider
    fileprivate let contactImageProvider: ContactImageProvider
    
    override init(style: UITableViewStyle) {
        self.contactListProvider = ContactListProvider()
        self.contactImageProvider = ContactImageProvider()
        super.init(style:style)
    }
    
    required init?(coder: NSCoder) {
        self.contactListProvider = ContactListProvider()
        self.contactImageProvider = ContactImageProvider()
        super.init(coder: coder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.fetchContacts),
                                               name: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil)
        self.fetchContacts()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailViewController = segue.destination as? ContactTableViewController,
            let indexPath = self.tableView.indexPathForSelectedRow,
            segue.identifier == "ContactDetailSegue" {
            detailViewController.contact = self.contactListProvider.contact(forIndexPath: indexPath)
        }
    }
    
    // MARK: UITableViewDataSource/UITableViewDelegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contactListProvider.contactCount(forSection: section)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.contactListProvider.sectionCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier, for: indexPath)
        
        guard let contact = self.contactListProvider.contact(forIndexPath: indexPath) else {
            return UITableViewCell()
        }
        cell.textLabel?.text = contact.displayName
        
        return cell
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.contactListProvider.sectionTitles()
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Lazily load contact photos
        guard let contact = self.contactListProvider.contact(forIndexPath: indexPath) else {
            return
        }
        if let _ = contact.photo {
            return
        }
        self.contactImageProvider.fetchImage(forContact: contact) { (image) in
            contact.photo = image
        }
    }

    // MARK: Data fetch
    func fetchContacts() {
        self.contactListProvider.fetchContacts { [unowned self] _ in
            self.tableView.reloadData()
        }
    }
}

