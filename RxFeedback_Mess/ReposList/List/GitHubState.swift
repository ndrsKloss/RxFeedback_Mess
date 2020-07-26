import Foundation
import RxSwift
import RxCocoa

struct GitHubState {
    var search: String {
        didSet {
            if search.isEmpty {
                self.nextPageURL = nil
                self.shouldLoadNextPage = false
                self.results = []
                self.lastError = nil
                return
            }
            self.nextPageURL = URL(string: "https://api.github.com/search/repositories?q=\(search.URLEscaped)")
            self.shouldLoadNextPage = true
            self.lastError = nil
        }
    }
    
    var nextPageURL: URL?
    var shouldLoadNextPage: Bool
    var results: [GitHubSearch.Repository]
    var lastError: GitHubServiceError?
}

extension GitHubState {
    var loadNextPage: URL? {
        return self.shouldLoadNextPage ? self.nextPageURL : nil
    }
}

enum GitHubEvent {
    case searchChanged(String)
    case response(SearchRepositoriesResponse)
    case scrollingNearBottom
}

extension GitHubState {
    static var empty: GitHubState {
        return GitHubState(search: "", nextPageURL: nil, shouldLoadNextPage: true, results: [])
    }

    static func reduce(state: GitHubState, event: GitHubEvent) -> GitHubState {
        switch event {
        case .searchChanged(let search):
            var result = state
            result.search = search
            result.results = []
            return result
        case .scrollingNearBottom:
            var result = state
            result.shouldLoadNextPage = true
            return result
        case .response(.success(let response)):
            var result = state
            result.results += response.repositories
            result.shouldLoadNextPage = false
            result.nextPageURL = response.nextURL
            result.lastError = nil
            return result
        case .response(.failure(let error)):
            var result = state
            result.shouldLoadNextPage = false
            result.lastError = error
            return result
        }
    }
}

fileprivate extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}
