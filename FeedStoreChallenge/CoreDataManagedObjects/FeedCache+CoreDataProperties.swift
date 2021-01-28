//
//  FeedCache+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Oliver Jordy Pérez Escamilla on 27/01/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedCache {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedCache> {
        return NSFetchRequest<FeedCache>(entityName: "FeedCache")
    }

    @NSManaged public var timestamp: Date?
    @NSManaged public var feedImages: NSOrderedSet?

}

// MARK: Generated accessors for feedImages
extension FeedCache {

    @objc(insertObject:inFeedImagesAtIndex:)
    @NSManaged public func insertIntoFeedImages(_ value: FeedImage, at idx: Int)

    @objc(removeObjectFromFeedImagesAtIndex:)
    @NSManaged public func removeFromFeedImages(at idx: Int)

    @objc(insertFeedImages:atIndexes:)
    @NSManaged public func insertIntoFeedImages(_ values: [FeedImage], at indexes: NSIndexSet)

    @objc(removeFeedImagesAtIndexes:)
    @NSManaged public func removeFromFeedImages(at indexes: NSIndexSet)

    @objc(replaceObjectInFeedImagesAtIndex:withObject:)
    @NSManaged public func replaceFeedImages(at idx: Int, with value: FeedImage)

    @objc(replaceFeedImagesAtIndexes:withFeedImages:)
    @NSManaged public func replaceFeedImages(at indexes: NSIndexSet, with values: [FeedImage])

    @objc(addFeedImagesObject:)
    @NSManaged public func addToFeedImages(_ value: FeedImage)

    @objc(removeFeedImagesObject:)
    @NSManaged public func removeFromFeedImages(_ value: FeedImage)

    @objc(addFeedImages:)
    @NSManaged public func addToFeedImages(_ values: NSOrderedSet)

    @objc(removeFeedImages:)
    @NSManaged public func removeFromFeedImages(_ values: NSOrderedSet)

}

extension FeedCache : Identifiable {

}
