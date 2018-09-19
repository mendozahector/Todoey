//
//  ViewController.swift
//  Todoey
//
//  Created by Hector Mendoza on 8/30/18.
//  Copyright © 2018 Hector Mendoza. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    var todoItems: Results<Item>?
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    //MARK: - Tableview Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        let item = (todoItems?[indexPath.row])!
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressed(_:)))
            
        cell.addGestureRecognizer(longGesture)
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark: .none
        
        if let color = UIColor(hexString: selectedCategory!.cellColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Method
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status: \(error)")
            }
            
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if textField.text!.isEmpty {
                //do nothing
            } else {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving context: \(error)")
                    }
                } else {
                    
                }
                
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
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
                let alert = UIAlertController(title: "Modify Todoey Item", message: "", preferredStyle: .alert)

                let action = UIAlertAction(title: "Modify", style: .default) { (action) in
                    do {
                        if task.text!.isEmpty {
                            self.deleteItems(indexPath)
                        } else {
                            try self.realm.write {
                                self.todoItems?[indexPath.row].title = task.text!
                            }
                            self.tableView.reloadData()
                        }
                    } catch {
                        print("Error updating data: \(error)")
                    }
                }

                alert.addTextField { (alertTextField) in
                    task = alertTextField
                    task.text = self.todoItems?[indexPath.row].title
                }

                alert.addAction(action)

                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    
    //MARK: - Model Manipulation Methods
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
    func deleteItems(_ indexPath: IndexPath) {
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Error deleting category: \(error)")
            }
        } else {
            //empty category
        }
    }
    
    override func updateModel(at indexPath: IndexPath) {
        deleteItems(indexPath)
    }
}


//MARK: - SearchBar Methods
extension TodoListViewController: UISearchBarDelegate {

    func queryItems(_ searchBar: UISearchBar) {
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        queryItems(searchBar)
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        } else {
            queryItems(searchBar)
        }
    }
}
