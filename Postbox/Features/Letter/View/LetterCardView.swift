import SwiftUI

enum SelectionCheckmarkPlacement {
    case topTrailing
    case bottom
}

struct LetterCardView: View {
    let letter: Letter
    let isLifted: Bool
    let isSelecting: Bool
    let isSelected: Bool
    var selectionCheckmarkPlacement: SelectionCheckmarkPlacement = .topTrailing

    var body: some View {
        cardContent
            .offset(y: isLifted ? -8 : 0)
            .scaleEffect(isLifted ? 1.015 : 1)
            .shadow(
                color: .black.opacity(isLifted ? 0.2 : 0.12),
                radius: isLifted ? 10 : 6,
                y: isLifted ? 8 : 3
            )
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7, blendDuration: 1),
                value: isLifted
            )
    }

    @ViewBuilder
    private var cardContent: some View {
        if isSelecting && selectionCheckmarkPlacement == .bottom {
            VStack(spacing: 6) {
                postcardSurface
                selectionCheckmark
            }
        } else {
            postcardSurface
        }
    }
    

    private var postcardSurface: some View {
        ZStack(alignment: .topTrailing) {
            postcardBody
            if isSelecting && selectionCheckmarkPlacement == .topTrailing {
                selectionCheckmark.padding(10)
            }
        }
        .aspectRatio(260.0 / 184.0, contentMode: .fit)
    }

    private var postcardBody: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                Image("Letter_Front_PostCard_Emotion")
                    .resizable()
                    .scaledToFill()

                // Sits inside the drawn "stamp" square in the artwork's
                // top-right corner, replacing its placeholder dot.
                emotionBadge
                    .frame(width: geo.size.width * 0.09, height: geo.size.width * 0.09)
                    .position(x: geo.size.width * 0.855, y: geo.size.height * 0.235)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(letter.title)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    Text(letter.date, format: .dateTime.day().month(.abbreviated))
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(width: geo.size.width * 0.58, alignment: .leading)
                .position(x: geo.size.width * 0.46, y: geo.size.height * 0.25)
            }
        }
    }

    private var emotionBadge: some View {
        // `letter.emotion` now holds an asset name (e.g. "unwell"), not an
        // emoji — swap in whichever mood asset matches the entry.
        Image(letter.emotion)
            .resizable()
            .scaledToFill()
            .clipShape(Circle())
    }

    private var selectionCheckmark: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.system(size: 22))
            .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.5))
            .background(Circle().fill(.white))
    }
}
