import UIKit

extension ErrorViews {
    class RootView: UIView {
        // MARK: - Views
        private lazy var headerLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 30, weight: .medium)
            label.numberOfLines = 0
            return label
        }()
        private lazy var descriptionLabel: UILabel = {
            let label = UILabel()
            label.textColor = .white
            label.font = .systemFont(ofSize: 24, weight: .light)
            label.numberOfLines = 0
            return label
        }()
        private lazy var errorImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.tintColor = .white
            imageView.contentMode = .scaleAspectFit
            return imageView
        }()
        
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
            setupHeaderLabel()
            setupDescriptionLabel()
            setupErrorImageView()
        }
        
        private func setupHeaderLabel() {
            addSubview(headerLabel)
            headerLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 50),
                headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
            ])
        }
        
        private func setupDescriptionLabel() {
            addSubview(descriptionLabel)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 40),
                descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
            ])
        }
        
        private func setupErrorImageView() {
            addSubview(errorImageView)
            errorImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                errorImageView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -100),
                errorImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
                errorImageView.widthAnchor.constraint(equalToConstant: 170),
                errorImageView.heightAnchor.constraint(equalToConstant: 150)
            ])
        }

        // MARK: - Populate
        func updateView(title: String, description: String, image: UIImage?) {
            headerLabel.text = title
            descriptionLabel.text = description
            errorImageView.image = image
        }
    }
}
