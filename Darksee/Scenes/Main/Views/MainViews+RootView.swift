import UIKit

extension MainViews {
    class RootView: UIView {
        // MARK: - Views
        private var jetView: PreviewMetalView = {
            let metalView = PreviewMetalView(frame: .zero)
            metalView.rotation = .rotate90Degrees
            return metalView
        }()
        private lazy var smoothingActionView: RoundedButtonView = {
            return RoundedButtonView(
                imageName: "waveform.path.ecg.rectangle",
                selectedImageName: "waveform.path.ecg.rectangle.fill",
                imageWeight: .medium,
                enabled: true,
                tapAction: { [weak self] enabled in
                    self?.switchSmoothing(enabled: enabled)
                }
            )
        }()
        private var aaa: UILabel = {
            let aaa = UILabel()
            aaa.text = "Aaaaa"
            aaa.textColor = .green
            return aaa
        }()
        
        // MARK: - Variables
        var currentDrawableSize: CGSize!
        private var smoothingSwitchActionHandler: ((_ enabled: Bool) -> Void)?

        // MARK: - Life Cycle
        init() {
            super.init(frame: .zero)
            setupViews()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Setup
        func setupSmoothingSwitchActionHandler(_ handler: @escaping (Bool) -> Void) {
            smoothingSwitchActionHandler = handler
        }
        
        private func setupViews() {
            backgroundColor = .systemBackground
            setupMetalKitView()
            setupSmoothingActionView()
        }
        
        func setupMetalKitView() {
            addSubview(jetView)
            jetView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                jetView.topAnchor.constraint(equalTo: topAnchor),
                jetView.leadingAnchor.constraint(equalTo: leadingAnchor),
                jetView.trailingAnchor.constraint(equalTo: trailingAnchor),
                jetView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
        
        func setupSmoothingActionView() {
            addSubview(smoothingActionView)
            smoothingActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                smoothingActionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -30),
                smoothingActionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
                smoothingActionView.widthAnchor.constraint(equalToConstant: 70),
                smoothingActionView.heightAnchor.constraint(equalToConstant: 70)
            ])
        }
        
        // MARK: - Populate
        func updateJetView(_ viewModel: Main.LoadGreeting.ViewModel) {
            guard case let .greeting(pixelBuffer) = viewModel else {
                return
            }
            jetView.pixelBuffer = pixelBuffer
        }
        
        func stopJetView() {
            jetView.pixelBuffer = nil
            jetView.flushTextureCache()
        }
        
        // MARK: - Actions
        @objc private func switchSmoothing(enabled: Bool) {
            smoothingSwitchActionHandler?(enabled)
        }
    }
}
