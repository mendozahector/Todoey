//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hector Mendoza on 9/3/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categoriesArray = [Category]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let item = categoriesArray[indexPath.row]
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
        
        cell.addGestureRecognizer(longGesture)
        cell.textLabel?.text = item.name
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
        print("indexPathSelected: \(indexPath)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoriesArray[indexPath.row]
            print("categoriesArray[indexPath.row]: \(categoriesArray[indexPath.row])")
        }
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            if textField.text!.isEmpty {
                //do nothing
            } else {
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text!
                
                self.categoriesArray.append(newCategory)
                
                self.saveCategories()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoriesArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        
        tableView.reloadData()
    }
    
    func deleteCategories(_ indexPath: IndexPath) {
        context.delete(categoriesArray[indexPath.row])
        categoriesArray.remove(at: indexPath.row)
        
        saveCategories()
    }
    
    
    //MARK: - Updating Items
    @objc func longPressed(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            //beginning of gesture
        } else if sender.state == .ended {
            //ending of gesture
            let touchPoint = sender.location(in: self.view)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                var task = UITextField()
                let alert = UIAlertController(title: "Modify Category", message: "", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Modify", style: .default) { (action) in
                    if task.text!.isEmpty {
                        self.deleteCategories(indexPath)
                    } else {
                        self.categoriesArray[indexPath.row].setValue("\(task.text ?? "")", forKey: "name")
                        self.saveCategories()
                    }
                }
                
                alert.addTextField { (alertTextField) in
                    task = alertTextField
                    task.text = "\(self.categoriesArray[indexPath.row].name!)"
                }
                
                alert.addAction(action)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
}
