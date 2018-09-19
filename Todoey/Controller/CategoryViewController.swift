//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Hector Mendoza on 9/3/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: SwipeTableViewController {
    var categoriesArray: Results<Category>?
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))

        cell.addGestureRecognizer(longGesture)
        cell.textLabel?.text = categoriesArray?[indexPath.row].name
        
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
            destinationVC.selectedCategory = categoriesArray?[indexPath.row]
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
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.dateCreated = Date()
                
                self.save(category: newCategory)
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
    func save(category: Category) {
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving context: \(error)")
        }

        self.tableView.reloadData()
    }

    func loadCategories() {
        categoriesArray = realm.objects(Category.self).sorted(byKeyPath: "dateCreated", ascending: true)

        tableView.reloadData()
    }

    func deleteCategories(_ indexPath: IndexPath) {
        if let category = categoriesArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(category)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        } else {
            //empty category
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        deleteCategories(indexPath)
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
                        do {
                            try self.realm.write {
                                self.categoriesArray?[indexPath.row].name = task.text!
                            }
                            self.tableView.reloadData()
                        } catch {
                            print("Error modifying name: \(error)")
                        }
                    }
                }

                alert.addTextField { (alertTextField) in
                    task = alertTextField
                    task.text = self.categoriesArray?[indexPath.row].name
                }

                alert.addAction(action)

                present(alert, animated: true, completion: nil)
            }
        }
    }
}
