//
//  EntryDetailViewController.swift
//  CloudKitJournal
//
//  Created by Zebadiah Watson on 3/26/20.
//  Copyright © 2020 Zebadiah Watson. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextField: UITextView!
    
    // MARK: - Properties
    var entry: Entry? {
        didSet {
            DispatchQueue.main.async {
                self.loadViewIfNeeded()
                self.updateViews()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        titleTextField.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty,
            let body = bodyTextField.text, !body.isEmpty
            else { return }


        EntryController.sharedInstance.createEntry(with: title, body: body) { (result) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func clearTextButtonTapped(_ sender: Any) {
        titleTextField.text = ""
        bodyTextField.text = ""
    }
    
    // MARK: - Helper Functions
    func updateViews() {
        guard let entry = entry else { return }
        titleTextField.text = entry.title
        bodyTextField.text = entry.body
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
}// End of Class
