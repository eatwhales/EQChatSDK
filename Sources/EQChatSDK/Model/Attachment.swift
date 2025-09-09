import Foundation

public struct Attachment: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    
    public init(id: String) {
        self.id = id
    }
}

public enum AttachmentType: String, Codable, Sendable {
    case none
    
    public var title: String {
        return "None"
    }
}

#if DEBUG
extension Attachment {
    static func randomImage() -> Attachment {
        Attachment(id: UUID().uuidString)
    }
}
#endif