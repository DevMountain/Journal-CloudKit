# CloudKit Journal
This app is designed to allow you to further develop your understanding of MVC, protocols and delegates, tableViews and adding a new skill of persistence through the CloudKit framework and database.

## Part One - Model Objects and Controllers
* Create a custom model object with a memberwise initializer, and an  convenience initializer that takes in a CKRecord
* In the initializer that takes in a CKRecord, use the key-value pairs from the CKRecord to create the entries properties as you would a dictionary
* Add properties for the CKRecordID
* Add an extension on CKRecord that initializes an instance of CKRecord with your custom model object. Here is where you set the key-value pairs.
* Understand, create, and use a shared instance
* Create a model object controller with create and read functions

## Part Two - User Interface
* Implement a master-detail interface
* Implement the `UITableViewDataSource` protocol
* Understand and implement the `UITextFieldDelegate` protocol to dismiss the keyboard
* Create relationship segues in Storyboards
* Understand, use, and implement the `updateViews` pattern
* Implement `prepare(for segue: UIStoryboardSegue, sender: Any?)` to configure destination view controllers

## Part Three - Controller Implementation

* Add data persistence using CloudKit, managing CKRecords and Model Objects.
* Upon launch, fetch the CKRecords from the private database and turn those records into your model object.

# Part One - Model Objects and Controller
## Before you Begin
* Go into the app target file and select “Capabilities”.
* Open the “iCloud” section and turn the capability on.
* Uncheck “Key-value storage” and instead check the “CloudKit box

*By enabling this capability your Xcode will automatically construct an entitlements file with CloudKit support.  It will also create a new CKContainer in the CloudKit dashboard of your Developer account.  This may take a few minutes to show up.*

##  Entry & EntryController
### Entry

Create an Entry model class that will hold a title, body, and ckRecordID properties for each entry.

* Add a new `Entry.swift` file and define a new `Entry` class
* Import `CloudKit`
* Add properties for title, body, timestamp, and ckRecordID of type  `CKRecord.ID` 
* Add a memberwise initializer that takes parameters for each property.  Give the `timestamp` property you pass in a default parameter value of `Date()`.  Give the CkRecordID you pass in a default parameter value of `CKRecord.ID(recordName: UUID().uuidString))`.
	* This will allow you to refer back to entry objects CKRecord without an optional CKRecordID
* Extend the `Entry` class and create a fail-able convenience initializer that takes in only a `CKRecord` Entry
* Look up the documentation for `CKRecord`. Notice it acts like a dictionary.
* Get the value from your properties keys. Typically the value will be the string version of your property names. It's a good idea to create a set of constants outside of your class to make sure these keys stay uniform.

```swift
struct EntryConstants{
        static let TitleKey = "title"
        static let BodyKey = "body"
        static let TimestampKey = "timestamp"
    }
```

* You can then use these keys to pull values out of the CKRecord coming from your convenience initializer.
* You will need to cast these properties as their respective types while you unwrap them at the beginning of your convenience initializer.  See the example below for reference.  If any of the three properties are not found in the CKRecord for the specified key the initializer should fail and return nil.

```swift
 guard let title = ckRecord[EntryConstants.TitleKey] as? String else {return nil}
```
* Call the memberwise initializer you wrote before, using the values you unwrapped from the CKRecord as the initializer's arguments.  Do not use either of the default values provided in the memberwise initializer.  User the `recordID` property on the `ckRecord` taken in by the convenience initializer as the argument for initializers `ckRecordID` parameter.

Write an initializer for CKRecord using only an instance of your Entry model object

* Add an extension to the `CKRecord`  class and then create a convenience initializer in an `extension` on `CKRecord` 
* Create a convenience initializer that takes in an Entry as it’s only parameter 
* Call the designated initializer of the `CKRecord` which takes in a `recordType` and a `recordID`.  The record type is going to be a string representation of your model object (`Entry`).  
	* Add this as a fourth static property to your `EntryConstants` struct. 
* The record ID is going to be the `ckRecordID` property on the entry object your initializer takes in as a parameter
* This is where you set the key-value pairs for the `CKRecord`.  After the designated initializer, you can call `self.setValue(value: forKey:)` (The key is going to be a string representation of your property from your `EntryConstants` struct, the value is going to be the entry parameter’s value). 

```swift
extension CKRecord{
  convenience init(entry: Entry){
    self.init(recordType: EntryContstants.RecordType, recordID: entry.ckRecordID)
    self.setValue(entry.title, forKey: EntryContstants.TitleKey)
    self.setValue(entry.body, forKey: EntryContstants.BodyKey)
    self.setValue(entry.timestamp, forKey: EntryContstants.TimestampKey)
  }
}
```

# EntryController
Create a model object controller called `EntryController` that will manage adding, reading, updating, and removing entries. We will follow the shared instance design pattern because we want one consistent source of truth for our entry objects that are held on the controller.

* Add a new `EntryController.swift` file and define a new `EntryController` class inside.
* Add an entries array property, and set its value to an empty array
* Write your function declarations for create, save, and fetch.
* Create a property for `privateDB` and set it to your containers private database

## Create

* Write a `createEntryWith(title: ...)` function that takes in a `title`, and `body`, and `@escaping(_ result: Result<Entry?, EntryError>) -> Void` 
	* Similar to your completion blocks in Anchor Point 3 you will need to create an `extension` to handle your `result Error`. Do that now
* Create a new instance of `Entry`
* With the Entry you just created, call your `save(entry: Entry, completion: @escaping(_ result: Result<Entry?, EntryError>) -> Void))` method signiture created earlier
* Pass in the `newEntry` and the `completion`

## Save

* Create a `save(entry: ...)` function that takes in an `entry`, and `completion: @escaping (_ result: Result<Entry?, EntryError>) -> Void)` that will take in an entry, and save it to the private database
* Turn your entry into a `CKRecord` (Using the convenience initializer we used on `CKRecord`)
* Access your private database using the CKContainer and then call the save method 

```swift
CKContainer.default().privateCloudDatabase.save(record: CKRecord, completionHandler:(CKRecord?, Error?) -> Void)
```

* Handle the error that this function build your first  case on your Error extension 
 
* If you successfully saved your record, unwrap it and call the convenience initializer to create an entry from the record. 
* Append this newly initialized entry to your entries array. 
	* *This process of initializing another entry from our record may seem redundant, but it ensures the data in CloudKit will match what the user sees locally (i.e. if the record fails to save for some reason, it will not show up on the user's phone).*
	* complete with success


## Read (Fetch)

*  Create a `fetchEntriesWith(completion: @escaping(_ result: Result<[Entry]?,EntryError>)` function that only has a completion handler. This will fetch all the entries in your private database.
* In order to perform a query to the private database, you will need to create a `CKQuery`. 
* A `CKQuery` takes in two parameters, `recordType: String` and `predicate: NSPredicate` The recordType will be a string representation of our CKRecord. You can call this string off of the static property in your `Constants` struct. 
* `NSPredicate` is a definition of logical conditions (true-false) used to constrain a search either for a fetch or for in-memory filtering. For this project, we want to get all entries back from the private database so we will be using the initializer that takes in a value, and we will be setting that value to `true` This tells the predicate to just return everything.
* Now call `CKContainer.default().privateCloudDatabase.perform(query: inZoneWith: completionHandler:)`. Plug in your `CKQuery` for the query, and `nil` for inZoneWith. 
	* In smaller apps, you typically will keep this value nil. 
* The `Result` gives us an optional error and an optional array of `Entry`s. Check for error, and if there is an error, call `completion(.Failure)` 
* Unwrap your array of records, and if it’s nil. call `completion(.Failure)` 
* Now that you have an array of `CKRecords`, you can loop through the array and attempt to initialize an `Entry` with them. We are able to do this because we created a the failable initializer in the Model that takes in a `CKRecord`
	* use the `compactMap` higher order function on your returned records to create an array of `Entry` from those records
* After the loop, you can set `self.entries` to equal the array you created. 
* Call `completion(.success(entries))`



# Part Two - User Interface
## EntryListTableViewController
Build a view that lists all journal entries. You will use a UITableViewController and implement the UITableViewDataSource functions.

You will want this view to reload the table view each time it appears in order to display newly created entries.

* Add a UITableViewController as your root view controller in Main.storyboard and embed it into a UINavigationController
* Create an `EntryListTableViewController` file as a subclass of UITableViewController and set the class of your root view controller scene
* Implement the UITableViewDataSource functions using the EntryController `entries` array
* Pay attention to your `reuseIdentifier` in the Storyboard scene and your `dequeueReusableCell(withIdentifier:for:)` function call
* Set up your cells to display the title and timestamp of the entry
* Add a UIBarButtonItem to the UINavigationBar with the plus symbol
* Select ‘Add’ in the System Item menu from the Identity Inspector to set the button as a plus symbol, these are system bar button items and include localization and other benefits
* Call the `fetchEntries` function from your `EntryController` in the `ViewDidLoad` of the tableview controller.  In the completion block for `fetchEntries` call `self.tableView.reloadData()` **on the application main thread.**

## EntryDetailViewController

Build a view that provides editing and view functionality for a single entry. You will use a UITextField to capture the title, a UITextView to capture the body, a UIBarButtonItem to save the new or updated entry, and a UIButton to clear the title and body text areas.

Your Detail View should follow the ‘updateViews’ pattern for updating the view elements with the details of a model object. To follow this pattern, the developer adds an ‘updateViews’ function that checks for a model object. The function updates the view with details from the model object.

* Add an `EntryDetailViewController` file as a subclass of UIViewController.
* Add an optional `entry` property to the class (this will be our “landing pad”)
* Add a UIViewController scene to Main.storyboard and set the class to `EntryDetailViewController`
* Add a UITextField for the entry’s title text to the top of the scene, add an outlet to the class file called `titleTextField`, and set the delegate relationship
*(To set the delegate relationship control-drag from the UITextField to the current view controller in the scene dock or call*  `titleTextField.delegate = self` *in the view controller* `ViewDidLoad` *functions)*
* Add an extension to `EntryDetailViewController` with conformance to the `UITextFieldDelegate`
* Implement the delegate function `textFieldShouldReturn`  and resign first responder to dismiss the keyboard
* Add a UITextView for the entry’s body text beneath the title text field and add an outlet to the class file `bodyTextView`.
* In Storyboard Add a `UITapGuestureRecognizer` to the ViewControllers Main view by dragging it from the object library directly onto the outer view.
* Create an IBAction named `mainViewTapped(sender:)`  for the tap gesture recognizer in the `EntryDetailViewController` class.  Within the function call `resignFirstResponder` on the `bodyTextView`  and `titleTextField`  *This will allow the user to dismiss the keyboard by touching anywhere on the outer screen.*
* Add a UIButton beneath the body text view and add an IBAction called `clearButtonTapped(sender:)` to the class file that clears the text in the `titleTextField` and `bodyTextView`
* Add a `UIBarButtonItem` to the `UINavigationBar` as a `Save` System Item and add an IBAction to the class file called `saveButtonTapped(sender:)`
*(You may need to add a segue from* `EntryListTableViewController` *to see a UINavigationBar on the detail view, and a UINavigationItem to add the UIBarButtonItem to the UINavigationBar)*
* In the `saveButtonTapped(sender:)` action, guard against the title and body being empty or nil, then call the `createEntryWith(title: ...)` using the shared instance of the `EntryController`
* In the completion of  `createEntryWith(title: String, body: String, completion: @escaping (_ result: Result<Entry?, EntryError>) -> Void)`  use the current ViewController `navigationController` property to call `popViewController(animated)`  **Make sure you are on the main thread when you call** `popViewController(animated)` . *Without completing the Black Diamonds for each part, our program will have a bug.  When a user goes to edit an entry, the entry will duplicate saving a new edited version but also maintaining the old version, locally and in CloudKit.*
* Add an `updateViews()` function that checks if the optional `entry` property holds an entry. If it does, implement the function to update all view elements that reflect details about the model object `entry` (in this case, the titleTextField and bodyTextView)
* Place a `didSet` on the `entry` property which calls `loadViewIfNeeded`  then `updateViews` anytime the entry is set.
* You may also notice, after we save an entry, it doesn’t immediately show up in our `tableView` as we pop back to the `EntryListTableViewController`.  Fix this by calling `tableView.reloadData()` in the `viewWillAppear` function on the `EntryListTableViewController`

## Segue

You will add two separate segues from the List View to the Detail View. The segue from the plus button will tell the EntryDetailViewController that it should create a new entry. The segue from a selected cell will tell the EntryDetailViewController that it should display a previously created entry, and save any changes to the same.

* Add a ‘show’ segue from the Add button to the EntryDetailViewController scene and give the segue an identifier
(*When naming the identifier, consider that this segue will be used to add an entry*)
* Add a ‘show’ segue from the table view cell to the EntryDetailViewController scene and give the segue an identifier of “toEditEntry”.
* Add a `prepare(for segue: UIStoryboardSegue, sender: Any?)` function to the EntryListTableViewController
* Implement the `prepare(for segue: UIStoryboardSegue, sender: Any?)` function. If the identifier is “toEditEntry” we will pass the selected entry to the `EntryDetailViewController`, which will call our `updateViews()` function
* You will need to capture the selected entry by using the indexPath of the selected cell
* Since we aren’t passing an entry if the identifier is ‘toAddEntry’ we don’t need to account for this in our `prepare(for segue: UIStoryboardSegue, sender: Any?)`

# Black Diamonds
* Add swipe to delete functionality which removes entries locally and from `CloudKit`.
* Write a function which allows you to modify entries in locally and in `CloudKit`.  *Hint: You will need to use the*`CKModifiyRecordsOperation`*class.*[*Documenation*](https://developer.apple.com/documentation/cloudkit/ckmodifyrecordsoperation)*
*Second Hint: This might be on your test*
* In the detail view controller, when the save button is tapped, check to see if an entry exists.  If it does, update the entry locally and in CloudKit.  If it does not, create a new entry
* Present the User with an appropriate alert anytime we get an error from CloudKit or something was done wrong locally (e.g. the User tried to create an entry with a blank title)

## Contributions

If you see a problem or a typo, please fork, make the necessary changes, and create a pull request so we can review your changes and merge them into the master repo and branch.

## Copyright

© DevMountain LLC, 2020. Unauthorized use and/or duplication of this material without express and written permission from DevMountain, LLC is strictly prohibited. Excerpts and links may be used, provided that full and clear credit is given to DevMountain with appropriate and specific direction to the original content.

<p align="center">
<img src="https://s3.amazonaws.com/devmountain/readme-logo.png" width="250">
</p>
