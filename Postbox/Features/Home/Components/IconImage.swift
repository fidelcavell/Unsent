//
//  IconImage.swift
//  Postbox
//
//  Created by Theona Arlinton on 11/08/26.
//

import SwiftUI

struct IconImage: View {
    let name: String
    var size: CGFloat = 66

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}
