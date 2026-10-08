//
//  JournalViewModel.swift
//  Postbox
//
//  Created by habil on 09/08/26.
//

import Foundation

@Observable
final class JournalViewModel {
    private let repository: JournalRepository
    
    init(repository: JournalRepository) {
        self.repository = repository
    }
}
