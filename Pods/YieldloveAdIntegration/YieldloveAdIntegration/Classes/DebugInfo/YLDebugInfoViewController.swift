import UIKit

class YLDebugInfoViewController: UIViewController {
    
    private var adUnitData: YLAdUnitData?
    
    init(_ adUnitData: YLAdUnitData) {
        self.adUnitData = adUnitData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDebugInfoLabel()
    }
    
    func addDebugInfoLabel() {
        let debugInfoView = YLDebugInfoView()
        if let debugInfo = adUnitData {
            debugInfoView.attributedText = YLDebugInfoCollector().getDebugInfoText(debugInfo)
        }
        self.view.addSubview(debugInfoView)
        layoutDebugInfoView(debugInfoView)
    }
    
    func layoutDebugInfoView(_ view: UIView) {
        let parentHeight = self.view.frame.height
        let parentWidth = self.view.frame.width
        let rect = CGRect(x: 0, y: parentHeight * 0.3, width: parentWidth, height: parentHeight * 0.5)
        view.frame = rect
    }
    
}
