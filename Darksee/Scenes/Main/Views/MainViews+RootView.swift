import UIKit

extension MainViews {
    class RootView: UIView {
        // MARK: - Views
        var jetView: PreviewMetalView = {
            let metalView = PreviewMetalView(frame: .zero)
            metalView.rotation = .rotate90Degrees
            return metalView
        }()
        private lazy var actionsStackView: UIStackView = {
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.spacing = 20
            return stackView
        }()
        private lazy var actionsBackgroundView: UIView = {
            let blurEffect = UIBlurEffect(style: .dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.clipsToBounds = true
            blurEffectView.layer.cornerRadius = 28
            blurEffectView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            return blurEffectView
        }()
        private lazy var smoothingActionView: RoundedButtonView = {
            return RoundedButtonView(
                imageName: "waveform.path.ecg.rectangle",
                selectedImageName: "waveform.path.ecg.rectangle.fill",
                imageSize: CGSize(width: 45, height: 35),
                imageWeight: .medium,
                switchable: true,
                enabled: true,
                tapAction: { [weak self] enabled in
                    self?.switchSmoothing(enabled: enabled)
                }
            )
        }()
        private lazy var torchActionView: RoundedButtonView = {
            return RoundedButtonView(
                imageName: "flashlight.off.fill",
                selectedImageName: "flashlight.on.fill",
                imageSize: CGSize(width: 20, height: 35),
                imageWeight: .medium,
                switchable: true,
                enabled: false,
                tapAction: { [weak self] enabled in
                    self?.switchTorch(enabled: enabled)
                }
            )
        }()
        private lazy var decreaseScreenBrightnessActionView: RoundedButtonView = {
            return RoundedButtonView(
                imageName: "light.min",
                imageSize: CGSize(width: 35, height: 27),
                imageWeight: .medium,
                switchable: false,
                enabled: false,
                tapAction: { [weak self] _ in
                    self?.decreaseScreenBrightness()
                }
            )
        }()
        private lazy var increaseScreenBrightnessActionView: RoundedButtonView = {
            return RoundedButtonView(
                imageName: "light.max",
                imageSize: CGSize(width: 35, height: 27),
                imageWeight: .medium,
                switchable: false,
                enabled: false,
                tapAction: { [weak self] _ in
                    self?.increaseScreenBrightness()
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
        private var torchSwitchActionHandler: ((_ enabled: Bool) -> Void)?
        private var decreaseScreenBrightnessActionHandler: (() -> Void)?
        private var increaseScreenBrightnessActionHandler: (() -> Void)?

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
        
        func setupTorchSwitchActionHandler(_ handler: @escaping (Bool) -> Void) {
            torchSwitchActionHandler = handler
        }
        
        func setupDecreaseScreenBrightnessActionHandler(_ handler: @escaping () -> Void) {
            decreaseScreenBrightnessActionHandler = handler
        }
        
        func setupIncreaseScreenBrightnessActionHandler(_ handler: @escaping () -> Void) {
            increaseScreenBrightnessActionHandler = handler
        }
        
        private func setupViews() {
            backgroundColor = .systemBackground
            setupMetalKitView()
            setupActionsBackgroundView()
            setupActionsStackView()
            setupSmoothingActionView()
            setupTorchActionView()
            setupDecreaseScreenBrightnessActionView()
            setupIncreaseScreenBrightnessActionView()
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
        
        func setupActionsBackgroundView() {
            addSubview(actionsBackgroundView)
            actionsBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                actionsBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
                actionsBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
                actionsBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
                actionsBackgroundView.heightAnchor.constraint(equalToConstant: 130)
            ])
        }
        
        func setupActionsStackView() {
            addSubview(actionsStackView)
            actionsStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                actionsStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
                actionsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                actionsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                actionsStackView.heightAnchor.constraint(equalToConstant: 70)
            ])
        }
        
        func setupSmoothingActionView() {
            addSubview(smoothingActionView)
            smoothingActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                smoothingActionView.widthAnchor.constraint(equalToConstant: 70),
                smoothingActionView.heightAnchor.constraint(equalToConstant: 70)
            ])
            actionsStackView.addArrangedSubview(smoothingActionView)
        }
        
        func setupTorchActionView() {
            addSubview(torchActionView)
            torchActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                torchActionView.widthAnchor.constraint(equalToConstant: 70),
                torchActionView.heightAnchor.constraint(equalToConstant: 70)
            ])
            actionsStackView.addArrangedSubview(torchActionView)
        }
        
        func setupDecreaseScreenBrightnessActionView() {
            addSubview(decreaseScreenBrightnessActionView)
            decreaseScreenBrightnessActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                decreaseScreenBrightnessActionView.widthAnchor.constraint(equalToConstant: 70),
                decreaseScreenBrightnessActionView.heightAnchor.constraint(equalToConstant: 70)
            ])
            actionsStackView.addArrangedSubview(decreaseScreenBrightnessActionView)
        }
        
        func setupIncreaseScreenBrightnessActionView() {
            addSubview(increaseScreenBrightnessActionView)
            increaseScreenBrightnessActionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                increaseScreenBrightnessActionView.widthAnchor.constraint(equalToConstant: 70),
                increaseScreenBrightnessActionView.heightAnchor.constraint(equalToConstant: 70)
            ])
            actionsStackView.addArrangedSubview(increaseScreenBrightnessActionView)
        }
        
        // MARK: - Populate
        func updateJetView(_ viewModel: Main.LoadData.ViewModel) {
            guard case let .data(pixelBuffer) = viewModel else {
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
        
        @objc private func switchTorch(enabled: Bool) {
            torchSwitchActionHandler?(enabled)
        }
        
        @objc private func decreaseScreenBrightness() {
            decreaseScreenBrightnessActionHandler?()
        }
        
        @objc private func increaseScreenBrightness() {
            increaseScreenBrightnessActionHandler?()
        }
    }
}
