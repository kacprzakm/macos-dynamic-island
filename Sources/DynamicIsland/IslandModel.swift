import Combine
import CoreGraphics

final class IslandModel: ObservableObject {
    @Published var isExpanded = false
    @Published var notchHeight: CGFloat = 0
}
