import UIKit.UINavigationController

final class GitHubListCoordinator {
    
    let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = GitHubListViewModel()
        let viewController = GitHubListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
