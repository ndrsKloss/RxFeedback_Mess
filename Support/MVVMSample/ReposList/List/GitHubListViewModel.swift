import RxSwift
import RxCocoa

final class GitHubListViewModel {
    
    private let githubServices: GitHubServices
    
    init(
        githubServices: GitHubServices = GitHubServices()
    ) {
        self.githubServices = githubServices
    }
    
    func bind() { }
}

