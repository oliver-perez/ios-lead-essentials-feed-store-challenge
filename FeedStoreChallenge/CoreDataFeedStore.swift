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
	
	public init() {}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
	}
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		completion(.empty)
	}
	
}
