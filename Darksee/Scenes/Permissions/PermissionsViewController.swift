import UIKit

protocol PermissionsDisplayLogic: AnyObject {
    func displayLoadGreeting(_ viewModel: Permissions.LoadGreeting.ViewModel)
}

class PermissionsViewController: UIViewController {
    // MARK: - Views
    private lazy var rootView = PermissionsViews.RootView()

    // MARK: - Variables
    private let interactor: PermissionsInteractor
    private let router: PermissionsRouter

    // MARK: - Life Cycle
    init(interactor: PermissionsInteractor, router: PermissionsRouter) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        loadGreating()
    }

    // MARK: - Setup
    private func setupViews() {
        view.addSubview(rootView)
        rootView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rootView.topAnchor.constraint(equalTo: view.topAnchor),
            rootView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            rootView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rootView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupActions() {
        rootView.setupStartButtonHandler { [weak self] in self?.start() }
    }
    
    // MARK: - Actions
    private func loadGreating() {
        let request = Permissions.LoadGreeting.Request(parameter: false)
        interactor.loadGreeting(request)
    }
    
    private func start() {
        router.routeToSomewhere()
    }
}

// MARK: - Display Logic
extension PermissionsViewController: PermissionsDisplayLogic {
    // MARK: - Load Greating
    func displayLoadGreeting(_ viewModel: Permissions.LoadGreeting.ViewModel) {
        switch viewModel {
        case .loading:
            // TODO: Show loading indicator
            ()
        case let .error(error):
            // TODO: Hide loading indicator
            ()
        case .greeting:
            // TODO: Hide loading indicator
            rootView.populate(viewModel)
        }
    }
}
