import UIKit

protocol MainDisplayLogic: AnyObject {
    func displayLoadGreeting(_ viewModel: Main.LoadGreeting.ViewModel)
}

class MainViewController: UIViewController {
    // MARK: - Views
    private lazy var rootView = MainViews.RootView()

    // MARK: - Variables
    private let interactor: MainInteractor
    private let router: MainRouter

    // MARK: - Life Cycle
    init(interactor: MainInteractor, router: MainRouter) {
        self.interactor = interactor
        self.router = router
        super.init(nibName: nil, bundle: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        interactor.requestCameraAuthorization()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
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
//        rootView.setupStartButtonHandler { [weak self] in self?.start() }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForground),
                                               name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Actions
    private func start() {
        router.routeToSomewhere()
    }
    
    // MARK: - Helpers
    @objc func didEnterBackground(notification: NSNotification) {
        // Free up resources
        interactor.updateRenderingStatus(enabled: false)
        rootView.stopJetView()
    }
    
    @objc func willEnterForground(notification: NSNotification) {
        ()
    }
}

// MARK: - Display Logic
extension MainViewController: MainDisplayLogic {
    // MARK: - Load Greating
    func displayLoadGreeting(_ viewModel: Main.LoadGreeting.ViewModel) {
        switch viewModel {
        case .loading:
            // TODO: Show loading indicator
            ()
        case let .error(error):
            // TODO: Hide loading indicator
            ()
        case .greeting:
            // TODO: Hide loading indicator
            rootView.updateJetView(viewModel)
        }
    }
}
