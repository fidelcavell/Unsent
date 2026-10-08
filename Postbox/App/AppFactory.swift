//
//  AppFactory.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//

import SwiftData

@Observable
final class AppFactory {
    let modelContext: ModelContext

    @ObservationIgnored
    private lazy var journalRepository = JournalRepository(modelContext: modelContext)

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func makeJournalViewModel() -> JournalViewModel {
        JournalViewModel(repository: journalRepository)
    }
}
