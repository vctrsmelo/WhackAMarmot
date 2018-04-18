//#-hidden-code
import PlaygroundSupport
import UIKit

func setGameDuration(seconds: TimeInterval) {
    Configuration.gameDuration = (seconds < 1) ? 1 : seconds
}

func setMapComplexity(_ complexity: MapComplexity) {
    Configuration.mapComplexity = complexity
}

func setVisibleTime(min: TimeInterval, max: TimeInterval) {
    let minVal = (min < max) ? min : max
    let maxVal = (min < max) ? max : min
    Configuration.minVisibleTime = (minVal < 0) ? 0 : minVal
    Configuration.maxVisibleTime = (maxVal < 0) ? 0 : maxVal
}

func setWaitToSpawnTime(min: TimeInterval, max: TimeInterval) {
    let minVal = (min < max) ? min : max
    let maxVal = (min < max) ? max : min
    Configuration.minWaitToSpawn = (minVal < 0) ? 0 : minVal
    Configuration.maxWaitToSpawn = (maxVal < 0) ? 0 : maxVal
}

func setSpawningTime(min: TimeInterval, max: TimeInterval) {
    let minVal = (min < max) ? min : max
    let maxVal = (min < max) ? max : min
    Configuration.minSpawningTime = (minVal < 0) ? 0 : minVal
    Configuration.maxSpawningTime = (maxVal < 0) ? 0 : maxVal
}

func setHittedHideTime(seconds: TimeInterval) {
    Configuration.hittedHideTime = (seconds < 0) ? 0 : seconds
}
var playingMusic: Bool {
    set {
        Configuration.isMusicOn = newValue
    }
    get {
        return Configuration.isMusicOn
    }
}
//#-end-hidden-code
/*:
**Goal:** Customize the game, play and have fun 😆.
 
 * Important: *After touching start button, load AR on the floor (and take a reasonable distance) for a better experience.*
 
 Hello! I am *Victor*. I have started learning coding during high school, trying to customize an existing game. **Whack a mARmot** was developed to present you coding the same way it was presented to me: through game customization.
 
 This playground allows you to make your own version of this immersive AR game, to challenge yourself or your friends. At the end of this page you can configure the game as you wish, increasing or decreasing the difficulty.
 
 ## Try it out:
 - Touch the two marmots in start screen. They are interactive.
 - After the marmots appear, turn off the lights (or put your finger over camera ☝️). In the dark, only the eyes of the marmots will be visible.


 ## Configurations:
 * **Game Duration**: how much seconds each game will last.
 * **Map Complexity**: the number of marmots displayed. Can be *low*, *medium* or *high*.
 * **Visible Time**: how much seconds the marmots stay visible before hiding again.
 * **Wait to Spawn Time**: how much seconds it takes for a second marmot unhide after a first one does it.
 * **Spawning Time**: how much seconds the unhiding animation takes.
 * **Hitted Hide Time**: how much seconds it takes to a marmot hide when hitted.

 * Important: Negative values are rounded to 0 (except game duration, that is rounded to 1). Maximum values should be greater than minimum. If not, they are switched.
 
 *No marmot was injured during the development of this playground 😊.*
 */
setMapComplexity(.low)
setGameDuration(seconds:30)
playingMusic = true

setVisibleTime(min: 0.5, max: 1.5)
setWaitToSpawnTime(min: 0.5, max: 2)
setSpawningTime(min: 0.4, max: 0.8)
setHittedHideTime(seconds: 0.5)
//#-hidden-code
let vc = ViewController()

PlaygroundPage.current.liveView = vc
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code

