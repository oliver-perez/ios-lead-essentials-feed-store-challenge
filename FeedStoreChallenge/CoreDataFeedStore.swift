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
	let managedObjectContext: NSManagedObjectContext
	let coreDataStack: CoreDataStack

	// MARK: Initializers
	public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
		self.managedObjectContext = managedObjectContext
		self.coreDataStack = coreDataStack
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		
		let feedCache = FeedCache(context: managedObjectContext)
		
		let feedImages: [FeedImage] = feed.map {
			let feedImage = FeedImage(context: managedObjectContext)
			feedImage.id = $0.id
			feedImage.location = $0.location
			feedImage.imageDescription = $0.description
			feedImage.url = $0.url
			
			return feedImage
		}
		
		feedCache.feedImages = NSOrderedSet(array: feedImages)
		feedCache.timestamp = timestamp

		coreDataStack.saveContext()
		completion(nil)
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		let fetchRequest: NSFetchRequest<FeedCache> = FeedCache.fetchRequest()
		
		do {
			let result = try coreDataStack.context.fetch(fetchRequest)
			
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
		
	static func loadModel(name: String, in bundle: Bundle, descriptions:  [NSPersistentStoreDescription] = []) -> NSPersistentContainer {
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
