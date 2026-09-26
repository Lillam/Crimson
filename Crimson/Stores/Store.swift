//
//  BaseStore.swift
//  Crimson
//
//  Created by Liam Taylor on 24/09/2026.
//

import Foundation
import SwiftData

@Observable class Store<Model: PersistentModel> {
    @ObservationIgnored let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
        load()
    }
    
    func load() {
        fatalError("subclass must override load")
    }
    
    /// utility helper function for better readability. reload reads better
    /// than load when you're wanting to recollect the data. 
    func reload() {
        load()
    }
    
    func insert(_ item: Model) throws {
        context.insert(item)
        save(reload: true)
    }
    
    func save(reload: Bool = false) {
        do {
            try context.save()
            // whenever we save the data will now be out of date with
            // what's in the store, so we can forcefully reload the
            // data.
            if reload {
                self.reload()
            }
        } catch {
            assertionFailure("\(error)")
        }
    }
    
    func clear() {
        do {
            try context.delete(model: Model.self)
        } catch {
            assertionFailure("Could not clear the store: [\(Model.self)] \(error)")
        }
    }
}
