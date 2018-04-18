import UIKit

public protocol EndViewDelegate: class {
    func didTouchPlayAgain()
}

public class EndView: UIView {
    
    public var congratulationsLabel: UILabel!
    public var yourScoreLabel: UILabel!
    public var bestScoreLabel: UILabel!
    public var pointsLabel: UILabel!
    public var marmotFaceImageView: UIImageView!
    public var playAgainButton: UIButton!
    
    public var delegate: EndViewDelegate?
    
    public var topConstraint: NSLayoutConstraint!
    
    var originY: CGFloat!
    
    public func hideAnimated(completion: @escaping () -> Void) {
        self.frame.origin.y = self.originY
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin.y = self.superview!.frame.maxY
        }, completion: ({ _ in
            super.isHidden = true
            completion()
        }))
    }
        
    public func unhideAnimated() {
        originY = superview!.frame.height/2 - 250
        super.isHidden = false
        self.frame.origin.y = self.superview!.frame.maxY
        UIView.animate(withDuration: 0.5, animations: {
            self.frame.origin.y = self.originY
        })
    }

    public func configure() {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        originY = superview!.frame.height/2 - 250
        
        widthAnchor.constraint(equalTo: self.superview!.widthAnchor, multiplier: 0.8).isActive = true
        centerXAnchor.constraint(equalTo: self.superview!.centerXAnchor).isActive = true
        centerYAnchor.constraint(equalTo: self.superview!.centerYAnchor).isActive = true
        topAnchor.constraint(greaterThanOrEqualTo: superview!.topAnchor, constant: 20).isActive = true
        bottomAnchor.constraint(lessThanOrEqualTo: superview!.bottomAnchor, constant: -20).isActive = true
        heightAnchor.constraint(equalToConstant: 500).isActive = true
       
        
        setupUI()
    }
    
    private func setupUI() {
        self.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9294117647, alpha: 1)

        setupCongratulationsLabel()
        setupBestScoreLabel()
        setupYourScoreLabel()
        setupMarmotFaceImageView()
        setupPointsLabel()
        setupPlayAgainButton()
        
        self.layer.cornerRadius = 70
        self.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        self.layer.borderWidth = 10
    }
    
    private func setupCongratulationsLabel() {
        congratulationsLabel = UILabel()
        addSubview(congratulationsLabel)
        
        let congratulationsAttributes = [
            NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.5926792513, green: 0.480837506, blue: 0.00397248327, alpha: 1),
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.9459542632, green: 0.7699680924, blue: 0, alpha: 1),
            NSAttributedStringKey.strokeWidth : -4.0,
            NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 30)!
            ] as [NSAttributedStringKey : Any]
        
        congratulationsLabel.attributedText = NSAttributedString(string: "Congratulations!",
                                                           attributes: congratulationsAttributes)
        
        congratulationsLabel.textAlignment = .center
        
        congratulationsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        congratulationsLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        congratulationsLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
        congratulationsLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        
    }
    
    public func setScore(score: Int) {
        let attributes = [
            NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.3568627451, green: 0.4549019608, blue: 0.1647058824, alpha: 1),
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.8980392157, green: 0.9176470588, blue: 0.7490196078, alpha: 1),
            NSAttributedStringKey.strokeWidth : -4.0,
            NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 80)!
            ] as [NSAttributedStringKey : Any]
        
        self.pointsLabel.attributedText = NSAttributedString(string: "x\(score)",
            attributes: attributes)
        
        if GameManager.shared.bestScorePoints <= score {
            setBestScore(score: score, isNewBestScore: true)
        } else {
            setBestScore(score: GameManager.shared.bestScorePoints, isNewBestScore: false)
        }
    }
    
    private func setBestScore(score: Int, isNewBestScore: Bool) {
        let attributes = [
            NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.3568627451, green: 0.4549019608, blue: 0.1647058824, alpha: 1),
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.4862745098, green: 0.631372549, blue: 0.4588235294, alpha: 1),
            NSAttributedStringKey.strokeWidth : -4.0,
            NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 30)!
            ] as [NSAttributedStringKey : Any]
        
        if isNewBestScore {
            congratulationsLabel.isHidden = false
            bestScoreLabel.attributedText = NSAttributedString(string: "New Best Score: \(score)",
                attributes: attributes)
        } else {
            congratulationsLabel.isHidden = true
            bestScoreLabel.attributedText = NSAttributedString(string: "Best Score: \(score)",
                attributes: attributes)
        }
    }
    
    private func setupBestScoreLabel() {
        bestScoreLabel = UILabel()
        addSubview(bestScoreLabel)

        bestScoreLabel.adjustsFontSizeToFitWidth = true
        bestScoreLabel.textAlignment = .center
        
        bestScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bestScoreLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bestScoreLabel.topAnchor.constraint(equalTo: self.congratulationsLabel.bottomAnchor, constant: 15).isActive = true
        bestScoreLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    private func setupYourScoreLabel() {
        yourScoreLabel = UILabel()
        addSubview(yourScoreLabel)
        
        let attributes = [
            NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.3568627451, green: 0.4549019608, blue: 0.1647058824, alpha: 1),
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.4862745098, green: 0.631372549, blue: 0.4588235294, alpha: 1),
            NSAttributedStringKey.strokeWidth : -4.0,
            NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 40)!
            ] as [NSAttributedStringKey : Any]

        yourScoreLabel.attributedText = NSAttributedString(string: "Your Score is",
            attributes: attributes)
        
        yourScoreLabel.textAlignment = .center
        
        yourScoreLabel.translatesAutoresizingMaskIntoConstraints = false
        
        yourScoreLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        yourScoreLabel.topAnchor.constraint(equalTo: self.bestScoreLabel.bottomAnchor, constant: 15).isActive = true
        
        yourScoreLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
    
    private func setupMarmotFaceImageView() {
        marmotFaceImageView = UIImageView()
        addSubview(marmotFaceImageView)
        
        marmotFaceImageView.image = UIImage(named: "marmotFace")
        
        marmotFaceImageView.translatesAutoresizingMaskIntoConstraints = false
        
        marmotFaceImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        marmotFaceImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        marmotFaceImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 10).isActive = true
        marmotFaceImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -75).isActive = true
    }
    
    private func setupPointsLabel() {
        pointsLabel = UILabel()
        addSubview(pointsLabel)
        
        let attributes = [
            NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.3568627451, green: 0.4549019608, blue: 0.1647058824, alpha: 1),
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.8980392157, green: 0.9176470588, blue: 0.7490196078, alpha: 1),
            NSAttributedStringKey.strokeWidth : -4.0,
            NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 80)!
            ] as [NSAttributedStringKey : Any]
        
        pointsLabel.attributedText = NSAttributedString(string: "x10",
                                                           attributes: attributes)
        
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pointsLabel.centerYAnchor.constraint(equalTo: marmotFaceImageView.centerYAnchor, constant: 10).isActive = true
        pointsLabel.leftAnchor.constraint(equalTo: marmotFaceImageView.rightAnchor, constant: 10).isActive = true
        pointsLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    private func setupPlayAgainButton() {
        playAgainButton = UIButton()
        addSubview(playAgainButton)
        
        playAgainButton.translatesAutoresizingMaskIntoConstraints = false
        
        playAgainButton.setImage(UIImage(named: "playAgainButton"), for: .normal)
        playAgainButton.setImage(UIImage(named: "playAgainButtonPressed"), for: .highlighted)
        playAgainButton.imageView!.contentMode = .scaleAspectFit
        
        playAgainButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        playAgainButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playAgainButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -40).isActive = true
        
        playAgainButton.addTarget(self, action: #selector(self.playAgainButtonTouched), for: .touchUpInside)
    }
    
    @objc private func playAgainButtonTouched() {
        delegate?.didTouchPlayAgain()
    }
    
}

