import SceneKit
import ARKit

public enum MapComplexity {
    case low
    case medium
    case high
}

public enum GameState {
    case startView
    case loadingAR
    case loadedAR
    case willPlay
    case playing
    case finished
}

public protocol GameManagerDelegate: class {
    func didUpdateState(_ state: GameState)
    func marmotWasHitted()
}

public class GameManager: NSObject {
    
    static public var shared = GameManager()
    
    public var delegate: GameManagerDelegate?
    
    private(set) public var state: GameState!
    
    @objc dynamic public var points: Int = 0
    public var bestScorePoints: Int = 0
    
    public var sceneLight: SCNLight!
    
    public var scenarioNode: SCNNode!
    public var marmotContainers = [SCNNode]()
    public var marmots = [Marmot]()
    
    public var isScenarioAdded: Bool = false {
        didSet {
            if isScenarioAdded {
                state = .loadedAR
            }
        }
    }
    
    private var showMarmotsAction: SCNAction!
    
    private override init() {
        self.state = .startView
    }
    
    public func setupScene(for plane: ARPlaneAnchor) {
        switch Configuration.mapComplexity {
        case .low:
            setup(for: plane, with: SCNScene(named: "scenarioEasy.scn")!)
        case .medium:
            setup(for: plane, with: SCNScene(named: "scenarioMedium.scn")!)
            break
        case .high:
            setup(for: plane, with: SCNScene(named: "scenarioHard.scn")!)
            break
        }

    }
    
    private func setup(for planeAnchor: ARPlaneAnchor, with scene: SCNScene) {
        
        
        guard let scenario = scene.rootNode.childNode(withName: "SceneContainer", recursively: true) else {
            fatalError("Couldn't load scenario scene")
        }
        
        guard let floor = scenario.childNode(withName: "Floor", recursively: true) else {
            fatalError("Couldn't load floor")
        }
        
        // makes floor "invisible"
        floor.renderingOrder = -1
        floor.geometry!.materials.forEach { $0.colorBufferWriteMask = [] }
        
        scenarioNode = scenario
        
        guard let containers = scenario.childNode(withName: "Marmots", recursively: true) else {
            fatalError("Couldn't load marmot containers")
        }

        marmotContainers.append(contentsOf: containers.childNodes)
        loadMarmots()
        
        scenario.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
        containers.position =  SCNVector3(planeAnchor.center.x, -0.07, planeAnchor.center.z)
        showMarmotsAction = SCNAction.move(by: SCNVector3(0, 0.06, 0), duration: 3)
    }
    
    public func showMarmots(completion: @escaping () -> Void) {
        guard let containers = scenarioNode.childNode(withName: "Marmots", recursively: true) else {
            fatalError("Couldn't load marmot containers")
        }
        
        containers.runAction(showMarmotsAction) {
            completion()
        }
    }
    
    private func loadMarmots() {
        
        marmotContainers.forEach { container in
            
            let centerY = container.worldPosition.y
            
            let newMarmot = Marmot()
            
            let visibleY = centerY + Float((newMarmot.marmotNode.geometry as! SCNCapsule).height)/5.0
            let hiddenY = centerY - Float((newMarmot.marmotNode.geometry as! SCNCapsule).height)/3.0
            
            newMarmot.marmotNode.pivot = container.pivot
            newMarmot.visiblePosition = SCNVector3.init(newMarmot.marmotNode.position.x, visibleY, newMarmot.marmotNode.position.z)
            newMarmot.hiddenPosition = SCNVector3.init(newMarmot.marmotNode.position.x, hiddenY, newMarmot.marmotNode.position.z)
            newMarmot.marmotNode.position.y = hiddenY
            
            newMarmot.delegate = self
            
            container.addChildNode(newMarmot.marmotNode)
            marmots.append(newMarmot)
            
        }
    }
    
    public func rotateMarmots(to angle: Float) {
        let newRotation = SCNVector3Make(0, angle, 0)
        self.marmots.forEach {
            $0.marmotNode.eulerAngles = newRotation
        }
    }
    
    @objc public func unhideMarmot() {
        
        if state != .playing { return }
        
        var randomIndex: Int = Int(arc4random_uniform(UInt32(marmotContainers.count)))
        var marmot = marmots[randomIndex]
        
        var i = 0
        while i < marmotContainers.count {
            if marmot.isHidden { break }
            
            randomIndex = (randomIndex + 1) % marmotContainers.count
            marmot = marmots[randomIndex]
            i += 1
        }
        
        if i < marmotContainers.count {
            marmot.unhide()
        }
    }
    
    // MARK: - States Methods
    
    public func start() {
        self.state = .startView
        delegate?.didUpdateState(state)
    }
    
    public func loading() {
        self.state = .loadingAR
        delegate?.didUpdateState(state)
        
    }
    
    public func play() {
        self.points = 0
        self.state = .playing
        delegate?.didUpdateState(state)
    }
    
    public func willPlay() {
        self.state = .willPlay
        delegate?.didUpdateState(state)
    }
    
    public func loaded() {
        self.state = .loadedAR
        isScenarioAdded = true
        delegate?.didUpdateState(state)
    }
    
    public func finish() {
        self.state = .finished
        if points > bestScorePoints {
            bestScorePoints = points
        }
        delegate?.didUpdateState(state)
    }
    
}

extension GameManager: MarmotDelegate {
    public func wasHitted() {
        self.points += 1
        delegate?.marmotWasHitted()
    }
}
