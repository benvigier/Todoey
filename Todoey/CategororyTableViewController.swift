//
//  CategororyTableViewController.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/21/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import UIKit
import RealmSwift

class CategororyTableViewController: UITableViewController, UITextFieldDelegate {

    let realm = try! Realm()
    var categories : Results<Category>?
    var alertTextField : UITextField?
    var addItemAlertAction : UIAlertAction?
    var dataFilePath : URL?
    var lastSelectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    ///////////////////////////////////////////
    
    //MARK: - Header Bar + Button management
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alertAction) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        let addItemAction = UIAlertAction(title: "Add Category", style: .default) { (alertAction) in
            print("Add item selected in alert - Text = "+self.alertTextField!.text!)
            
            let category = Category()
            
            category.name = self.alertTextField!.text!
            
            //Saving the new category in the database
            do{
                try self.realm.write {
                    self.realm.add(category)
                }
                
            } catch{
                    print("An error occured while attempting to saving the new category: \(error)")
                }
            
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
    

    func loadData(){
     //Retrieving all objects of class Category from the Realm db
     categories = realm.objects(Category.self)
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories available"
        return cell
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath){
        
        if categories == nil{
            return
        }
        print("Cell selected: " + self.categories![indexPath.row].name)
        self.lastSelectedRow = indexPath.row
        performSegue(withIdentifier: "goToItems", sender: self)
      
    }
    
    ///////////////////////////////////////////
    
    //MARK: - Preparting the segue to the item list
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier != "goToItems"{
            print("Invalid segue name")
            return
        }
        let destinationVC = segue.destination as! TodoListTableViewController
        destinationVC.selectedCategory = categories![lastSelectedRow]
    }
    
}
