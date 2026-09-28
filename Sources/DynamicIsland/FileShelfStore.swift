import Foundation
import Combine

struct ShelfItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let storedPath: String
    var url: URL { URL(fileURLWithPath: storedPath) }
}

final class FileShelfStore: ObservableObject {
    @Published private(set) var items: [ShelfItem] = []

    private let dir: URL
    private let indexURL: URL

    init() {
        let base = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DynamicIsland/shelf", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        dir = base
        indexURL = base.appendingPathComponent("index.json")
        load()
    }

    func add(_ source: URL) {
        let dest = dir.appendingPathComponent("\(UUID().uuidString)-\(source.lastPathComponent)")
        do {
            try FileManager.default.copyItem(at: source, to: dest)
        } catch {
            NSLog("Shelf copy failed for \(source.path): \(error)")
            return
        }
        items.append(ShelfItem(id: UUID(), name: source.lastPathComponent, storedPath: dest.path))
        save()
    }

    func remove(_ item: ShelfItem) {
        try? FileManager.default.removeItem(at: item.url)
        items.removeAll { $0.id == item.id }
        save()
    }

    func clear() {
        items.forEach { try? FileManager.default.removeItem(at: $0.url) }
        items.removeAll()
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL),
              let decoded = try? JSONDecoder().decode([ShelfItem].self, from: data) else { return }
        items = decoded.filter { FileManager.default.fileExists(atPath: $0.storedPath) }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: indexURL, options: .atomic)
    }
}
