import UIKit

public struct Configuration {
    
    static public var mapComplexity: MapComplexity = MapComplexity.low
    
    static public var minVisibleTime: TimeInterval = 0.5
    static public var maxVisibleTime: TimeInterval = 1.5
    
    static public var minWaitToSpawn: TimeInterval = 0.5
    static public var maxWaitToSpawn: TimeInterval = 2
    
    static public var minSpawningTime: TimeInterval = 0.4
    static public var maxSpawningTime: TimeInterval = 0.8
    
    static public var hittedHideTime: TimeInterval = 0.5
    
    static public var gameDuration: TimeInterval = 10
    
    static public var isMusicOn: Bool = true
    
    static public var fontName = "Chalkboard SE"
}
