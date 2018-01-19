//
//  TodoListTableViewController.swift
//  Todoey
//
//  Created by Benjamin Vigier on 1/18/18.
//  Copyright © 2018 Benjamin Vigier. All rights reserved.
//

import UIKit

class TodoListTableViewController: UITableViewController {
    
    var todoListArray = ["Buy oranges", "Get bread", "Go on vacations"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    
    
    
    
}

