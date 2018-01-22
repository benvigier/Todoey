//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/18/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import UIKit
import RealmSwift


class TodoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    let realm = try! Realm()
    var allItemsForSelectedCategory : Results<ToDoItem>?
    var itemsToDisplay : Results<ToDoItem>?
    var selectedCategory : Category? {
        didSet{
            loadSelectedCategoryItems()
        }
    }
    
    let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
    var alertTextField : UITextField?
    var addItemAlertAction : UIAlertAction?
    
    
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
        
        return itemsToDisplay?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemsToDisplay?[indexPath.row].label ?? "No items available"
        
        if itemsToDisplay != nil{
            cell.accessoryType = itemsToDisplay![indexPath.row].isSelected ? .checkmark : .none
        }
        else{
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath){
                
        if self.itemsToDisplay == nil{
            return
        }
        
        print("Cell selected: " + self.itemsToDisplay![indexPath.row].label)
        tableView.deselectRow(at: indexPath, animated: true)
        
        do{
            try realm.write{
                self.itemsToDisplay![indexPath.row].isSelected = !self.itemsToDisplay![indexPath.row].isSelected
            }
        } catch{
            print("An error occurred while attempting to update the item in the db : \(error)")
        }
        
        tableView.reloadData()
        
       // self.saveData()
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
  
            //Saving the new item in the Realm db
            do{
                try self.realm.write {
                    
                    let item = ToDoItem()
                    item.label = self.alertTextField!.text!
                    item.isSelected = false
                    self.selectedCategory?.items.append(item)
                }
            } catch{
                print("An error occured while attempting to save the new item to the db : \(error)")
            }
            
            self.allItemsForSelectedCategory = self.itemsToDisplay
            
            
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
    
    func loadSelectedCategoryItems(){
        
       itemsToDisplay = selectedCategory!.items.sorted(byKeyPath: "label", ascending: true)
       //itemsToDisplay = selectedCategory!.items.sorted(byKeyPath: "dateCreated", ascending: true)
        allItemsForSelectedCategory = itemsToDisplay
    }
    
   
    
} // END OF CLASS


//MARK - Search bar management
extension TodoListTableViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        
        print("Search button text did change")
        
        let text = searchBar.text
        
        if text == nil{
            itemsToDisplay = allItemsForSelectedCategory
            self.tableView.reloadData()
            return
        }
        
        if text!.trimmingCharacters(in: .whitespaces) == ""{
            itemsToDisplay = allItemsForSelectedCategory
            self.tableView.reloadData()
            return
        }
        
        let predicate = NSPredicate(format: "label CONTAINS[cd] %@", text!)
        
        self.itemsToDisplay = itemsToDisplay!.filter(predicate)
        self.tableView.reloadData()
        
    }
    

    

}


