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
    
    
    let saveButton : UIButton = {
        let button = UIButton()
        button.titleLabel?.text = "Save"
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let addTaskButton : UIButton = {
        let button = UIButton()
        button.titleLabel?.text = "Add Task"
        button.backgroundColor = UIColor.lightGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var expandingCellHeight: CGFloat = 50
    var expandingIndexRow = 0
    let cellSpacingHeight: CGFloat = 20
    
    var managedContext: NSManagedObjectContext!
    var todo: Todo?
    var tasks: [String]?
    var isExistingTodo: Bool?
    
    private var currentEdit = -1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTitleTextView()
        setUpTasksTableView()
     
        if todo == nil || todo?.tasks == nil {
            self.tasks = []
        }else{
            self.tasks = todo?.tasks
        }
    }
    
    override func loadView() {
     
//        view.addSubview(saveButton)
//        view.addSubview(addTaskButton)
//
//        saveButton.topAnchor.constraint(equalTo: tasksTableView.bottomAnchor)
//        saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor)
    }

    
    private func setUpTitleTextView(){
        titleTextView.text = todo?.name ?? "Title"
        titleTextView.textColor = (todo == nil) ? UIColor.lightGray : UIColor.black
        titleTextView.delegate = self
        titleTextView.becomeFirstResponder()
        titleTextView.selectedTextRange = titleTextView.textRange(from: titleTextView.beginningOfDocument, to: titleTextView.beginningOfDocument)
        titleTextView.translatesAutoresizingMaskIntoConstraints = false
        titleTextView.isScrollEnabled = false
        titleTextView.sizeToFit()
        titleTextView.adjustsFontForContentSizeCategory = true
    }
    
    private func setUpTasksTableView(){
        tasksTableView.sizeToFit()
        tasksTableView.estimatedRowHeight = 44.0
        tasksTableView.separatorColor = UIColor.black
        tasksTableView.delegate = self
    }

    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func saveTodo(){
        guard let name = titleTextView.text, !name.isEmpty else {
            return
        }
        
        if(currentEdit >= 0){
            self.tasks?[currentEdit] = ((tasksTableView.cellForRow(at: IndexPath(row: currentEdit, section: 0)) as? TasksTableViewCell)?.taskTextView.text)!
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
        cell.taskTextView.translatesAutoresizingMaskIntoConstraints = false
        cell.taskTextView.tag = indexPath.row
        cell.sizeToFit()
        cell.translatesAutoresizingMaskIntoConstraints = false
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
            return tableView.rowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("hi")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            completion(true)
            
            self.tasks?.remove(at: indexPath.row)
            if(self.currentEdit == indexPath.row){
                self.currentEdit == -1
            }
            self.saveTodo()
            tableView.reloadData()
            completion(true)
            
        }
        action.title = "Delete"
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

extension DetailsViewController: TasksTableViewCellDelegate {
    
    func updated(height: CGFloat, index: Int) {
        expandingCellHeight = height
        expandingIndexRow = index
        
        // Disabling animations gives us our desired behaviour
        UIView.setAnimationsEnabled(false)

        tasksTableView.beginUpdates()
        tasksTableView.endUpdates()
        // Re-enable animations
        UIView.setAnimationsEnabled(true)
        
        let indexPath = IndexPath(row: expandingIndexRow, section: 0)
        currentEdit = indexPath.row
        
        tasksTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    func updateTask(at index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        guard let cell = tasksTableView.cellForRow(at: indexPath) as? TasksTableViewCell else {
            fatalError("Unable to find cell")
        }
        
        tasks![index] = cell.taskTextView.text
        
    }
}

extension DetailsViewController : UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {

          var textFrame: CGRect  = textView.frame;
          textFrame.size.height = textView.contentSize.height;
          textView.frame = textFrame;
          self.view.layoutIfNeeded()
        
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
