//
//  EntryDetailViewController.swift
//  CloudKitJournal
//
//  Created by Junior Suarez-Leyva on 5/11/20.
//  Copyright © 2020 Zebadiah Watson. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    
    var entry: Entry? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        
    }
    
    @IBAction func mainViewTapped(_ sender: Any) {
        bodyTextView.resignFirstResponder()
        //titleTextField.resignFirstResponder()
        
    }
    @IBAction func clearButtonTapped(_ sender: Any) {
        titleTextField.text = ""
        bodyTextView.text = ""
      }
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty,
            let body = bodyTextView.text, !body.isEmpty else { return }
        
        EntryController.sharedInstance.createEntryWith(title: title, body: body) { (result) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    func updateViews() {
           
           guard let entry = entry else { return }
           
           titleTextField.text = entry.title
           bodyTextView.text = entry.body
       }
}

extension EntryDetailViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
    }
    
   
}
