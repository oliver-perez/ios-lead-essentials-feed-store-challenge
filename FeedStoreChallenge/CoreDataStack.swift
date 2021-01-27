//
//  CoreDataStack.swift
//  FeedStoreChallenge
//
//  Created by Oliver Jordy Pérez Escamilla on 24/01/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

open class CoreDataStack {

	let modelName: String
	let bundle: Bundle
	
	public lazy var context: NSManagedObjectContext = {
		storeContainer.viewContext
	}()
	
	public lazy var storeContainer: NSPersistentContainer = {
		NSPersistentContainer.loadModel(name: modelName, in: bundle)
	}()

	public init(modelName: String, bundle: Bundle = .main) {
		self.modelName = modelName
		self.bundle = bundle
	}
	
	public func saveContext() {
		context.perform { [weak self] in
			guard let self = self else { return }
			do {
				try self.context.save()
			} catch let error as NSError {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		}	}

}
