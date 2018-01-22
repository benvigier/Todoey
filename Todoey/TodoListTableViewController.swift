//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/18/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import UIKit
import CoreData


class TodoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    var fullToDoListArray : [ToDoItem] = []
    var toDoListArrayToDisplay : [ToDoItem] = []
    var selectedCategory : Category? {
        didSet{
            loadSelectedCategoryItems()
        }
    }
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
    var alertTextField : UITextField?
    var addItemAlertAction : UIAlertAction?
    var dataFilePath : URL?
    let coreDataContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Monitoring taps to hide the keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        
        //Ensures that the tap events also get propagated to the default tableView handlers
        tapGestureRecognizer.cancelsTouchesInView = false
        
        self.tableView.addGestureRecognizer(tapGestureRecognizer)
        
        //Loading the CoreData database
        self.tableView.reloadData()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    
    ///////////////////////////////////////////
    
    //MARK: - Keyboard management
    
    
    @objc func tableViewTapped(){
        
        //Hiding the keyboard
        self.view.endEditing(true)
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return toDoListArrayToDisplay.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        
        cell.textLabel?.text = toDoListArrayToDisplay[indexPath.row].label
        
        cell.accessoryType = toDoListArrayToDisplay[indexPath.row].isSelected ? .checkmark : .none
        
        return cell
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath){
                
        print("Cell selected: " + self.toDoListArrayToDisplay[indexPath.row].label!)
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.toDoListArrayToDisplay[indexPath.row].isSelected = !self.toDoListArrayToDisplay[indexPath.row].isSelected
        
        tableView.reloadData()
        
        self.saveData()
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - Header Bar + Button management
    
    
    @IBAction func addItemButtonPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add item", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let addItemAction = UIAlertAction(title: "Add Item", style: .default) { (alertAction) in
            print("Add item selected in alert - Text = "+self.alertTextField!.text!)
            
            let item = ToDoItem(context: self.coreDataContext)
                
            item.label = self.alertTextField!.text!
            item.isSelected = false
            item.category = self.selectedCategory
            
            self.toDoListArrayToDisplay.append(item)
            self.fullToDoListArray.append(item)
            
            self.saveData()
            
            alert.dismiss(animated: true, completion: nil)
            self.tableView.reloadData()
        }
        
        self.addItemAlertAction = addItemAction
        
        alert.addAction(cancelAction)
        alert.addAction(addItemAction)
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "New item"
            alertTextField.delegate = self
            
            self.alertTextField = alertTextField

            //Registering to the event editingChange
            //alertTextField.addTarget(self, action: #selector(self.alertTextFieldEditingChanged(textField: alertTextField)), for: .editingChanged)
            alertTextField.addTarget(self, action: #selector(self.alertTextFieldEditingChanged), for: .editingChanged)
            
        }
        
        addItemAction.isEnabled = false
        present(alert, animated: true, completion: nil)
    }
    
    
   
    //Manages the enable/disable state of the Add New Item button:
    @objc func alertTextFieldEditingChanged() {
        
        if self.alertTextField!.text == nil{
            self.addItemAlertAction?.isEnabled = false
            return
        }
        
        var text = self.alertTextField!.text!
        text = text.trimmingCharacters(in: .whitespaces)
        if text.isEmpty{
            self.addItemAlertAction?.isEnabled = false
            return
        }
        
         self.addItemAlertAction?.isEnabled = true
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - Persistent Data Management
    
    func loadAllItemsForAllCategories(){
        
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        do{
            try self.toDoListArrayToDisplay = self.coreDataContext.fetch(request)
            self.fullToDoListArray = toDoListArrayToDisplay
        }
        catch{
            print("An error occured while attempting to read the Item database: \(error)")
        }
    }
    
    
    func loadSelectedCategoryItems(){
        
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        request.predicate = NSPredicate(format: "category.name MATCHES %@", self.selectedCategory!.name!)
        
        do{
            try self.toDoListArrayToDisplay = self.coreDataContext.fetch(request)
            self.fullToDoListArray = toDoListArrayToDisplay
            self.tableView.reloadData()
        }
        catch{
            print("An error occured while attempting to fetch Item results from database: \(error)")
        }
    }
    
    
  
    func saveData(){
        
        do{
            try self.coreDataContext.save()
            
        } catch{
            print("An error occured while attempting to save Item data : \(error)")
        }
        
    }
    
    
} // END OF CLASS


//MARK - Search bar management
extension TodoListTableViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        print("Search button text did change")
        
        let text = searchBar.text
        
        if text == nil{
            self.toDoListArrayToDisplay = fullToDoListArray
            self.tableView.reloadData()
            return
        }
        
        if text!.trimmingCharacters(in: .whitespaces) == ""{
            self.toDoListArrayToDisplay = fullToDoListArray
            self.tableView.reloadData()
            return
        }
        
        let request : NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        
        /*let labelPredicate = NSPredicate(format: "label CONTAINS[cd] %@", text!)
        let categoryPredicate = NSPredicate(format: "category.name MATCHES %@", self.selectedCategory!.name!)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [labelPredicate,categoryPredicate])
        request.predicate = compoundPredicate */
      
        let predicate = NSPredicate(format: "label CONTAINS[cd] %@ AND category.name MATCHES %@", argumentArray: [text!,self.selectedCategory!.name!])
        request.predicate = predicate
        
        request.sortDescriptors = [NSSortDescriptor(key: "label", ascending: true)]
        
        do{
            try self.toDoListArrayToDisplay = self.coreDataContext.fetch(request)
            self.tableView.reloadData()
        }
        catch{
            print("An error occured while attempting to fetch results from database: \(error)")
        }
    }
    

    

}


