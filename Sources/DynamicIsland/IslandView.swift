import SwiftUI

struct IslandView: View {
    @ObservedObject var model: IslandModel

    private var cornerRadius: CGFloat { model.isExpanded ? 28 : 12 }

    var body: some View {
        ZStack(alignment: .top) {
            islandShape
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var islandShape: some View {
        UnevenRoundedRectangle(
            topLeadingRadius: 0,
            bottomLeadingRadius: cornerRadius,
            bottomTrailingRadius: cornerRadius,
            topTrailingRadius: 0,
            style: .continuous
        )
        .fill(.black)
    }
}
