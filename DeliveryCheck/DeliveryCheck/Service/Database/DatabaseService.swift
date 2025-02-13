//
//  DatabaseService.swift
//  DeliveryCheck
//
//  Created by 현수빈 on 2/13/25.
//

import Foundation
import SwiftData
import Dependencies

extension DependencyValues {
    var swiftData: DatabaseService {
        get { self[DatabaseService.self] }
        set { self[DatabaseService.self] = newValue }
    }
}

struct DatabaseService {
    var fetchAll: @Sendable () throws -> [Item]
    var fetch: @Sendable (FetchDescriptor<Item>) throws -> [Item]
    var add: @Sendable (Item) throws -> Void
    var delete: @Sendable (Item) throws -> Void
    var edit: @Sendable (Item) throws -> Void
    var save: @Sendable () throws -> Void
    
    enum MovieError: Error {
        case add
        case delete
        case edit
        case save
    }
}

extension DatabaseService: DependencyKey {
    public static let liveValue = Self(
        fetchAll: {
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = try context()
                
                let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\.state)])
                return try movieContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        fetch: { descriptor in
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = try context()
                return try movieContext.fetch(descriptor)
            } catch {
                return []
            }
        },
        add: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = try context()
                
                movieContext.insert(model)
                try movieContext.save()
            } catch {
                throw MovieError.add
            }
        },
        delete: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = try context()
                
                let modelToBeDelete = model
                movieContext.delete(modelToBeDelete)
                try movieContext.save()
            } catch {
                throw MovieError.delete
            }
        },
        edit: { model in
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = try context()
                try movieContext.save()
            } catch {
                throw MovieError.edit
            }
        },
        save: {
            do {
                @Dependency(\.databaseService.context) var context
                let movieContext = try context()
                try movieContext.save()
            } catch {
                throw MovieError.save
            }
        }
    )
}

extension DatabaseService: TestDependencyKey {
    public static var previewValue = Self.noop
    
    public static let testValue = Self(
        fetchAll: unimplemented("\(Self.self).fetch"),
        fetch: unimplemented("\(Self.self).fetchDescriptor"),
        add: unimplemented("\(Self.self).add"),
        delete: unimplemented("\(Self.self).delete"),
        edit: unimplemented("\(Self.self).edit"),
        save: unimplemented("\(Self.self).save")
    )
    
    static let noop = Self(
        fetchAll: { [] },
        fetch: { _ in [] },
        add: { _ in },
        delete: { _ in },
        edit: { _ in },
        save: { }
    )
}
