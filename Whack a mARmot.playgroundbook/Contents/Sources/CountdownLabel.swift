import UIKit

public class CountdownLabel: UILabel {
    
    private var timer: Timer!
    
    public func startCounting(from initialValue: Int = 3, completion: @escaping () -> Void) {
        let attributes = [
            NSAttributedStringKey.strokeColor : #colorLiteral(red: 0.3568627451, green: 0.4549019608, blue: 0.1647058824, alpha: 1),
            NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.571272477, green: 0.7357355585, blue: 0.2684963127, alpha: 1),
            NSAttributedStringKey.strokeWidth : -5.0,
            NSAttributedStringKey.font:  UIFont(name: Configuration.fontName, size: 80)!
            ] as [NSAttributedStringKey : Any]
        
        var value = initialValue
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if value == -1 {
                timer.invalidate()
                completion()
            }
            
            if value != 0 {
                self.attributedText = NSAttributedString(string: "\(value)",
                    attributes: attributes)
            } else {
                self.attributedText = NSAttributedString(string: "Go!",
                    attributes: attributes)
            }
            
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            value -= 1
    
            UIView.animate(withDuration: 1, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            })
        })
    }
}
