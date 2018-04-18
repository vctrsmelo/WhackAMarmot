import SceneKit

public protocol MarmotDelegate {
    func wasHitted()
}

public class Marmot {
    
    public var marmotNode: SCNNode!
    private var starsNode: SCNNode!
    
    public var isHidden: Bool
    public var isHidding: Bool
    
    public var hiddenPosition: SCNVector3!
    public var visiblePosition: SCNVector3!
    
    private let hittedTexture = UIImage(named: "marmotHittedTexture.png")!
    private let hittedDarkTexture = UIImage(named: "marmotHittedDarkTexture.png")!
    
    private let okTexture = UIImage(named: "marmotTexture.png")!
    private let okDarkTexture = UIImage(named: "marmotDarkTexture.png")!
    
    private var textureMaterial = SCNMaterial()
    
    public var delegate: MarmotDelegate?
    
    public init() {
        
        let marmotScene = SCNScene(named: "art.scnassets/marmot.scn")!
        
        guard let marmot = marmotScene.rootNode.childNode(withName: "Marmot", recursively: true), let stars = marmot.childNode(withName: "Stars", recursively: true) else {
            fatalError("Couldn't load marmot scene")
        }

        
        marmotNode = marmot
        starsNode = stars
        
        let action = SCNAction.rotate(by: 360 * CGFloat(Double.pi/180), around: SCNVector3(x: 0, y: 1, z: 0), duration: 2)
        
        let repeatAction = SCNAction.repeatForever(action)
        
        starsNode.runAction(repeatAction)
        
        isHidden = true
        isHidding = false
        self.starsNode.isHidden = true
        
        marmotNode.geometry?.firstMaterial = SCNMaterial()
        marmotNode.geometry?.firstMaterial?.diffuse.contents = okTexture
        marmotNode.geometry?.firstMaterial?.emission.contents = okDarkTexture
        marmotNode.geometry?.firstMaterial?.shininess = 50

    }
    
    public func hide(_ definedHideTime: TimeInterval? = nil, delay: TimeInterval? = 0, completion: (() -> Void)? = nil) {
        
        let hideTime: TimeInterval
        
        if definedHideTime != nil {
            hideTime = definedHideTime!
        } else {
            let minSpawningTime = Configuration.minSpawningTime
            let upperSpawningTime = Configuration.maxSpawningTime - minSpawningTime
            
            hideTime = (Double(arc4random_uniform(UInt32(upperSpawningTime*100)))/100.0)+minSpawningTime
        }
//
//        let hideAction = SCNAction.group([
//                                SCNAction.wait(duration: delay ?? 0),
//                                SCNAction.move(to: hiddenPosition, duration: hideTime)
//            ])
//
        self.marmotNode.runAction(SCNAction.wait(duration: delay ?? 0)) {
            self.marmotNode.runAction(SCNAction.move(to: self.hiddenPosition, duration: hideTime)) {
                self.isHidden = true
                self.isHidding = false
                self.starsNode.isHidden = true
                completion?()
            }
        }
    }
    
    public func hit() {
        
        if isHidden || isHidding { return }
        
        
        self.starsNode.isHidden = false
        isHidding = true
        
        delegate?.wasHitted()
        
        marmotNode.removeAllActions()
        
        marmotNode.geometry?.firstMaterial?.diffuse.contents = hittedTexture
        marmotNode.geometry?.firstMaterial?.emission.contents = hittedDarkTexture
        self.hide(Configuration.hittedHideTime, delay: 0.3) {
            self.marmotNode.geometry?.firstMaterial?.diffuse.contents = self.okTexture
            self.marmotNode.geometry?.firstMaterial?.emission.contents = self.okDarkTexture
        }
    }
    
    public func unhide(completion: (() -> Void)? = nil) {
        isHidden = false
        
        let minSpawningTime = Configuration.minSpawningTime
        let upperSpawningTime = Configuration.maxSpawningTime - minSpawningTime
        
        let spawningTime = (Double(arc4random_uniform(UInt32(upperSpawningTime*100)))/100.0)+minSpawningTime

        self.marmotNode.runAction(SCNAction.move(to: visiblePosition, duration: spawningTime)) {
            
            let minVisibleTime = Configuration.minVisibleTime
            let upperVisibleTime = Configuration.maxVisibleTime - minVisibleTime
            
            let visibleTime = (Double(arc4random_uniform(UInt32(upperVisibleTime*100)))/100.0)+minVisibleTime
            
            self.marmotNode.runAction(SCNAction.wait(duration: visibleTime), completionHandler: {
                self.hide(spawningTime)
                completion?()
            })
        }
    }
    
}

