//
//  FeedImage+CoreDataProperties.swift
//  FeedStoreChallenge
//
//  Created by Oliver Jordy Pérez Escamilla on 27/01/21.
//  Copyright © 2021 Essential Developer. All rights reserved.
//
//

import Foundation
import CoreData


extension FeedImage {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedImage> {
        return NSFetchRequest<FeedImage>(entityName: "FeedImage")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var imageDescription: String?
    @NSManaged public var location: String?
    @NSManaged public var url: URL?
    @NSManaged public var feedCache: FeedCache?

}

extension FeedImage : Identifiable {

}
