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
	lazy var context: NSManagedObjectContext = {
		Self.coreDataStack.context
	}()
	private static var coreDataStack: CoreDataStack = CoreDataStack(modelName: "FeedStoreModel")
	
	// MARK: Initializers
	public init(coreDataStack: CoreDataStack) {
		Self.coreDataStack = coreDataStack
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		context.perform { [unowned context] in
			
			do {
				guard let cache = try self.fetchCache() else { return completion(nil) }
				context.delete(cache)
				
				completion(nil)
				
			} catch {
				return completion(error)
			}
			
			Self.coreDataStack.saveContext()
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		context.perform { [unowned self] in
			
			do {
				if let cache = try self.fetchCache() {
					self.context.delete(cache)
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
			
			do {
				try self.context.save()
			} catch {
				completion(error)
			}
			completion(nil)
		}
		
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		do {
			let cache = try fetchCache()
			
			let localFeedResult = cache.map {
				(feed: $0.feedImages, timestamp: $0.timestamp)
			}
			
			guard let feedResult = localFeedResult,
						let timestamp = localFeedResult?.timestamp
			else { return completion(.empty) }
			
			let feed = feedResult.feed?.array as? [FeedImage] ?? []
			
			let retrievedImages: [LocalFeedImage] = feed.compactMap {
				guard let id = $0.id, let url = $0.url else { return nil }
				return LocalFeedImage(id: id,
															description: $0.imageDescription,
															location: $0.location,
															url: url)
			}
			
			return completion(.found(feed: retrievedImages, timestamp: timestamp))
		} catch {
			return completion(.failure(error))
		}
	}
	
	private func fetchCache() throws -> FeedCache? {
		let fetchRequest: NSFetchRequest<FeedCache> = FeedCache.fetchRequest()
		let result = try Self.coreDataStack.context.fetch(fetchRequest)
		
		return result.first
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
