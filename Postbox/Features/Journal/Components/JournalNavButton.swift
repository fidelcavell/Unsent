//
//  JournalNavButton.swift
//  Postbox
//
//  Created by Fidel Fausta Cavell on 11/08/26.
//

import SwiftUI

struct JournalNavButton: View {
    var assetName: String
    var buttonTitle: String
    
    var xImageAsset: CGFloat
    var yImageAsset: CGFloat
    
    var xnavButton: CGFloat
    var ynavButton: CGFloat
    
    var degree: Double
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            if let action = action {
                action()
            } else {
                print("Journal Nav Button!")
            }
        } label: {
            ZStack {
                Image("halaman_kertas_kosong")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 450)
                
                Image(assetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .offset(x: xImageAsset, y: yImageAsset)
                
                Text(buttonTitle)
                    .font(.title3)
                    .fontWeight(.medium)
                    .rotationEffect(Angle(degrees: -degree))
                    .offset(x: xImageAsset - -5, y: yImageAsset + 80)
                
            }
            .rotationEffect(Angle(degrees: degree))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .offset(x: xnavButton, y: ynavButton)
    }
}

#Preview {
    JournalNavButton(
        assetName: "button_back",
        buttonTitle: "Add new page",
        xImageAsset: -72,
        yImageAsset: -210,
        xnavButton: 520,
        ynavButton: 500,
        degree: 7
    )
}
