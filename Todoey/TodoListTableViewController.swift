//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/18/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    var todoListArray : [ToDoItem] = []
    var alertTextField : UITextField?
    var addItemAlertAction : UIAlertAction?
    var dataFilePath : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("item.plist")
        
        loadData()
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return todoListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItemCell", for: indexPath)
        
        cell.textLabel?.text = todoListArray[indexPath.row].label
        
        cell.accessoryType = todoListArray[indexPath.row].isSelected ? .checkmark : .none 
        
        return cell
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath){
        
        print("Cell selected: " + self.todoListArray[indexPath.row].label)
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.todoListArray[indexPath.row].isSelected = !self.todoListArray[indexPath.row].isSelected
        
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
            let item = ToDoItem()
            item.label = self.alertTextField!.text!
            item.isSelected = false
            self.todoListArray.append(item)
            
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
    
    
   
    //Manages the enable/disable state of the Send button:
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
        let decoder = PropertyListDecoder()
        
        
        let data = try? Data(contentsOf: dataFilePath!)
        
        if data == nil{
            print("No data found")
            return
        }
        
        if let array = try? decoder.decode([ToDoItem].self, from: data!) {
            self.todoListArray = array
            return
        }
        
        print("An error occured while attempting to decode data")
        return
    }
    
    
    func saveData(){
        
        let encoder = PropertyListEncoder()
        
        do{
            let data = try encoder.encode(self.todoListArray)
            try data.write(to: self.dataFilePath!)
            
        } catch{
            print("An error occured while attempting to write data")
        }
        
    }
    
    
}


