//
//  LetterEntry.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import Foundation

struct LetterEntry: Identifiable, Equatable {
    let id: UUID
    var title: String
    var date: Date
    var previewText: String
    var fullContent: String

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        previewText: String,
        fullContent: String
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.previewText = previewText
        self.fullContent = fullContent
    }
}
