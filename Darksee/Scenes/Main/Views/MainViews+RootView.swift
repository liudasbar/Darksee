import UIKit

extension MainViews {
    class RootView: UIView {
        // MARK: - Views
        private var jetView: PreviewMetalView!
        
        private lazy var cameraPreviewView: UIView = {
            let view = makeDefaultView(config: Config(backgroundColor: .systemBackground))
            view.layer.opacity = 0
            return view
        }()
        private var aaa: UILabel = {
            let aaa = UILabel()
            aaa.text = "Aaaaa"
            aaa.textColor = .green
            return aaa
        }()
        
        // MARK: - Variables
        var currentDrawableSize: CGSize!
        private var startButtonHandler: (() -> Void)?

        // MARK: - Life Cycle
        init() {
            super.init(frame: .zero)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        private func setupViews() {
            backgroundColor = .systemBackground
            setupCameraPreviewView()
            setupMetalKitView()
        }
        
        func setupCameraPreviewView() {
            addSubview(cameraPreviewView)
            cameraPreviewView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                cameraPreviewView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 15),
                cameraPreviewView.heightAnchor.constraint(equalToConstant: 100),
                cameraPreviewView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0)
            ])
        }
        
        func setupMetalKitView() {
            jetView = PreviewMetalView()
            jetView.rotation = .rotate90Degrees
        }

        // MARK: - Populate
        func updateJetView(_ viewModel: Main.LoadGreeting.ViewModel) {
            guard case let .greeting(pixelBuffer) = viewModel else {
                return
            }
            jetView.pixelBuffer = pixelBuffer
            addSubview(jetView)
        }
        
        func stopJetView() {
            jetView.pixelBuffer = nil
            jetView.flushTextureCache()
        }
        
        // MARK: - Actions
        @objc private func startButtonAction() {
            startButtonHandler?()
        }
    }
}
