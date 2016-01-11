//
//  Utilities.swift
//  SpeakApp
//
//  Created by Aviel Gross on 10/22/14.
//  Copyright (c) 2014 Aviel Gross. All rights reserved.
//

import UIKit

// MARK: Operators/Typealiases

/**
*  Set lhs to be rhs only if lhs is nil
*  Example: imageView.image ?= placeholderImage
*           Will set placeholderImage only if imageView.image is nil
*/
infix operator ?= {}
func ?=<T>(inout lhs: T!, rhs: T) {
    if lhs == nil {
        lhs = rhs
    }
}
func ?=<T>(inout lhs: T?, rhs: T) {
    if lhs == nil {
        lhs = rhs
    }
}
func ?=<T>(inout lhs: T?, rhs: T?) {
    if lhs == nil {
        lhs = rhs
    }
}

typealias Seconds = NSTimeInterval

//MARK: Tick/Tock
private var tickD = NSDate()
func TICK() {
    tickD = NSDate()
}
func TOCK(sender: Any = __FUNCTION__) {
    print("⏰ TICK/TOCK for: \(sender) :: \(-tickD.timeIntervalSinceNow) ⏰")
}

// MARK: Common/Generic

func local(key: String, comment: String = "") -> String {
    return NSLocalizedString(key, comment: comment)
}

var brString: String { return "_________________________________________________________________" }
func printbr() {
    print(brString)
}
func printFunc(val: Any = __FUNCTION__) {
    print("🚩 \(val)")
}

func prettyPrint<T>(val: T, filename: NSString = __FILE__, line: Int = __LINE__, funcname: String = __FUNCTION__)
{
    print("\(NSDate()) [\(filename.lastPathComponent):\(line)] - \(funcname):\r\(val)\n")
}

public func resizeImage(var image : UIImage, size : CGSize) -> UIImage {
    UIGraphicsBeginImageContextWithOptions(size, false, 0);
    image.drawInRect(CGRectMake(0, 0, size.width, size.height))
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

func async<T>(back:()->(T), then main:(T)->()) {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        let some = back()
        dispatch_async(dispatch_get_main_queue()) {
            main(some)
        }
    }
}

func async(back:()->(), then main:()->()) {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        back()
        dispatch_async(dispatch_get_main_queue()) {
            main()
        }
    }
}

func sync(main:()->()) {
    dispatch_async(dispatch_get_main_queue()) {
        main()
    }
}

func async(back:()->()) {
    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
    dispatch_async(dispatch_get_global_queue(priority, 0)) {
        back()
    }
}

extension NSData {
    var unarchived: AnyObject? { return NSKeyedUnarchiver.unarchiveObjectWithData(self) }
}

extension Array {
    func safeRetrieveElement(index: Int) -> Element? {
        if count > index { return self[index] }
        return nil
    }
    
    mutating func removeFirst(element: Element, equality: (Element, Element) -> Bool) -> Bool {
        for (index, item) in enumerate() {
            if equality(item, element) {
                self.removeAtIndex(index)
                return true
            }
        }
        return false
    }
    
    mutating func removeFirst(compareTo: (Element) -> Bool) -> Bool {
        for (index, item) in enumerate() {
            if compareTo(item) {
                self.removeAtIndex(index)
                return true
            }
        }
        return false
    }
}


extension UIStoryboardSegue {
    func destinationController<T>(type: T.Type) -> T? {
        if let destNav = destinationViewController as? UINavigationController,
            let dest = destNav.topViewController as? T {
                return dest
        }
        
        if let dest = destinationViewController as? T {
            return dest
        }
        
        return nil
    }
}

extension UIViewController {
    func parentViewController<T: UIViewController>(ofType type:T.Type) -> T? {
        if  let parentVC = presentingViewController as? UINavigationController,
            let topParent = parentVC.topViewController as? T {
                return topParent
        } else
            if let parentVC = presentingViewController as? T {
                return parentVC
        }
        return nil
    }
}

extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.sharedApplication().keyWindow?.rootViewController {
            presentFromController(rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if  let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController {
                presentFromController(visibleVC, animated: animated, completion: completion)
        } else
        if  let tabVC = controller as? UITabBarController,
            let selectedVC = tabVC.selectedViewController {
                presentFromController(selectedVC, animated: animated, completion: completion)
        } else {
            controller.presentViewController(self, animated: animated, completion: completion)
        }
    }
}

extension UIAlertView {
    class func show(title: String?, message: String?, closeTitle: String?) {
        UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: closeTitle).show()
    }
}

extension UIImageView {
    func setImage(url: String, placeHolder: UIImage? = nil, animated: Bool = true) {
        if let placeHolderImage = placeHolder {
            self.image = placeHolderImage
        }

        UIImage.image(url, image: { (image) in
            if animated {
                UIView.transitionWithView(self, duration: 0.25, options: .TransitionCrossDissolve, animations: {
                    self.image = image
                }) { done in }
            } else {
                self.image = image
            }
        })
    }
}

extension UIImage {
    
    func resizeToSquare() -> UIImage? {
        let originalWidth  = self.size.width
        let originalHeight = self.size.height
        
        var edge: CGFloat
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        
        let posX = (originalWidth  - edge) / 2.0
        let posY = (originalHeight - edge) / 2.0
        
        let cropSquare = CGRectMake(posX, posY, edge, edge)
        
        if let imageRef = CGImageCreateWithImageInRect(self.CGImage, cropSquare)
        {
            return UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: self.imageOrientation)
        }
        return nil
        
    }
    
    /// Returns an image in the given size (in pixels)
    func resized(size: CGSize) -> UIImage? {
        let image = self.CGImage
        
        let bitsPerComponent = CGImageGetBitsPerComponent(image)
        let bytesPerRow = CGImageGetBytesPerRow(image)
        let colorSpace = CGImageGetColorSpace(image)
        let bitmapInfo = CGImageGetBitmapInfo(image)
        
        let context = CGBitmapContextCreate(nil, Int(size.width), Int(size.height), bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo.rawValue)
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.Medium)
        CGContextDrawImage(context, CGRect(origin: CGPointZero, size: size), image)
        
        if let aCGImage = CGBitmapContextCreateImage(context)
        {
            return UIImage(CGImage: aCGImage)
        }
        
        return nil
        
    }
    
    func scaled(scale: CGFloat) -> UIImage? {
        return resized(CGSizeMake(self.size.width * scale, self.size.height * scale))
    }
    
    func resizedToFullHD() -> UIImage? { return resize(maxLongEdge: 1920) }
    func resizedToMediumHD() -> UIImage? { return resize(maxLongEdge: 1080) }
    func resizeToThumbnail() -> UIImage? { return resize(maxLongEdge: 50) }
    
    func resize(maxLongEdge maxLongEdge: CGFloat) -> UIImage? {
        let longEdge = max(size.width, size.height)
        let shortEdge = min(size.width, size.height)
        
        if longEdge <= maxLongEdge {
            return self
        }
        
        let scale = maxLongEdge/longEdge
        if longEdge == size.width {
            return resized(CGSize(width: maxLongEdge, height: shortEdge * scale))
        } else {
            return resized(CGSize(width: shortEdge * scale, height: maxLongEdge))
        }
    }
    
    class func image(link: String, session: NSURLSession = NSURLSession.sharedSession(), image: (UIImage)->()) {
        let url = NSURL(string: link)!
        let downloadPhotoTask = session.downloadTaskWithURL(url) { (location, response, err) in
            if  let location = location,
                let data = NSData(contentsOfURL: location),
                let img = UIImage(data: data) {
                    dispatch_async(dispatch_get_main_queue()) {
                        image(img)
                    }
            }
        }
        downloadPhotoTask.resume()
    }
    
    class func imageWithInitials(initials: String, diameter: CGFloat, textColor: UIColor = UIColor.darkGrayColor(), backColor: UIColor = UIColor.lightGrayColor(), font: UIFont = UIFont.systemFontOfSize(14)) -> UIImage {
        let size = CGSizeMake(diameter, diameter)
        let r = size.width / 2
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetStrokeColorWithColor(context, backColor.CGColor)
        CGContextSetFillColorWithColor(context, backColor.CGColor)
        
        let path = UIBezierPath(ovalInRect: CGRectMake(0, 0, size.width, size.height))
        path.addClip()
        path.lineWidth = 1.0
        path.stroke()
        
        CGContextSetFillColorWithColor(context, backColor.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        
        let dict = [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor]
        let nsInitials = initials as NSString
        let textSize = nsInitials.sizeWithAttributes(dict)
        nsInitials.drawInRect(CGRectMake(r - textSize.width / 2, r - font.lineHeight / 2, size.width, size.height), withAttributes: dict)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

}

extension UITextField {
    
    func passRegex(expression: Regex) -> Bool {
        if let text = self.text where text.empty
        {
            return false
        }
        return (self.text ?? "").passRegex(expression)
    }
}

extension UIActivityIndicatorView {
    
    /// Calls 'startAnimating()' or 'stopAnimating()'. Returns 'isAnimating()'
    var animating: Bool {
        set{
            if newValue { startAnimating() }
            else { stopAnimating() }
        }
        get {
            return isAnimating()
        }
    }
}

extension UITableView {
    func reloadData(completion: ()->()) {
        UIView.animateWithDuration(0, animations: { self.reloadData() })
            { _ in completion() }
    }
    
    func calculateHeightForConfiguredSizingCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds.size = CGSize(width: frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height + 1
    }
    
    func deselectRowIfNeeded(animated animate: Bool = true) {
        if let selected = indexPathForSelectedRow {
            deselectRowAtIndexPath(selected, animated: animate)
        }
    }
    
    /**
    !!WILL OVERRIDE ANY EXISTING TABLE FOOTER THAT MIGHT EXIST!!
    */
    func hideEmptySeperators() {
        tableFooterView = UIView(frame: CGRectZero)
    }
}


enum Regex: String {
    case FullName = ".*\\s.*." // two words with a space
    case Email = "^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-.]+$"
    case Password = "^[\\d\\w]{6,255}$"
    case LetterOrDigit = "[a-zA-Z0-9]"
    case Digit = "[0-9]"
}

extension String {
    
    func passRegex(expression: Regex) -> Bool {
        var error: NSError?
        let regex: NSRegularExpression?
        do {
            regex = try NSRegularExpression(pattern: expression.rawValue, options: NSRegularExpressionOptions.CaseInsensitive)
        } catch let error1 as NSError {
            error = error1
            regex = nil
        }
        
        if error != nil {
            print(error)
        }
        
        if self.empty {
            return false
        }
        
        let str: NSString = self as NSString
        let options: NSMatchingOptions = NSMatchingOptions()
        let numOfMatches = regex!.numberOfMatchesInString(str as String, options: options, range: str.rangeOfString(str as String))
        
        return numOfMatches > 0
    }
    
    func attributedStringFromHTMLString(overrideFont: Bool = false, color: UIColor = UIColor.whiteColor()) -> NSAttributedString {
        let options = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
        ]
        
        var atStr: NSMutableAttributedString?
        do {

            atStr = try NSMutableAttributedString(data: self.dataUsingEncoding(NSUTF8StringEncoding)!, options: options as! [String : AnyObject], documentAttributes: nil)
            if let str = atStr
            {
                let range = NSMakeRange(0, NSString(string: str.string).length)
                
                str.addAttribute(NSForegroundColorAttributeName, value: color, range: range)
                
                if overrideFont {
                    str.addAttribute(NSFontAttributeName, value: UIFont.preferredFontForTextStyle(UIFontTextStyleBody), range:range)
                }
                
                atStr = str
            }
            
        }
        catch let error as NSError
        {
            prettyPrint(error)
        }
        
        if let s = atStr
        {
            return s
        }
        
        return NSMutableAttributedString(string: "")
    }
    
    func stringByTrimmingHTMLTags() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: nil)
    }
       
    func firstWord() -> String? {
        return self.componentsSeparatedByString(" ").first
    }
    
    func lastWord() -> String? {
        return self.componentsSeparatedByString(" ").last
    }
    
    var firstChar: String? { return empty ? nil : String(self[0]) }
    var lastChar:  String? { return String(self[endIndex.predecessor()]) }

    func firstCharAsLetterOrDigit() -> String? {
        if let f = firstChar where f.passRegex(.LetterOrDigit) { return f }
        return nil
    }
    
    var empty: Bool {
        return self.characters.count == 0
    }
    
    /// Either empty or only whitespace and/or new lines
    var emptyDeduced: Bool {
        return empty || stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).empty
    }
        
    // discussion: http://stackoverflow.com/a/2933145/2242359
    func stringByForcingWritingDirectionLTR() -> String {
        return "\u{200E}".stringByAppendingString(self)
    }
    
    func stringByForcingWritingDirectionRTL() -> String {
        return "\u{200F}".stringByAppendingString(self)
    }
    /**
    Returns the caller string with apostrophes.
    e.g.,
    "Hello" will return "\"Hello\""
    */
    func forceApostrophes() -> String {
        return "\"\(self)\""
    }
    
    func contains(substring: String, ignoreCase: Bool = false, ignoreDiacritic: Bool = false) -> Bool {
        var options = NSStringCompareOptions()
        if ignoreCase { options.insert(NSStringCompareOptions.CaseInsensitiveSearch) }
        if ignoreDiacritic { options.insert(NSStringCompareOptions.DiacriticInsensitiveSearch) }
        return rangeOfString(substring, options: options) != nil
    }
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }

}

extension NSMutableAttributedString {
    public func addAttribute(name: String, value: AnyObject, ranges: [NSRange]) {
        for r in ranges {
            addAttribute(name, value: value, range: r)
        }
    }
}


extension Int {
    var ordinal: String {
        get {
            var suffix: String = ""
            let ones: Int = self % 10;
            let tens: Int = (self/10) % 10;
            
            if (tens == 1) {
                suffix = "th";
            } else if (ones == 1){
                suffix = "st";
            } else if (ones == 2){
                suffix = "nd";
            } else if (ones == 3){
                suffix = "rd";
            } else {
                suffix = "th";
            }
            
            return suffix
        }
    }
    
    var string: String {
        get{
            return "\(self)"
        }
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    func shakeView() {
        let shake:CABasicAnimation = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let from_point:CGPoint = CGPointMake(self.center.x - 5, self.center.y)
        let from_value:NSValue = NSValue(CGPoint: from_point)
        
        let to_point:CGPoint = CGPointMake(self.center.x + 5, self.center.y)
        let to_value:NSValue = NSValue(CGPoint: to_point)
        
        shake.fromValue = from_value
        shake.toValue = to_value
        self.layer.addAnimation(shake, forKey: "position")
    }
    
    func blowView() {
        UIView.animateWithDuration(0.1, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(1.06, 1.05)
        }) { _ in
                
                UIView.animateWithDuration(0.06, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                    self.transform = CGAffineTransformIdentity
                }) { _ in }
            
        }
    }
    
    func snapShotImage(afterScreenUpdates after: Bool) -> UIImage? {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.drawViewHierarchyInRect(self.bounds, afterScreenUpdates: after)
        let snap = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snap
    }
}

extension NSNotificationCenter {
    
    class func post(name: String) {
        defaultCenter().postNotificationName(name, object: nil)
    }
    
    class func observe(name: String, usingBlock block: (NSNotification!) -> Void) -> NSObjectProtocol {
        return defaultCenter().addObserverForName(name, object: nil, queue: nil, usingBlock:block)
    }
    
    class func observe<T: AnyObject>(target: T, name: String, usingBlock block: (note: NSNotification!, targetRef: T) -> Void) -> NSObjectProtocol {
        weak var weakTarget = target
        return defaultCenter().addObserverForName(name, object: nil, queue: nil) {
            if let strTarget = weakTarget {
                block(note: $0, targetRef: strTarget)
            }
        }
    }
    
}

extension NSDate {
    class func todayComponents() -> (day: Int, month: Int, year: Int) {
        let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let units: NSCalendarUnit = [NSCalendarUnit.Day, NSCalendarUnit.Month, NSCalendarUnit.Year]
        let comps = calendar.components(units, fromDate: NSDate())
        return (comps.day, comps.month, comps.year)
    }
    
    var shortDescription: String { return self.customDescription(.ShortStyle, date: .ShortStyle) }
    var shortTime: String { return self.customDescription(.ShortStyle) }
    var shortDate: String { return self.customDescription(date: .ShortStyle) }
    var mediumDescription: String { return self.customDescription(.MediumStyle, date: .MediumStyle) }
    var mediumTime: String { return self.customDescription(.MediumStyle) }
    var mediumDate: String { return self.customDescription(date: .MediumStyle) }
    var longDescription: String { return self.customDescription(.LongStyle, date: .LongStyle) }
    var longTime: String { return self.customDescription(.LongStyle) }
    var longDate: String { return self.customDescription(date: .LongStyle) }
    
    func customDescription(time: NSDateFormatterStyle = .NoStyle, date: NSDateFormatterStyle = .NoStyle) -> String {
        let form = NSDateFormatter()
        form.timeStyle = time
        form.dateStyle = date
        return form.stringFromDate(self)
    }
    
    func formattedFromCompenents(styleAttitude: NSDateFormatterStyle, year: Bool = true, month: Bool = true, day: Bool = true, hour: Bool = true, minute: Bool = true, second: Bool = true) -> String {
        let long = styleAttitude == .LongStyle || styleAttitude == .FullStyle ? true : false
        var comps = ""
        
        if year { comps += long ? "yyyy" : "yy" }
        if month { comps += long ? "MMMM" : "MMM" }
        if day { comps += long ? "dd" : "d" }
        
        if hour { comps += long ? "HH" : "H" }
        if minute { comps += long ? "mm" : "m" }
        if second { comps += long ? "ss" : "s" }
        
        let format = NSDateFormatter.dateFormatFromTemplate(comps, options: 0, locale: NSLocale.currentLocale())
        let formatter = NSDateFormatter()
        formatter.dateFormat = format
        return formatter.stringFromDate(self)
    }
    
    func formatted(format: String) -> String {
        let form = NSDateFormatter()
        form.dateFormat = format
        return form.stringFromDate(self)
    }
    
    /**
    Init an NSDate with string and format. eg. (W3C format: "YYYY-MM-DDThh:mm:ss")
    
    - parameter val:      the value with the date info
    - parameter format:   the format of the value string
    - parameter timeZone: optional, default is GMT time (not current locale!)
    
    - returns: returns the created date, if succeeded
    */
    convenience init?(val: String, format: String, timeZone: String = "") {
        let form = NSDateFormatter()
        form.dateFormat = format
        if timeZone.emptyDeduced {
            form.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        } else {
            form.timeZone = NSTimeZone(name: timeZone)
        }
        if let date = form.dateFromString(val) {
            self.init(timeIntervalSince1970: date.timeIntervalSince1970)
        } else {
            self.init()
            return nil
        }
    }
}

extension UIApplication {
    
    static var isAppInForeground: Bool {
        return sharedApplication().applicationState == UIApplicationState.Active
    }
    
    func registerForPushNotifications() {

        let types: UIUserNotificationType = ([.Alert, .Badge, .Sound])
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
        
        registerUserNotificationSettings(settings)
        registerForRemoteNotifications()
    }
    
}

extension NSFileManager
{
    class func documentsDir() -> String
    {
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) 
        return paths[0]
    }
    
    class func cachesDir() -> String
    {
        var paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true) 
        return paths[0]
    }
    
    class func tempBaseDir() -> String!
    {
        print("temp - \(NSTemporaryDirectory())")
        return NSTemporaryDirectory()        
    }

}

func + <K,V>(left: Dictionary<K,V>, right: Dictionary<K,V>) -> Dictionary<K,V> {
    var map = Dictionary<K,V>()
    for (k, v) in left {
        map[k] = v
    }
    for (k, v) in right {
        map[k] = v
    }
    return map
}


