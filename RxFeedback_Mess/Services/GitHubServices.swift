import Foundation
import RxSwift
import RxSwiftExt
import Alamofire

struct GitHubSearch: Decodable {
    
    struct Repository: Decodable {
        let name: String
        let url: String
    }
    
    let items: [Repository]
}

enum GitHubServiceError: Error {
    case generic
}

/*
extension GitHubServiceError {
    var displayMessage: String {
        switch self {
        case .offline:
            return "No network connectivity"
        case .githubLimitReached:
            return "Reached GitHub throttle limit, wait 60 sec"
        }
    }
}*/

typealias SearchRepositoriesResponse = Result<(repositories: [GitHubSearch.Repository], nextURL: URL?), GitHubServiceError>

final class GitHubServices {
    func getRepositories(_ searchURL: URL) -> Single<SearchRepositoriesResponse> {
        .create { single -> Disposable in
            let request = AF.request(URLRequest(url: searchURL))
            request.responseDecodable(of: GitHubSearch.self) { response in
                
                switch response.result {
                case .success(let gitHubSearch):
                    
                    let nextURL = try? GitHubServices.parseNextURL(response.response)
                    
                    single(.success(.success((repositories: gitHubSearch.items, nextURL: nextURL))))
                    
                case .failure(_): break
                    
                    // TODO: Parse it to GitHubServiceError properly in future
                    /*
                     SearchRepositoriesResponse.failure(.generic)
                     single(.error(SearchRepositoriesResponse.failure(.generic).rawValue))
                     single(.error(error))
                     */
                }
            }
            return Disposables.create { request.cancel() }
        }
    }
}

extension GitHubServices {

    private static func parseNextURL(_ httpResponse: HTTPURLResponse?) throws -> URL? {
        guard let serializedLinks = httpResponse?.allHeaderFields["Link"] as? String else {
            return nil
        }
        
        let links = try GitHubServices.parseLinks(serializedLinks)
        
        guard let nextPageURL = links["next"] else {
            return nil
        }
        
        guard let nextUrl = URL(string: nextPageURL) else {
            return nil
        }
        
        return nextUrl
    }
    
    private static let parseLinksPattern = "\\s*,?\\s*<([^\\>]*)>\\s*;\\s*rel=\"([^\"]*)\""
    private static let linksRegex = try! NSRegularExpression(pattern: parseLinksPattern, options: [.allowCommentsAndWhitespace])

    private static func parseLinks(_ links: String) throws -> [String: String] {

        let length = (links as NSString).length
        let matches = GitHubServices.linksRegex.matches(in: links, options: NSRegularExpression.MatchingOptions(), range: NSRange(location: 0, length: length))

        var result: [String: String] = [:]

        for m in matches {
            let matches = (1 ..< m.numberOfRanges).map { rangeIndex -> String in
                let range = m.range(at: rangeIndex)
                let startIndex = links.index(links.startIndex, offsetBy: range.location)
                let endIndex = links.index(links.startIndex, offsetBy: range.location + range.length)
                return String(links[startIndex ..< endIndex])
            }

            if matches.count != 2 {
                throw error("Error parsing links")
            }

            result[matches[1]] = matches[0]
        }
        
        return result
    }
}
