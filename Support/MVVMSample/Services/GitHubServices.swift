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

final class GitHubServices {
    // URL: "https://api.github.com/search/repositories?q=\(serachString)"
    // Pagination: "https://api.github.com/search/repositories?q=\(serachString)&page=\(page)"
    func getRepositories(
        _ searchURL: URL
    ) -> Single<[GitHubSearch.Repository]> {
        .create { single -> Disposable in
            let request = AF.request(URLRequest(url: searchURL))
            request.responseDecodable(of: GitHubSearch.self) { response in
                
                switch response.result {
                case .success(let gitHubSearch):
                    single(.success(gitHubSearch.items))
                    
                case .failure(let error):
                    single(.error(error))
                }
            }
            return Disposables.create { request.cancel() }
        }
    }
}

/// Those set of functions serve to extract the direct next URL from the Link header.
/// It is part of the GitHub's Traversing with Pagination: https://developer.github.com/v3/guides/traversing-with-pagination/
/// More about Web Linking here: https://tools.ietf.org/html/rfc5988
/// Feel free to use, but be aware that there are other ways of doing it.

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
