import RxSwift
import RxCocoa
import RxFeedback

final class GitHubListViewModel {
    
    private let disposeBag = DisposeBag()
    
    private let githubServices: GitHubServices
    
    init(
        githubServices: GitHubServices = GitHubServices()
    ) {
        self.githubServices = githubServices
    }
    
    func bind(
        _ UI: @escaping (Driver<GitHubState>) -> Signal<GitHubEvent>
    ) -> Driver<GitHubState> {
        return Driver.system(
            initialState: GitHubState.empty,
            reduce: GitHubState.reduce,
            feedback:
                UI,
                react(request: { $0.loadNextPage }, effects: { [githubServices] resource in
                    return githubServices
                        .getRepositories(resource)
                        .asObservable()
                        .asSignal(onErrorJustReturn: .failure(.generic))
                        .map(GitHubEvent.response)
                    })
        )
    }
    
    func triggerLoadNextPage(
        state: Driver<GitHubState>,
        nearBottom: Signal<()>
    ) -> Signal<GitHubEvent> {
        return state.flatMapLatest { state -> Signal<GitHubEvent> in
            if state.shouldLoadNextPage {
                return Signal.empty()
            }
            
            return nearBottom
                .skip(1)
                .map { _ in GitHubEvent.scrollingNearBottom }
        }
    }
    
    func search(
        text: ControlProperty<String?>
    ) -> Signal<GitHubEvent> {
        text
            .orEmpty
            .changed
            .asSignal()
            .map(GitHubEvent.searchChanged)
    }
}

