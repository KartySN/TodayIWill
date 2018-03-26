//
//  DetailsViewController.swift
//  TodayIWill
//
//  Created by Karthik Nair on 3/23/18.
//  Copyright © 2018 Karthik Nair. All rights reserved.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController {
   
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var tasksTableView: UITableView!
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        saveTodo()
    }
    
    @IBAction func addTaskButton(_ sender: UIBarButtonItem) {
        addTask()
    }

    
    var expandingCellHeight: CGFloat = 50
    var expandingIndexRow = 0
    
    var managedContext: NSManagedObjectContext!
    var todo: Todo?
    var tasks: [String]?
    var isExistingTodo: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tasksTableView.estimatedRowHeight = 44.0
    
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DetailsViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//        tap.delegate = self
        
        titleTextView.text = todo?.name ?? "Title"
        titleTextView.textColor = (todo == nil) ? UIColor.lightGray : UIColor.black
        self.titleTextView.delegate = self
        titleTextView.becomeFirstResponder()
        titleTextView.selectedTextRange = titleTextView.textRange(from: titleTextView.beginningOfDocument, to: titleTextView.beginningOfDocument)
        titleTextView.translatesAutoresizingMaskIntoConstraints = true
        titleTextView.isScrollEnabled = false
    

        tasksTableView.sizeToFit()
        
        
        if todo == nil || todo?.tasks == nil {
            self.tasks = []
        }else{
            self.tasks = todo?.tasks
        }
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func saveTodo(){
        guard let name = titleTextView.text, !name.isEmpty else {
            return
        }
        
        if let todo = self.todo {
            todo.name = name
            todo.tasks = self.tasks
        } else {
            let todo = Todo(context: managedContext)
            todo.name = name
            todo.date = Date()
            todo.tasks = self.tasks
        }
        
        do {
            try managedContext.save()
        } catch {
            print("Error saving todo: \(error)")
        }
    }
    
    
    
    func addTask(){
        self.tasks?.append("")
        tasksTableView.reloadData()
    }

}

extension DetailsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let value = self.tasks?.count ?? 0
        return value
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as? TasksTableViewCell else{
            fatalError("Error")
        }
        
        cell.delegate = self
        
        let task = self.tasks![indexPath.row]
        cell.taskTextView.text = task
        cell.layer.cornerRadius = 8
        cell.layer.masksToBounds = true
        
        return cell
    }
}

extension DetailsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == expandingIndexRow {
            return expandingCellHeight
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hi")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            
            self.tasks?.remove(at: indexPath.row)
            
            do {
                try self.managedContext.save()
                tableView.reloadData()
                completion(true)
            } catch {
                print("delete failed: \(error)")
                completion(false)
            }
        }
        action.title = "Delete"
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Mark Done") { (action, view, completion) in
            completion(true)
            
            self.tasks?.remove(at: indexPath.row)
            
            do {
                try self.managedContext.save()
                tableView.reloadData()
                completion(true)
            } catch {
                print("mark done failed: \(error)")
                completion(false)
            }
        }
        action.title = "Mark Done"
        action.backgroundColor = UIColor.green
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension DetailsViewController: TasksTableViewCellDelegate {
    
    func updated(height: CGFloat) {
        expandingCellHeight = height
        
        // Disabling animations gives us our desired behaviour
        UIView.setAnimationsEnabled(false)

        tasksTableView.beginUpdates()
        tasksTableView.endUpdates()
        // Re-enable animations
        UIView.setAnimationsEnabled(true)
        
        let indexPath = IndexPath(row: expandingIndexRow, section: 0)
        
        tasksTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
}

extension DetailsViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: .greatestFiniteMagnitude))
        var newFrame = textView.frame
        
        let baseHeight: CGFloat = 50
        /* Our new height should never be smaller than our base height, so use the larger of the two */
        let height: CGFloat = newSize.height > baseHeight ? newSize.height : baseHeight
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: height)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        
        if updatedText.isEmpty {
            
            textView.text = "Title"
            textView.textColor = UIColor.lightGray
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        }
            
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = UIColor.black
        }else if(text == "\n"){
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}

extension DetailsViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if(touch.view?.isDescendant(of: tasksTableView))!{
            print("false")
            return false
        }
        print("true")
        return true
    }
    
    
}

fileprivate extension DetailsViewController {
    
    fileprivate func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let userInfo = notification.userInfo,
            let keyBoardValueBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue,
            let keyBoardValueEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, keyBoardValueBegin != keyBoardValueEnd else {
                return
        }
        
        let keyboardHeight = keyBoardValueEnd.height
        
        tasksTableView.contentInset.bottom = keyboardHeight
    }
}
