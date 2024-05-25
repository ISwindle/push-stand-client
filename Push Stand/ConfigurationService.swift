import Foundation

class Configuration {
    static let shared = Configuration()

    private(set) var environment: String
    private(set) var baseURL: URL

    private init() {
        guard let url = Bundle.main.url(forResource: "Configuration", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let config = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any],
              let environment = config["Environment"] as? String,
              let baseURLs = config["BaseURLs"] as? [String: String],
              let baseURLString = baseURLs[environment],
              let baseURL = URL(string: baseURLString) else {
            fatalError("Unable to load configuration")
        }
        self.environment = environment
        self.baseURL = baseURL
    }
}
