

import UIKit

class ViewController: UIViewController {
    var v2 : UIView!
    var constraintsWith = [NSLayoutConstraint]()
    var constraintsWithout = [NSLayoutConstraint]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("here")
        super.touchesBegan(touches, with:event)
    }
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let v1 = UIView()
        v1.backgroundColor = .red
        v1.translatesAutoresizingMaskIntoConstraints = false
        let v2 = UIView()
        v2.backgroundColor = .yellow
        v2.translatesAutoresizingMaskIntoConstraints = false
        let v3 = UIView()
        v3.backgroundColor = .blue
        v3.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(v1)
        self.view.addSubview(v2)
        self.view.addSubview(v3)
        
        self.v2 = v2 // retain, because we'll remove it from the interface later
        
        // construct constraints

        let c1 = NSLayoutConstraint.constraints(withVisualFormat:"H:|-(20)-[v(100)]", metrics: nil, views: ["v":v1])
        let c2 = NSLayoutConstraint.constraints(withVisualFormat:"H:|-(20)-[v(100)]", metrics: nil, views: ["v":v2])
        let c3 = NSLayoutConstraint.constraints(withVisualFormat:"H:|-(20)-[v(100)]", metrics: nil, views: ["v":v3])
        let c4 = NSLayoutConstraint.constraints(withVisualFormat:"V:|-(100)-[v(20)]", metrics: nil, views: ["v":v1])
        let c5with = NSLayoutConstraint.constraints(withVisualFormat:"V:[v1]-(20)-[v2(20)]-(20)-[v3(20)]", metrics: nil, views: ["v1":v1, "v2":v2, "v3":v3])
        let c5without = NSLayoutConstraint.constraints(withVisualFormat:"V:[v1]-(20)-[v3(20)]", metrics: nil, views: ["v1":v1, "v3":v3])
        
        // first set of constraints

        self.constraintsWith.append(contentsOf:c1)
        self.constraintsWith.append(contentsOf:c2)
        self.constraintsWith.append(contentsOf:c3)
        self.constraintsWith.append(contentsOf:c4)
        self.constraintsWith.append(contentsOf:c5with)
        
        // second set of constraints
        
        self.constraintsWithout.append(contentsOf:c1)
        self.constraintsWithout.append(contentsOf:c3)
        self.constraintsWithout.append(contentsOf:c4)
        self.constraintsWithout.append(contentsOf:c5without)

        // apply first set

        NSLayoutConstraint.activate(self.constraintsWith)
        

        // ignore, just testing new iOS 10 read-only properties
        do {
            let c = self.constraintsWith[0]
            print(c.firstItem as Any)
            print(c.firstAnchor)
        }
        
    }

    @IBAction func doSwap(_ sender: Any) {
        if self.v2.superview != nil {
            self.v2.removeFromSuperview()
            NSLayoutConstraint.deactivate(self.constraintsWith)
            NSLayoutConstraint.activate(self.constraintsWithout)

        } else {
            self.view.addSubview(v2)
            NSLayoutConstraint.deactivate(self.constraintsWithout)
            NSLayoutConstraint.activate(self.constraintsWith)

        }
    }
}

