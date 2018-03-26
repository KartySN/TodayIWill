//
//  CoreDataStack.swift
//  TodayIWill
//
//  Created by Karthik Nair on 3/23/18.
//  Copyright © 2018 Karthik Nair. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "TodosDataModel")
        container.loadPersistentStores { (description,error) in
            guard error == nil else {
                print("ERROR: \(error!)")
                return
            }
        }
        return container
    }
    var managedContext : NSManagedObjectContext {
        return container.viewContext
    }
}
