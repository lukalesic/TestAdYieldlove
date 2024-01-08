import UIKit
import MobileCoreServices

class YLDebugInfoView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(dynamicFontLabel)
        
        NSLayoutConstraint.activate([
            dynamicFontLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
            dynamicFontLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            dynamicFontLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            dynamicFontLabel.bottomAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 20)
        ])
        
        dynamicFontLabel.isUserInteractionEnabled = true
        let tapAction = #selector(copyDebugInfoToClipboard)
        let tap = UITapGestureRecognizer(target: self, action: tapAction)
        tap.numberOfTapsRequired = 2
        dynamicFontLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    var attributedText: NSAttributedString = NSAttributedString() {
        didSet {
            dynamicFontLabel.attributedText = attributedText
            self.setNeedsLayout()
        }
    }
    
    let dynamicFontLabel: UILabel = {
        let label = UILabel()
        label.accessibilityIdentifier = "debugInfo"
        label.textColor = .black
        label.backgroundColor = UIColor.white
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        
        return label
    }()
    
    @objc private func copyDebugInfoToClipboard(sender: UITapGestureRecognizer) {
        UIPasteboard.general.set(attributedString: attributedText)
    }
    
}

public extension UIPasteboard {
    func set(attributedString: NSAttributedString) {
        do {
            let rtf = try attributedString.data(from: NSMakeRange(0, attributedString.length), documentAttributes: [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.rtf])
            items = [[kUTTypeRTF as String: NSString(data: rtf, encoding: String.Encoding.utf8.rawValue)!, kUTTypeUTF8PlainText as String: attributedString.string]]
        } catch {
            if Yieldlove.instance.debug {
                print("Could not copy contents of debug info label")
            }
        }
    }
}
