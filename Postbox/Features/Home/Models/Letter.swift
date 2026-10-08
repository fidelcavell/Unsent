//
//  Letter.swift
//  Postbox
//
//  Created by Theona Arlinton on 10/08/26.
//
import SwiftUI

struct Letter: Identifiable, Equatable, Hashable {
    let id: UUID
    var title: String
    var date: Date
    var content: String
    var emotion: String // asset name of a mood illustration, e.g. "unwell"
    var sealColor: Color

    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        content: String,
        emotion: String = "unwell",
        sealColor: Color = .red
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.content = content
        self.emotion = emotion
        self.sealColor = sealColor
    }
}
