//
//  ViewController.swift
//  TodoGe
//
//  Created by Ming jie Huang on 1/4/18.
//  Copyright © 2018 Ming jie Huang. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController{
    
    var todoItems : Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory : Category?{
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    //First - Create tableView with numberOfRowInSection function. This indicates the amount(count) in the itemArray.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    //Second - Create tableView with CellForRowAt function. This indicates the cell with indentifier, and display that cells on the screen.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row]{
            
            cell.textLabel?.text = item.title
            
            if let Color = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)){
                
                cell.backgroundColor = Color
                cell.textLabel?.textColor = ContrastColorOf(Color, returnFlat: true)
            }
            
            cell.addGestureRecognizer(longPressedRecognizer)
            
            // Adding a checkmark when it's indexPath cell is selected. If It's has selected, remove checkmark
            //Ternary operator ==> value = condition ? valueIfTrue : valueIfFalse
            cell.accessoryType = item.done ? .checkmark : .none
        }else{
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - Tableview Delegate Methods
    
    //Third - Create tableView with didSelectRowAt function. This indicates the selected indexpath cell on the screen
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do{
                try realm.write {
                    item.done = !item.done
                }
            }catch{
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        
        //Deselect the indexPath row with animation
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New TodoGe Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user click the add button on our UIAlert
            
            if let currentCategory = self.selectedCategory{
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Errot saving new items, \(error)")
                }
                
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new line"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK - Model Manupulation Methods
    
    func save(item : Item) {
        
        do{
            try realm.write {
                realm.add(item)
            }
        }catch{
            print("Error saving context \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
        
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let itemDeletion = self.todoItems?[indexPath.row]{
            do {
                try self.realm.write {
                    self.realm.delete(itemDeletion)
                }
            }catch{
                print("Error deleting new items, \(error)")
            }
            
        }
    }
    
    // Model Manupulation Methods - Update Items in Core Data
    @objc func longPressed(_ sender: UIGestureRecognizer){
        if sender.state == UIGestureRecognizerState.ended{
            let longPressedLocation = sender.location(in: self.tableView)
            if let pressedIndexPath = self.tableView.indexPathForRow(at: longPressedLocation){
                
                var task = UITextField()
                let alert = UIAlertController(title: "Modify Task", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Modify", style: .default){ (action) in
                    do{
                        try self.realm.write {
                            self.todoItems![pressedIndexPath.row].title = task.text!
                        }
                    }catch{
                        print("Error updating task, \(error)")
                    }
                    
                    self.tableView.reloadData()
                }
                
                alert.addTextField { (alertTextField) in
                    task = alertTextField
                    task.text = "\(self.todoItems![pressedIndexPath.row].title)"
                }
                
                alert.addAction(action)
                
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
}

//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}

