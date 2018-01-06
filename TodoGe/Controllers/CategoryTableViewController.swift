//
//  CategoryTableViewController.swift
//  TodoGe
//
//  Created by Ming jie Huang on 1/5/18.
//  Copyright © 2018 Ming jie Huang. All rights reserved.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {
    
    var categoryArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    //MARK: - TableView Datsource Methods
    
    //First - Create tableView with numberOfRowInSection function. This indicates the amount(count) in the categoryArray.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //Second - Create tableView with CellForRowAt function. This indicates the cell with indentifier, and display that cells on the screen.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let longPressedRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.addGestureRecognizer(longPressedRecognizer)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }
    
    //MARK: - TableView Manipulation Methods
    
    func saveCategories() {
        
        do{
            try context.save()
        }catch{
            print("Error saving category \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("Error loading categories \(error)")
        }
        
        tableView.reloadData()
    }
    
    // Model Manupulation Methods - Update Category in Core Data
    @objc func longPressed(_ sender: UIGestureRecognizer){
        if sender.state == UIGestureRecognizerState.ended{
            let longPressedLocation = sender.location(in: self.tableView)
            if let pressedIndexPath = self.tableView.indexPathForRow(at: longPressedLocation){
                
                var task = UITextField()
                let alert = UIAlertController(title: "Modify Name", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Modify", style: .default){ (action) in
                    
                    self.categoryArray[pressedIndexPath.row].setValue("\(task.text ?? "")", forKey: "name")
                    self.saveCategories()
                    
                }
                
                alert.addTextField { (alertTextField) in
                    task = alertTextField
                    task.text = "\(self.categoryArray[pressedIndexPath.row].name!)"
                }
                
                alert.addAction(action)
                
                present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            //what will happen once the user click the add button on our UIAlert
            
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            
            self.categoryArray.append(newCategory)
            
            self.saveCategories()
        }
        
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Create new category"
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
}

//MARK: - Search bar methods
extension CategoryTableViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        
        request.predicate  = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadCategories(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0{
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
    }
    
}
