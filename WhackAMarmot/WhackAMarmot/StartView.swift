import UIKit

public protocol StartViewDelegate: class {
    func didTouchStart()
    func didTouchMarmot()
}

public class StartView: UIView {
    
    var logoImageView: UIImageView!
    var startButton: UIButton!
    var marmotsImageViews = [UIImageView]()
    
    public var delegate: StartViewDelegate?
    
    var topConstraint: NSLayoutConstraint!
    
    override public var isHidden: Bool {
        didSet {
            marmotsImageViews.forEach{ $0.isHidden = isHidden }
        }
    }
    
    public func configure() {        
        self.frame = superview!.frame
        translatesAutoresizingMaskIntoConstraints = false

        topConstraint = topAnchor.constraint(equalTo: self.superview!.topAnchor)
        topConstraint.isActive = true
        leftAnchor.constraint(equalTo: self.superview!.leftAnchor).isActive = true
        rightAnchor.constraint(equalTo: self.superview!.rightAnchor).isActive = true
        bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor).isActive = true
        setupUI()
    }
    
    private func setupUI() {
        
        self.backgroundColor = #colorLiteral(red: 0.937254902, green: 0.9450980392, blue: 0.9294117647, alpha: 1)
        
        setupLogoImageView()
        setupStartButton()
        setupMarmotsImages()
    }
    
    private func setupLogoImageView() {
        logoImageView = UIImageView()
        addSubview(logoImageView)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        logoImageView.image = UIImage(named: "Logo")
        logoImageView.contentMode = .scaleAspectFit
        
        logoImageView.topAnchor.constraint(equalTo: topAnchor, constant: 30).isActive = true
        logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        logoImageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, multiplier: 0.8).isActive = true
        logoImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
    }
    
    private func setupStartButton() {
        startButton = UIButton()
        addSubview(startButton)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        startButton.setImage(UIImage(named: "StartButton"), for: .normal)
        startButton.setImage(UIImage(named: "StartButtonPressed"), for: .highlighted)
        
        startButton.imageView!.contentMode = .scaleAspectFit
        
        startButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -100).isActive = true
        startButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        startButton.heightAnchor.constraint(equalToConstant: 90).isActive = true
        startButton.widthAnchor.constraint(equalToConstant: 252).isActive = true
        
        startButton.addTarget(self, action: #selector(self.startButtonTouched), for: .touchUpInside)
    }
    
    private func setupMarmotsImages() {
        marmotsImageViews.append(contentsOf: [
            UIImageView(image: UIImage(named: "marmot2d")),
            UIImageView(image: UIImage(named: "marmot2d"))
            ])
    
        marmotsImageViews.forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = UIColor.clear
            superview!.addSubview($0)
            $0.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 20).isActive = true
            $0.heightAnchor.constraint(equalToConstant: 140.0).isActive = true
            $0.widthAnchor.constraint(equalToConstant: 70.0).isActive = true
        }
        
        marmotsImageViews[0].leftAnchor.constraint(equalTo: leftAnchor, constant: 50).isActive = true
        marmotsImageViews[1].rightAnchor.constraint(equalTo: rightAnchor, constant: -50).isActive = true
        
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.marmotsImageViews[0].frame.origin.y += 20
        })
        
        UIView.animate(withDuration: 2.0, delay: 1, options: [.repeat, .autoreverse], animations: {
            self.marmotsImageViews[1].frame.origin.y += 20
        })
        
    }

    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if let firstTouch = touches.first {
            
            let marmot1Frame = self.convert(marmotsImageViews[0].frame, from: marmotsImageViews[0].superview)
            
            if marmot1Frame.contains(firstTouch.location(in: self)) {
                hit(marmotsImageViews[0])
            }
            
            let marmot2Frame = self.convert(marmotsImageViews[1].frame, from: marmotsImageViews[1].superview)
            
            if marmot2Frame.contains(firstTouch.location(in: self)) {
                hit(marmotsImageViews[1])
            }
        }
    }
    
    private func hit(_ marmotView: UIImageView) {
        let marmotHeight: CGFloat = marmotView.frame.height

        marmotView.image = UIImage(named: "marmotHitted2d")
        delegate?.didTouchMarmot()
        
        UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
            marmotView.frame.origin.y = self.frame.maxY
        }, completion: { _ in
            
            marmotView.image = UIImage(named: "marmot2d")
            UIView.animate(withDuration: 2.0, delay: 3, animations: {
                
                marmotView.frame.origin.y = self.frame.maxY-marmotHeight
                
            }, completion: { _ in
                UIView.animate(withDuration: 2.0, delay: 1, options: [.repeat, .autoreverse], animations: {
                    marmotView.frame.origin.y += 20
                })
            })
            
        })
    }
    
    @objc private func startButtonTouched() {
        
        let newMarmotY = self.frame.maxY
        
        var newFrame = self.frame
        newFrame.origin.y = self.frame.minY-self.frame.height

        self.marmotsImageViews[0].stopAnimating()
        self.marmotsImageViews[1].stopAnimating()
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseInOut, animations: {
            self.frame = newFrame
            self.marmotsImageViews[0].frame.origin.y = newMarmotY
            self.marmotsImageViews[1].frame.origin.y = newMarmotY
        }, completion: ({ _ in
            self.delegate?.didTouchStart()
        }))
    }
    
}
