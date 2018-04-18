import UIKit
import SceneKit
import ARKit
import AVFoundation

public class ViewController: UIViewController {
    
    var sceneView: ARSCNView!
    var sceneLight: SCNLight!
    
    let gameManager = GameManager.shared
    
    //HUD
    var startView: StartView!
    var timerProgressView: TimerProgressView!
    var pointsLabel: UILabel!
    var endView: EndView!
    var countdownLabel: CountdownLabel!
    
    var messageTextView: UITextView!
    var activityIndicator: UIActivityIndicatorView!
    
    private var lastTime: TimeInterval!
    
    var pointsObservation: NSKeyValueObservation!
    
    var touchPlayer: AVAudioPlayer?
    var musicPlayer: AVAudioPlayer?
    
    override public func loadView() {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        self.view = view
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        gameManager.delegate = self
        
        sceneView = ARSCNView()
        self.view.addSubview(sceneView)
        
        self.sceneView.translatesAutoresizingMaskIntoConstraints = false
        self.sceneView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        self.sceneView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        sceneView.delegate = self
        
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        let scene = SCNScene()
        
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = false
        sceneLight = SCNLight()
        sceneLight.type = .omni
        
        let lightNode = SCNNode()
        lightNode.light = sceneLight
        lightNode.position = SCNVector3(x: 0, y: 5, z: 3)
        
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        loadHUD()
        loadAudios()
        
        setupObservations()
        
        gameManager.start()
    }
    
    private func setupObservations() {
        pointsObservation = gameManager.observe(\.points, options: [.initial,.new]) { (gameManager, change) in
            
            let attributes = [
                NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.3568627451, green: 0.4549019608, blue: 0.1647058824, alpha: 1),
                NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.8980392157, green: 0.9176470588, blue: 0.7490196078, alpha: 1),
                NSAttributedStringKey.strokeWidth : -4.0,
                NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 60)!
                ] as [NSAttributedStringKey : Any]
            
            let customizedPoints = NSMutableAttributedString(string: "x\(gameManager.points)",
                attributes: attributes)
            
            self.pointsLabel.attributedText = customizedPoints
            self.pointsLabel.setNeedsLayout()
            
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.pointsLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                
            }, completion: { _ in
                UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                    
                    self.pointsLabel.transform = CGAffineTransform(scaleX: 1/1.2, y: 1/1.2)
                    
                })
            })
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        
        sceneView.session.run(configuration)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Methods
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if gameManager.state == .loadedAR {
            gameManager.willPlay()
            
            countdownLabel.startCounting {
                self.gameManager.play()
            }
            
            return
        }
        
        let touchLocation = touch.location(in: sceneView)
        let results = sceneView.hitTest(touchLocation, options: nil)

        guard let hitResult = results.first(where: {$0.node.name == "Marmot"}) else { return }
        
        let touchedMarmot = gameManager.marmots.first {$0.marmotNode == hitResult.node}
        touchedMarmot?.hit()
    }
    
    // MARK: - Load Audios
    
    private func loadAudios() {
        
        loadTouchPlayer()
        
        if Configuration.isMusicOn {
            loadMusicPlayer()
            musicPlayer?.play()
        }
    }
    
    private func loadTouchPlayer() {
        guard let url = Bundle.main.url(forResource: "Hit", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            touchPlayer = player
            
        } catch {
            
        }
    }
    
    private func loadMusicPlayer() {
        guard let url = Bundle.main.url(forResource: "Theme", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            let player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player.numberOfLoops = -1
            player.volume = 0.6
            musicPlayer = player
            
        } catch {
            
        }
    }
    
    // MARK: - Load HUD
    
    private func loadHUD() {
        loadStartView()
        loadCountdownLabel()
        loadTimerProgressView()
        loadPointsLabel()
        loadLoadingView()
        loadEndView()
        
    }
    
    private func loadStartView() {
        startView = StartView()
        startView.delegate = self
        
        view.addSubview(startView)
        
        startView.configure()
    }
    
    @objc private func playButtonTouched() {
        gameManager.play()
    }
    
    private func loadTimerProgressView() {
        timerProgressView = TimerProgressView()
        timerProgressView.delegate = self
        
        view.addSubview(timerProgressView)
        
        timerProgressView.translatesAutoresizingMaskIntoConstraints = false
        
        timerProgressView.progressTintColor = #colorLiteral(red: 0.8705882353, green: 0.8941176471, blue: 0.6941176471, alpha: 1)
        timerProgressView.backgroundColor = #colorLiteral(red: 0.6392156863, green: 0.568627451, blue: 0.462745098, alpha: 1)
        timerProgressView.layer.cornerRadius = 10
        timerProgressView.layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        timerProgressView.layer.borderWidth = 5
        timerProgressView.clipsToBounds = true
        
        
        timerProgressView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        timerProgressView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        timerProgressView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        timerProgressView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
        
    }
    
    private func loadPointsLabel() {
        pointsLabel = UILabel()
        view.addSubview(pointsLabel)
        
        pointsLabel.translatesAutoresizingMaskIntoConstraints = false
        
        pointsLabel.topAnchor.constraint(equalTo: timerProgressView.bottomAnchor, constant: 10).isActive = true
        pointsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pointsLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        pointsLabel.heightAnchor.constraint(equalToConstant: 150).isActive = true
        pointsLabel.textColor = UIColor.white
        pointsLabel.font = UIFont.init(name: Configuration.fontName, size: 40)
        pointsLabel.textAlignment = .center
        
    }
    
    private func loadCountdownLabel() {
        countdownLabel = CountdownLabel()
        view.addSubview(countdownLabel)
        
        countdownLabel.translatesAutoresizingMaskIntoConstraints = false
        
        countdownLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        countdownLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        countdownLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        countdownLabel.textAlignment = .center
        
    }
    
    private func loadEndView() {
        endView = EndView()
        endView.delegate = self
        view.addSubview(endView)
        endView.configure()
    }
    
    private func loadLoadingView() {
        loadMessageTextView()
        loadActivityIndicator()
    }
    
    
    private func loadMessageTextView() {
        messageTextView = UITextView()
        view.addSubview(messageTextView)
        
        messageTextView.text = "Scan a well lit floor area. \nThe more yellow dots appearing, the better :)"
        messageTextView.font = UIFont(name: Configuration.fontName, size: 20)
        messageTextView.textColor = UIColor.white
        messageTextView.backgroundColor = UIColor.clear
        messageTextView.textAlignment = .center
        messageTextView.isEditable = false
        messageTextView.isSelectable = false
        
        messageTextView.translatesAutoresizingMaskIntoConstraints = false
        
        messageTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        messageTextView.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        messageTextView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        messageTextView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
    }
    
    private func loadActivityIndicator() {
        activityIndicator = UIActivityIndicatorView()
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10).isActive = true
    }
    
    private func updateHUD(for state: GameState) {
        
        switch state {
        case .startView:
            self.startView.isHidden = false
            self.messageTextView.isHidden = true
            self.countdownLabel.isHidden = true
            self.activityIndicator.isHidden = true
            self.pointsLabel.isHidden = true
            self.timerProgressView.isHidden = true
            self.endView.isHidden = true
            
        case .loadingAR:
            self.startView.isHidden = true
            self.messageTextView.isHidden = false
            self.countdownLabel.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            self.pointsLabel.isHidden = true
            self.timerProgressView.isHidden = true
            self.endView.isHidden = true
            
        case .loadedAR:
            self.startView.isHidden = true
            self.messageTextView.isHidden = false
            self.messageTextView.text = "Touch the screen to start"
            self.activityIndicator.isHidden = true
            self.pointsLabel.isHidden = true
            self.timerProgressView.isHidden = true
            self.endView.isHidden = true
            
        case .willPlay:
            self.startView.isHidden = true
            self.messageTextView.isHidden = true
            self.countdownLabel.isHidden = false
            self.activityIndicator.isHidden = true
            self.pointsLabel.isHidden = true
            self.timerProgressView.isHidden = true
            
        case .playing:
            self.startView.isHidden = true
            self.messageTextView.isHidden = true
            self.countdownLabel.isHidden = true
            self.activityIndicator.isHidden = true
            self.pointsLabel.isHidden = false
            self.timerProgressView.isHidden = false
            self.timerProgressView.start(timeInterval: Configuration.gameDuration)
            
        case .finished:
            self.startView.isHidden = true
            self.messageTextView.isHidden = true
            self.countdownLabel.isHidden = true
            self.activityIndicator.isHidden = true
            self.pointsLabel.isHidden = true
            self.timerProgressView.isHidden = true
            
            self.endView.setScore(score: self.gameManager.points)
        }
    }
}

extension ViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let estimate = self.sceneView.session.currentFrame?.lightEstimate {
            sceneLight.intensity = estimate.ambientIntensity
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if self.gameManager.state != .loadingAR || self.gameManager.isScenarioAdded {
            return
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.gameManager.setupScene(for: planeAnchor)
            
            node.addChildNode(self.gameManager.scenarioNode)
            
            if let yawn = self.sceneView.session.currentFrame?.camera.eulerAngles.y {
                self.gameManager.rotateMarmots(to: yawn)
            }
            
            self.gameManager.showMarmots { }
            self.gameManager.loaded()
            self.sceneView.debugOptions = []
        }
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        DispatchQueue.main.async {
            guard let lastTime = self.lastTime else {
                self.lastTime = time
                return
            }
            
            let minWait = Configuration.minWaitToSpawn
            let upperWait = Configuration.maxWaitToSpawn - minWait
            
            let waitToSpawnTime = (Double(arc4random_uniform(UInt32(upperWait*100)))/100.0)+minWait
            
            if self.gameManager.state != .playing || (time - lastTime) < waitToSpawnTime {
                return
            }
            
            self.gameManager.unhideMarmot()
            self.lastTime = time
        }
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        messageTextView.isHidden = false
        messageTextView.text = "An error ocurred with AR. Please restart the playground :("
    }
}

extension ViewController: TimerProgressViewDelegate {
    public func didFinish() {
        gameManager.finish()
        endView.unhideAnimated()
    }
}

extension ViewController: GameManagerDelegate {
    public func didUpdateState(_ newState: GameState) {
        updateHUD(for: newState)
    }
    
    public func marmotWasHitted() {
        touchPlayer?.play()
    }
}

extension ViewController: StartViewDelegate {
    public func didTouchStart() {
        gameManager.loading()
    }
    
    public func didTouchMarmot() {
        touchPlayer?.play()
    }
}
extension ViewController: EndViewDelegate {
    public func didTouchPlayAgain() {
        endView.hideAnimated { [weak self] in
            self?.gameManager.play()
        }
    }
}
