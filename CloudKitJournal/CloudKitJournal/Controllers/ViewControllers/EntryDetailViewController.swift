//
//  EntryDetailViewController.swift
//  CloudKitJournal
//
//  Created by Myles Cashwell on 5/10/21.
//  Copyright © 2021 Zebadiah Watson. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var entryTitleTextField: UITextField!
    @IBOutlet weak var entryBodyTextView: UITextView!
    
    
    
    //MARK: - Properties
    var entry: Entry? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }
    

    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        entryTitleTextField.delegate = self
    }
    
    
    //MARK: - Actions
    @IBAction func mainViewTapped(_ sender: Any) {
        entryTitleTextField.resignFirstResponder()
        entryBodyTextView.resignFirstResponder()
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        entryTitleTextField.text = ""
        entryBodyTextView.text = ""
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let entryTitle = entryTitleTextField.text, !entryTitle.isEmpty,
              let entryBody = entryBodyTextView.text, !entryBody.isEmpty else { return }
        
        EntryController.shared.createEntryWith(title: entryTitle, body: entryBody) { (result) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    
    
    //MARK: - Functions
    func updateViews() {
        guard let entry = entry else { return }
        entryTitleTextField.text = entry.title
        entryBodyTextView.text = entry.body
    }
}

//MARK: - Extensions
extension EntryDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        resignFirstResponder()
    }
}
