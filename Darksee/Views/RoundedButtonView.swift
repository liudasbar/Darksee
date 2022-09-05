import UIKit

class RoundedButtonView: UIView {
    // MARK: - Views
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        return imageView
    }()
    
    // MARK: - Variables
    let imageName: String
    let selectedImageName: String?
    let imageSize: CGSize
    let imageWeight: UIImage.SymbolWeight
    let switchable: Bool
    let tapAction: (_ enabled: Bool) -> Void
    var enabled: Bool
    
    required init(imageName: String,
                  selectedImageName: String? = nil,
                  imageSize: CGSize,
                  imageWeight: UIImage.SymbolWeight,
                  switchable: Bool,
                  enabled: Bool,
                  tapAction: @escaping (Bool) -> Void) {
        self.imageName = imageName
        self.selectedImageName = selectedImageName
        self.imageSize = imageSize
        self.imageWeight = imageWeight
        self.switchable = switchable
        self.enabled = enabled
        self.tapAction = tapAction
        super.init(frame: .zero)
        setupView()
        setupImageView(name: imageName, imageSize: imageSize, imageWeight: imageWeight)
        setupTapAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Setup
    func setupView() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.backgroundColor = .systemGray6
    }
    
    private func setupImageView(name: String, imageSize: CGSize, imageWeight: UIImage.SymbolWeight) {
        if let selectedImageName = selectedImageName {
            imageView.image = UIImage(
                systemName: enabled ? selectedImageName : imageName,
                withConfiguration: UIImage.SymbolConfiguration(weight: imageWeight)
            )
        } else {
            imageView.image = UIImage(
                systemName: imageName,
                withConfiguration: UIImage.SymbolConfiguration(weight: imageWeight)
            )
        }
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: imageSize.width),
            imageView.heightAnchor.constraint(equalToConstant: imageSize.height)
        ])
    }
    
    private func setupTapAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapAction))
        self.addGestureRecognizer(tap)
    }
    
    @objc private func onTapAction() {
        if let selectedImageName = selectedImageName, switchable {
            enabled = !enabled
            updateImage(name: enabled ? selectedImageName : imageName)
        }
        tapAction(enabled)
    }
    
    private func updateImage(name: String) {
        imageView.image = UIImage(
            systemName: name,
            withConfiguration: UIImage.SymbolConfiguration(weight: imageWeight)
        )
    }
    
    //  MARK: - Gestures Actions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(
                withDuration: 0.05,
                delay: 0,
                options: .curveLinear,
                animations: {
                    self.alpha = 0.5
                },
                completion: nil
            )
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(
                withDuration: 0.05,
                delay: 0,
                options: .curveLinear,
                animations: {
                    self.alpha = 1
                },
                completion: nil
            )
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(
                withDuration: 0.05,
                delay: 0,
                options: .curveLinear,
                animations: {
                    self.alpha = 1
                },
                completion: nil
            )
        }
    }
}
