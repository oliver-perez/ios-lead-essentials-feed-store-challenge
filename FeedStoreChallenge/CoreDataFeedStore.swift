//
//  CoreDataFeedStore.swift
//  FeedStoreChallenge
//
//  Created by Oliver Jordy Pérez Escamilla on 23/01/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//

import Foundation
import CoreData

public final class CoreDataFeedStore: FeedStore {
	
	// MARK: Properties
	let context: NSManagedObjectContext
	let coreDataStack: CoreDataStack

	// MARK: Initializers
	public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
		self.context = managedObjectContext
		self.coreDataStack = coreDataStack
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform { [unowned context] in
			let fetchRequest: NSFetchRequest<FeedCache> = FeedCache.fetchRequest()

			do {
				guard let result = try self.coreDataStack.context.fetch(fetchRequest).first else { return completion(nil) }
				context.delete(result)
				
				completion(nil)
				
			} catch {
				return completion(error)
			}
			
			self.coreDataStack.saveContext()
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform {
			
			do {
				let fetchRequest: NSFetchRequest<FeedCache> = FeedCache.fetchRequest()

				if let result = try self.context.fetch(fetchRequest).first {
					self.context.delete(result)
				}
								
			} catch {
				return completion(error)
			}
			
			let feedCache = FeedCache(context: self.context)
			
			let feedImages: [FeedImage] = feed.map {
				let feedImage = FeedImage(context: self.context)
				feedImage.id = $0.id
				feedImage.location = $0.location
				feedImage.imageDescription = $0.description
				feedImage.url = $0.url
				
				return feedImage
			}
			
			feedCache.feedImages = NSOrderedSet(array: feedImages)
			feedCache.timestamp = timestamp
			
			self.coreDataStack.saveContext()
			completion(nil)
		}
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let fetchRequest: NSFetchRequest<FeedCache> = FeedCache.fetchRequest()
			do {
				let result = try context.fetch(fetchRequest)
				
				let localFeedResult = result.first.map {
					(feed: $0.feedImages, timestamp: $0.timestamp)
				}
				
				guard let feedResult = localFeedResult,
							let timestamp = localFeedResult?.timestamp
				else { return completion(.empty) }
				
				let feed = feedResult.feed?.array as? [FeedImage] ?? []
				
				let retrievedImages = feed.map {
					LocalFeedImage(id: $0.id!,
												 description: $0.imageDescription,
												 location: $0.location,
												 url: $0.url!)
				}
				
				return completion(.found(feed: retrievedImages, timestamp: timestamp))
			} catch {
				return completion(.failure(error))
			}
	}
	
}

public extension NSPersistentContainer {
		
		// MARK: NSPersistentContainer extension
		
	static func loadModel(name: String, in bundle: Bundle, descriptions: [NSPersistentStoreDescription] = [NSPersistentStoreDescription()]) -> NSPersistentContainer {
		guard let mom = NSManagedObjectModel.mergedModel(from: [bundle]) else {
			fatalError("Not able to find data model")
		}
		
		let container = NSPersistentContainer(name: name, managedObjectModel: mom)
		container.persistentStoreDescriptions = descriptions
		container.loadPersistentStores { d, e in
			_ = e.flatMap {_ in
				fatalError("Not able to load store")
			}
		}
		return container
	}
}
