import Foundation

func error(_ error: String, location: String = "\(#file):\(#line)") -> NSError {
    return NSError(domain: "Error", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(location): \(error)"])
}
