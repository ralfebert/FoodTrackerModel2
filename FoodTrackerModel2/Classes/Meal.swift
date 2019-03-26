// Copyright © 2016 Apple Inc.; 2019 Ralf Ebert; see LICENSE.txt

import os.log
import UIKit

public class Meal: NSObject, NSCoding {

    // MARK: Properties

    public var name: String
    public var photo: UIImage?
    public var rating: Int

    // MARK: Archiving Paths

    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")

    // MARK: Types

    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }

    // MARK: Initialization

    public init?(name: String, photo: UIImage?, rating: Int) {

        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }

        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }

        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 {
            return nil
        }

        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating

    }

    // MARK: NSCoding

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.name, forKey: PropertyKey.name)
        aCoder.encode(self.photo, forKey: PropertyKey.photo)
        aCoder.encode(self.rating, forKey: PropertyKey.rating)
    }

    public required convenience init?(coder aDecoder: NSCoder) {

        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
            return nil
        }

        // Because photo is an optional property of Meal, just use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage

        let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)

        // Must call designated initializer.
        self.init(name: name, photo: photo, rating: rating)

    }
    
    
    public static func saveMeals(meals : [Meal]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if isSuccessfulSave {
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } else {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    public static func loadMeals() -> [Meal]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }

}
