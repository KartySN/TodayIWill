//
//  TodoTableViewController.swift
//  TodayIWill
//
//  Created by Karthik Nair on 3/20/18.
//  Copyright © 2018 Karthik Nair. All rights reserved.
//

import UIKit
import os.log
import CoreData


class TodoTableViewController: UITableViewController {

    var resultsController: NSFetchedResultsController<Todo>!
    let coreDataStack = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
        
        request.sortDescriptors = [sortDescriptors]
        
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        resultsController.delegate = self
        
        do {
           try resultsController.performFetch()
        } catch {
            print("Perform fetch error: \(error)")
        }
        
    }
    
    //TableView SetUp Start
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return resultsController.sections?[section].objects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoCell", for: indexPath) as? TodoTableViewCell else {
                fatalError("error")
            }
            
            let todo = resultsController.object(at: indexPath)
           
            cell.titleLabel.text = todo.name
            cell.firstItem.text = todo.tasks?.first ?? ""
            
            return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }
        }
        
//        action.image = #imageLiteral(resourceName: "Trash")
        action.title = "Delete"
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if segue.identifier == "AddTodoSegue",
            let destination = segue.destination as? DetailsViewController
        {
            destination.managedContext = resultsController.managedObjectContext
            destination.isExistingTodo = false
        }else if segue.identifier == "ShowDetailsSegue",
            let destination = segue.destination as? DetailsViewController,
            let destinationIndex = tableView.indexPathForSelectedRow
         {
                let todo = resultsController.object(at: destinationIndex)
                destination.managedContext = resultsController.managedObjectContext
                destination.todo = todo
                destination.isExistingTodo = true
            }
        }
        
}

extension TodoTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TodoTableViewCell{
                let todo = resultsController.object(at: indexPath)
                cell.titleLabel.text = todo.name
                cell.firstItem.text = todo.tasks?.first ?? ""
            }
        default:
            break
        }
    }
}
