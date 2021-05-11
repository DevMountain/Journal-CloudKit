//
//  EntryListTableViewController.swift
//  CloudKitJournal
//
//  Created by Myles Cashwell on 5/10/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import UIKit

class EntryListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEntries()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    
    //MARK: - Functions
    func fetchEntries() {
        EntryController.shared.fetchEntriesWith { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    guard let fetchedEntries = entries else { return }
                    EntryController.shared.entries = fetchedEntries
                    self.tableView.reloadData()
                case .failure(let error):
                    print("Error in \(#function)\(#line) : \(error.localizedDescription) \n---\n \(error)")
                }
            }
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EntryController.shared.entries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        
        let entry = EntryController.shared.entries[indexPath.row]
        cell.textLabel?.text = entry.title
        cell.detailTextLabel?.text = entry.timestamp.formatToString()
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEntryDetailVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                  let destinationVC = segue.destination as? EntryDetailViewController else { return }
            let entryToSend = EntryController.shared.entries[indexPath.row]
            destinationVC.entry = entryToSend
        }
    }
}
