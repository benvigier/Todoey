//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/18/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController, UITextFieldDelegate {
    
    var todoListArray : [String] = []
    var alertTextField : UITextField? = nil
    var addItemAlertAction : UIAlertAction? = nil
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let array = userDefault.array(forKey: "todoListArray")
        if array != nil{
            todoListArray = array as! [String]
            tableView.reloadData()
        }
        else{
            print("No data stored")
        }
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
        
        cell.textLabel?.text = todoListArray[indexPath.row]
        
        return cell
    }
    
    
    ///////////////////////////////////////////
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath){
        tableView.deselectRow(at: indexPath, animated: true)
        print("Cell selected: " + self.todoListArray[indexPath.row])
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
           tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
        else{
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
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
            self.todoListArray.append(self.alertTextField!.text!)
            self.userDefault.setValue(self.todoListArray, forKey: "todoListArray")
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
    
    
}


