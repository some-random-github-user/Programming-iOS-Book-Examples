
import UIKit
import WebKit

class WebViewController: UIViewController, UIViewControllerRestoration {
    var activity = UIActivityIndicatorView()
    weak var wv : WKWebView!
    var decoded = false
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.restorationIdentifier = "wvc"
        self.restorationClass = self.dynamicType
        self.edgesForExtendedLayout = [] // none, get accurate offset restoration
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    class func viewController(withRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController? {
        return self.init(nibName:nil, bundle:nil)
    }
    
    // unfortunately I see no evidence that the web view is assisting us at all!
    // the view is not coming back with its URL restored etc, as a UIWebView does

    override func decodeRestorableState(with coder: NSCoder) {
        print("decode")
        self.decoded = true
        super.decodeRestorableState(with:coder)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        print("encode")
        super.encodeRestorableState(with:coder)
    }


    override func applicationFinishedRestoringState() {
        print("finished restoring state", self.wv.url)
    }

    override func loadView() {
        print("loadView")
        super.loadView()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
                
        let wv = WKWebView(frame: CGRect.zero)
        wv.restorationIdentifier = "wv"
        self.view.restorationIdentifier = "wvcontainer" // shouldn't be necessary...
        wv.scrollView.backgroundColor = UIColor.black() // web view alone, ineffective
        self.view.addSubview(wv)
        wv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            NSLayoutConstraint.constraints(withVisualFormat:"H:|[wv]|", metrics: nil, views: ["wv":wv]),
            NSLayoutConstraint.constraints(withVisualFormat:"V:|[wv]|", metrics: nil, views: ["wv":wv])
            ].flatten().map{$0})
        self.wv = wv
                
        // take advantage of built-in "back" and "forward" swipe gestures
        wv.allowsBackForwardNavigationGestures = true
        
        // prepare nice activity indicator to cover loading
        let act = UIActivityIndicatorView(activityIndicatorStyle:.whiteLarge)
        act.backgroundColor = UIColor(white:0.1, alpha:0.5)
        self.activity = act
        wv.addSubview(act)
        act.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            act.centerXAnchor.constraintEqual(to:wv.centerXAnchor),
            act.centerYAnchor.constraintEqual(to:wv.centerYAnchor)
            ])
        // webkit uses KVO
        wv.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        // cool feature, show title
        wv.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        
        wv.navigationDelegate = self
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
            guard let _ = object as? WKWebView else {return}
            guard let keyPath = keyPath else {return}
            guard let change = change else {return}
            switch keyPath {
            case "loading": // new:1 or 0
                if let val = change[NSKeyValueChangeNewKey] as? Bool {
                    if val {
                        self.activity.startAnimating()
                    } else {
                        self.activity.stopAnimating()
                    }
                }
            case "title": // not actually showing it in this example
                if let val = change[NSKeyValueChangeNewKey] as? String {
                    self.navigationItem.title = val
                }
            default:break
            }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("view did appear, req: \(self.wv.url)") // no evidence that restoration is being done for us
        
        let b = UIBarButtonItem(title:"Back", style:.plain, target:self, action:#selector(goBack))
        self.navigationItem.rightBarButtonItems = [b]
        
        if self.decoded {
            // return // forget it, just trying to see if I was in restoration's way, but I'm not
        }
        
        let url = NSURL(string: "http://www.apeth.com/RubyFrontierDocs/default.html")!
        self.wv.load(NSURLRequest(url:url))
    }
    

    deinit {
        print("dealloc")
        // using KVO, always tear down, take no chances
        self.wv.removeObserver(self, forKeyPath: "loading")
        self.wv.removeObserver(self, forKeyPath: "title")
        // with webkit, probably no need for this, but no harm done
        self.wv.stopLoading()
    }
        
    func goBack(_ sender:AnyObject) {
        self.wv.goBack()
    }
    

}

extension WebViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation) {
        print("did commit \(navigation)")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: NSError) {
        print("did fail")
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        print("did fail provisional")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("did finish")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("did start provisional")
    }
}

