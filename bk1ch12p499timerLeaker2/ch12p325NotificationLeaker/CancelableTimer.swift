
import UIKit

class CancelableTimer: NSObject {
    private var q = DispatchQueue(label: "timer")
    private var timer : DispatchSourceTimer!
    private var firsttime = true
    private var once : Bool
    private var handler : () -> ()
    init(once:Bool, handler:()->()) {
        self.once = once
        self.handler = handler
        super.init()
    }
    func start(withInterval interval:Double) {
        self.firsttime = true
        self.cancel()
        self.timer = DispatchSource.timer(queue: self.q)
        self.timer.scheduleRepeating(wallDeadline: DispatchWallTime.now(), interval: interval)
        self.timer.setEventHandler {
            if self.firsttime {
                self.firsttime = false
                return
            }
            self.handler()
            if self.once {
                self.cancel()
            }
        }
        self.timer.resume()
    }
    func cancel() {
        if self.timer != nil {
            timer.cancel()
        }
    }
    deinit {
        print("deinit cancelable timer")
    }
}
