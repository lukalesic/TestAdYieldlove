import CoreGraphics

public class YLCGSizeConverter {
    public static func getCGSize(for wxh: String?) -> CGSize {
        if let dimensions = wxh {
            let sizes = dimensions.split(separator: "x")
            if let width = Int(sizes[0]), let height = Int(sizes[1]) {
                return CGSize(width: width, height: height)
            }
        }
        return CGSize.zero
    }
}
