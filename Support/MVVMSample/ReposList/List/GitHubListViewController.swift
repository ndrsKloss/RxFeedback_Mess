import UIKit
import RxSwift
import RxCocoa

final class GitHubListViewController: UIViewController {
    
    static let configureCell = { (tableView: UITableView, row: Int, repository: GitHubSearch.Repository) -> UITableViewCell in
        let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "RepositoryCell")

        cell.textLabel?.text = repository.name
        cell.detailTextLabel?.text = repository.url.description
        return cell
    }
    
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        $0.tableFooterView = UIView()
        $0.translatesAutoresizingMaskIntoConstraints = false
        return $0
    }(UITableView())
    
    private let searchBar: UISearchBar = {
        $0.searchBarStyle = .default
        $0.placeholder = "Repository search"
        return $0
    }(UISearchBar())

    private let viewModel: GitHubListViewModel
    
    init(
        viewModel: GitHubListViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(
        coder aDecoder: NSCoder
    ) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        setupSearchBar()
        setupBind()
    }
    
    func setupView() {
        view.backgroundColor = .white
    }
    
    private func setupTableView() {
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        view.addSubview(tableView)
        
        let margins = view.layoutMarginsGuide
        let guide = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            margins.trailingAnchor.constraint(equalTo: tableView.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: guide.topAnchor),
            guide.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    private func setupSearchBar() {
        tableView.tableHeaderView = searchBar
        searchBar.sizeToFit()
    }
    
    private func setupBind() { }
}

extension GitHubListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForHeaderInSection section: Int
    ) -> CGFloat {
        return 30
    }
}
