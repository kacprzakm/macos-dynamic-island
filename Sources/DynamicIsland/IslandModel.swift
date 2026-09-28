import Combine
import CoreGraphics

final class IslandModel: ObservableObject {
    @Published var isExpanded = false
    @Published var isDropTargeted = false
    @Published var notchHeight: CGFloat = 0
}
