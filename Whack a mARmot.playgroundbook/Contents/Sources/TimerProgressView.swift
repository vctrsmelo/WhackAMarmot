import UIKit

public protocol TimerProgressViewDelegate: class {
    func didFinish()
}

public class TimerProgressView: UIProgressView {
    
    public var delegate: TimerProgressViewDelegate?
    var totalTimeInterval: TimeInterval!
    
    private var timer: Timer!
    
    public func start(timeInterval: TimeInterval) {
        totalTimeInterval = timeInterval
        var currentTimeInterval = timeInterval
        
        self.setProgress(1.0, animated: false)

        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
            
            if currentTimeInterval < 0.01 {
                self.delegate?.didFinish()
                self.timer.invalidate()
            }
            
            currentTimeInterval -= 0.01
        
            let progress = currentTimeInterval*100/self.totalTimeInterval
            self.setProgress(Float(progress/100), animated: true)
            
        }
        
        timer.fire()
        
    }

}
