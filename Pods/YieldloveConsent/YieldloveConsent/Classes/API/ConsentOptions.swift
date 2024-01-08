import ConsentViewController

@objcMembers public class ConsentOptions: NSObject {
    
    public var authId: String?
    public var variant: String?
    public var language: SPMessageLanguage = .BrowserDefault
    
}
