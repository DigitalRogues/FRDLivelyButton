//
//  FRDLively-Swift.swift
//  Last Layer
//
//  Created by punk on 11/8/16.
//
//

import UIKit

enum kFRDLivelyButtonStyle {
    case kFRDLivelyButtonStyleHamburger
    case kFRDLivelyButtonStyleClose
    case kFRDLivelyButtonStylePlus
    case kFRDLivelyButtonStyleCirclePlus
    case kFRDLivelyButtonStyleCircleClose
    case kFRDLivelyButtonStyleCaretUp
    case kFRDLivelyButtonStyleCaretDown
    case kFRDLivelyButtonStyleCaretLeft
    case kFRDLivelyButtonStyleCaretRight
    case kFRDLivelyButtonStyleArrowLeft
    case kFRDLivelyButtonStyleArrowRight
}

// enum buttonProp: String {
//    case kFRDLivelyButtonHighlightScale = "kFRDLivelyButtonHighlightScale"
//    case kFRDLivelyButtonLineWidth = "kFRDLivelyButtonLineWidth"
//    case kFRDLivelyButtonColor = "kFRDLivelyButtonColor"
//    case kFRDLivelyButtonHighlightedColor = "kFRDLivelyButtonHighlightedColor"
//    case kFRDLivelyButtonHighlightAnimationDuration = "kFRDLivelyButtonHighlightAnimationDuration"
//    case kFRDLivelyButtonUnHighlightAnimationDuration = "kFRDLivelyButtonUnHighlightAnimationDuration"
//    case kFRDLivelyButtonStyleChangeAnimationDuration = "kFRDLivelyButtonStyleChangeAnimationDuration"
// }

class FRDLivelyButton: UIButton {

    var buttonStyle: kFRDLivelyButtonStyle?
    var dimension: CGFloat = 0
    var offset: CGPoint = CGPoint(x: 0, y: 0)
    var centerPoint: CGPoint = CGPoint(x: 0, y: 0)

    var circleLayer: CAShapeLayer = CAShapeLayer()
    var line1Layer: CAShapeLayer = CAShapeLayer()

    var line2Layer: CAShapeLayer = CAShapeLayer()

    var line3Layer: CAShapeLayer = CAShapeLayer()

    var shapeLayers = Array<CAShapeLayer>()
    let options = FRDLivelyButtonObject()

    let GOLDEN_RATIO: CGFloat = 1.618

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialization code
        self.commonInitializer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.commonInitializer()
    }

    func commonInitializer() {
        self.line1Layer = CAShapeLayer()
        self.line2Layer = CAShapeLayer()
        self.line3Layer = CAShapeLayer()
        self.circleLayer = CAShapeLayer()

        // options = FRDLivelyButton.defaultOptions()

        // i think this configs and adds all the blank paths to the main view
        let array = [line1Layer, line2Layer, line3Layer, circleLayer]
        array.forEach { (obj) in
            let layer = obj
            layer.fillColor = UIColor.clear.cgColor
            layer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            layer.lineJoin = kCALineJoinRound
            layer.lineCap = kCALineCapRound
            layer.contentsScale = self.layer.contentsScale
            // initialize with an empty path so we can animate the path w/o having to check for NULLs.
            let dummyPath = CGMutablePath()
            layer.path = dummyPath
            self.layer.addSublayer(layer)
        }

        self.addTarget(self, action: #selector(showHighlight), for: .touchDown)
        self.addTarget(self, action: #selector(showUnHighlight), for: .touchUpInside)
        self.addTarget(self, action: #selector(showUnHighlight), for: .touchUpOutside)
        //
        // in case the button is not square, the offset will be use to keep our CGPath's centered in it.
        let width: Double = Double(self.frame.width) - Double(self.contentEdgeInsets.left + self.contentEdgeInsets.right)
        let height: Double = Double(self.frame.height) - Double(self.contentEdgeInsets.top + self.contentEdgeInsets.bottom)
        self.dimension = CGFloat(min(width, height))
        self.offset = CGPoint(x: (self.frame.width - self.dimension) / 2.0, y: (self.frame.height - self.dimension) / 2.0)
        self.centerPoint = CGPoint(x: self.bounds.midX, y: self.bounds.midY)

        // set some options on existing objects?
        let layerArray = [line1Layer, line2Layer, line3Layer, circleLayer]
        layerArray.forEach { (obj) in
            let layer = obj
            layer.lineWidth = options.kFRDLivelyButtonLineWidth
            layer.strokeColor = options.kFRDLivelyButtonColor
        }
    }

    //    func setOptions(options: Dictionary<buttonProp, Any>) {
    //        //self.options = options
    //
    //        // set some options on existing objects?
    //        let array = [line1Layer, line2Layer, line3Layer, circleLayer]
    //        array.forEach { (obj) in
    //            let layer = obj
    //            layer.lineWidth = options//(valueForOptionKey(key: buttonProp.kFRDLivelyButtonLineWidth) as! CGFloat)
    //            layer.strokeColor = (valueForOptionKey(key: buttonProp.kFRDLivelyButtonColor) as! CGColor)
    //        }
    //    }

    //    func valueForOptionKey(key: buttonProp) -> Any {
    //        if self.options[key] != nil {
    //            return self.options[key]!
    //        }
    //        return FRDLivelyButton.defaultOptions()[key] as Any
    //    }

    func shapedLayers() -> Array<CAShapeLayer> {
        if shapeLayers.count == 0 {
            shapeLayers = [circleLayer, line1Layer, line2Layer, line3Layer]
        }

        return shapeLayers
    }

    //    class func defaultOptions() -> Dictionary<buttonProp, Any> {
    //        let dic = [buttonProp.kFRDLivelyButtonColor: UIColor.black, buttonProp.kFRDLivelyButtonHighlightedColor: UIColor.lightGray, buttonProp.kFRDLivelyButtonHighlightAnimationDuration: 0.1, buttonProp.kFRDLivelyButtonHighlightScale: 0.9, buttonProp.kFRDLivelyButtonLineWidth: 1.0, buttonProp.kFRDLivelyButtonUnHighlightAnimationDuration: 0.15, buttonProp.kFRDLivelyButtonStyleChangeAnimationDuration: 0.3] as [buttonProp: Any]
    //
    //        return dic
    //    }

    func transformWithScale(scale: CGFloat) -> CGAffineTransform {
        let transform = CGAffineTransform(translationX: (self.dimension + 2 * (self.offset.x)) * ((1 - scale) / 2.0), y: (self.dimension + 2 * (self.offset.y)) * ((1 - scale) / 2.0))
        return transform.scaledBy(x: scale, y: scale)
    }

    func createCenteredCircle(withRadius radius: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()

        path.move(to: CGPoint(x: (self.centerPoint.x) + radius, y: (self.centerPoint.y)))

        // note: if clockwise is set to true, the circle will not draw on an actual device,
        // event hough it is fine on the simulator...
        path.addArc(center: CGPoint(x: (self.centerPoint.x), y: (self.centerPoint.y)), radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: false)
        return path
    }

    func createCenteredLine(withRadius radius: CGFloat, angle: CGFloat, offset: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        let fangle = Float(angle)
        let c: CGFloat = CGFloat(cosf(fangle))
        let s: CGFloat = CGFloat(sinf(fangle))
        path.move(to: CGPoint(x: (self.centerPoint.x) + offset.x + radius * c, y: (self.centerPoint.y) + offset.y + radius * s))
        path.addLine(to: CGPoint(x: (self.centerPoint.x) + offset.x - radius * c, y: (self.centerPoint.y) + offset.y - radius * s))
        return path
    }

    func createLine(from p1: CGPoint, to p2: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: (self.offset.x) + p1.x, y: (self.offset.y) + p1.y))
        path.addLine(to: CGPoint(x: (self.offset.x) + p2.x, y: (self.offset.y) + p2.y))
        return path
    }

    func setStyle(style: kFRDLivelyButtonStyle, animated: Bool) {
        buttonStyle = style
        var newCirclePath = CGMutablePath()
        var newLine1Path = CGMutablePath()
        var newLine2Path = CGMutablePath()
        var newLine3Path = CGMutablePath()
        var newCircleAlpha: CGFloat = 0.0
        var newLine1Alpha: CGFloat = 0.0

        if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleHamburger {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 1.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: 0, offset: CGPoint(x: 0, y: -self.dimension / 2.0 / GOLDEN_RATIO))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: 0, offset: CGPoint(x: 0, y: self.dimension / 2.0 / GOLDEN_RATIO))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStylePlus {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: +(CGFloat)(M_PI_2), offset: CGPoint(x: 0, y: 0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: 0, offset: CGPoint(x: 0, y: 0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCirclePlus {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 2.0)
            newCircleAlpha = 1.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 2.0 / GOLDEN_RATIO, angle: CGFloat(M_PI_2), offset: CGPoint(x: 0, y: 0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 2.0 / GOLDEN_RATIO, angle: 0, offset: CGPoint(x: 0, y: 0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleClose {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: +(CGFloat)(M_PI_4), offset: CGPoint(x: 0, y: 0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: -(CGFloat)(M_PI_4), offset: CGPoint(x: 0, y: 0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCircleClose {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 2.0)
            newCircleAlpha = 1.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 2.0 / GOLDEN_RATIO, angle: +(CGFloat)(M_PI_4), offset: CGPoint(x: 0, y: 0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 2.0 / GOLDEN_RATIO, angle: -(CGFloat)(M_PI_4), offset: CGPoint(x: 0, y: 0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretUp {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line2Layer.lineWidth / 2.0, angle: CGFloat(M_PI_4), offset: CGPoint(x: self.dimension / 6.0, y: 0.0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line3Layer.lineWidth / 2.0, angle: CGFloat(3) * CGFloat(M_PI_4), offset: CGPoint(x: -self.dimension / 6.0, y: 0.0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretDown {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line2Layer.lineWidth / 2.0, angle: -(CGFloat)(M_PI_4), offset: CGPoint(x: self.dimension / 6.0, y: 0.0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line3Layer.lineWidth / 2.0, angle: CGFloat(-3) * CGFloat(M_PI_4), offset: CGPoint(x: -self.dimension / 6.0, y: 0.0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretLeft {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line2Layer.lineWidth / 2.0, angle: CGFloat(-3) * CGFloat(M_PI_4), offset: CGPoint(x: 0.0, y: self.dimension / 6.0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line3Layer.lineWidth / 2.0, angle: CGFloat(3) * CGFloat(M_PI_4), offset: CGPoint(x: 0.0, y: -self.dimension / 6.0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleCaretRight {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 20.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 0.0
            newLine2Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line2Layer.lineWidth / 2.0, angle: -(CGFloat)(M_PI_4), offset: CGPoint(x: 0.0, y: self.dimension / 6.0))
            newLine3Path = self.createCenteredLine(withRadius: self.dimension / 4.0 - self.line3Layer.lineWidth / 2.0, angle: CGFloat(M_PI_4), offset: CGPoint(x: 0.0, y: -self.dimension / 6.0))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleArrowLeft {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: .pi, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 1.0
            newLine2Path = self.createLine(from: CGPoint(x: 0, y: self.dimension / 2.0), to: CGPoint(x: self.dimension / 2.0 / GOLDEN_RATIO, y: self.dimension / 2 + self.dimension / 2.0 / GOLDEN_RATIO))
            newLine3Path = self.createLine(from: CGPoint(x: 0, y: self.dimension / 2.0), to: CGPoint(x: self.dimension / 2.0 / GOLDEN_RATIO, y: self.dimension / 2 - self.dimension / 2.0 / GOLDEN_RATIO))
        } else if style == kFRDLivelyButtonStyle.kFRDLivelyButtonStyleArrowRight {
            newCirclePath = self.createCenteredCircle(withRadius: self.dimension / 20.0)
            newCircleAlpha = 0.0
            newLine1Path = self.createCenteredLine(withRadius: self.dimension / 2.0, angle: 0, offset: CGPoint(x: 0, y: 0))
            newLine1Alpha = 1.0
            newLine2Path = self.createLine(from: CGPoint(x: self.dimension, y: self.dimension / 2.0), to: CGPoint(x: self.dimension - self.dimension / 2.0 / GOLDEN_RATIO, y: self.dimension / 2 + self.dimension / 2.0 / GOLDEN_RATIO))
            newLine3Path = self.createLine(from: CGPoint(x: self.dimension, y: self.dimension / 2.0), to: CGPoint(x: self.dimension - self.dimension / 2.0 / GOLDEN_RATIO, y: self.dimension / 2 - self.dimension / 2.0 / GOLDEN_RATIO))
        } else {
            assert(false, "unknown type")
        }

        let duration: TimeInterval = options.kFRDLivelyButtonStyleChangeAnimationDuration // valueForOptionKey(key: buttonProp.kFRDLivelyButtonStyleChangeAnimationDuration) as! Double

        if animated {
            let circleAnim = CABasicAnimation(keyPath: "path")
            circleAnim.isRemovedOnCompletion = false
            circleAnim.duration = CFTimeInterval(duration)
            circleAnim.fromValue = circleLayer.path
            circleAnim.toValue = newCirclePath
            circleAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            circleLayer.add(circleAnim, forKey: "animateCirclePath")

            let circleAlphaAnim = CABasicAnimation(keyPath: "opacity")
            circleAlphaAnim.isRemovedOnCompletion = false
            circleAlphaAnim.duration = CFTimeInterval(duration)
            circleAlphaAnim.fromValue = self.circleLayer.opacity
            circleAlphaAnim.toValue = newCircleAlpha
            circleAlphaAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            circleLayer.add(circleAlphaAnim, forKey: "animateCircleOpacityPath")

            let line1Anim = CABasicAnimation(keyPath: "path")
            line1Anim.isRemovedOnCompletion = false
            line1Anim.duration = CFTimeInterval(duration)
            line1Anim.fromValue = line1Layer.path
            line1Anim.toValue = newLine1Path
            line1Anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            line1Layer.add(line1Anim, forKey: "animateLine1Path")

            let line1AlphaAnim = CABasicAnimation(keyPath: "opacity")
            line1AlphaAnim.isRemovedOnCompletion = false
            line1AlphaAnim.duration = CFTimeInterval(duration)
            line1AlphaAnim.fromValue = line1Layer.opacity
            line1AlphaAnim.toValue = newLine1Alpha
            line1AlphaAnim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            line1Layer.add(line1AlphaAnim, forKey: "animateLine1OpacityPath")

            let line2Anim = CABasicAnimation(keyPath: "path")
            line2Anim.isRemovedOnCompletion = false
            line2Anim.duration = CFTimeInterval(duration)
            line2Anim.fromValue = line2Layer.path
            line2Anim.toValue = newLine2Path
            line2Anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            line2Layer.add(line2Anim, forKey: "animateLine2Path")

            let line3Anim = CABasicAnimation(keyPath: "path")
            line3Anim.isRemovedOnCompletion = false
            line3Anim.duration = CFTimeInterval(duration)
            line3Anim.fromValue = line3Layer.path
            line3Anim.toValue = newLine3Path
            line3Anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            line3Layer.add(line3Anim, forKey: "animateLine3Path")

            circleLayer.path = newCirclePath
            circleLayer.opacity = Float(newCircleAlpha)
            line1Layer.path = newLine1Path
            line1Layer.opacity = Float(newLine1Alpha)
            line2Layer.path = newLine2Path
            line3Layer.path = newLine3Path
        }
    }

    func showHighlight() {
        let highlightScale = options.kFRDLivelyButtonHighlightScale
        shapeLayers.forEach { (layer) in
            layer.strokeColor = options.kFRDLivelyButtonHighlightedColor

            var transform: CGAffineTransform = transformWithScale(scale: highlightScale)

            let scaledPath = layer.path?.copy(using: &transform)

            let anim = CABasicAnimation(keyPath: "path")
            anim.duration = options.kFRDLivelyButtonHighlightAnimationDuration
            anim.isRemovedOnCompletion = false
            anim.fromValue = layer.path
            anim.toValue = scaledPath
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            layer.add(anim, forKey: "layerAnim")

            layer.path = scaledPath
        }
    }

    func showUnHighlight() {
        let unHighlightScale = CGFloat(1) / options.kFRDLivelyButtonHighlightScale

        shapeLayers.forEach { (layer) in
            layer.strokeColor = options.kFRDLivelyButtonColor
            let path = layer.path
            var transform = transformWithScale(scale: unHighlightScale)
            let finalPath = path?.mutableCopy(using: &transform)

            var upTransform = transformWithScale(scale: unHighlightScale * 1.07)
            let scaledUpPath = path?.mutableCopy(using: &upTransform)

            var downTransform = transformWithScale(scale: unHighlightScale * 0.97)
            let scaledDownPath = path?.mutableCopy(using: &downTransform)

            let values = [layer.path!, scaledUpPath!, scaledDownPath!, finalPath!]

            let times = [0.0, 0.85, 0.93, 1.0]

            let anim = CAKeyframeAnimation(keyPath: "path")
            anim.duration = options.kFRDLivelyButtonUnHighlightAnimationDuration
            anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
            anim.isRemovedOnCompletion = false
            anim.values = values
            anim.keyTimes = times as [NSNumber]?
            layer.add(anim, forKey: "keyanim")

            layer.path = finalPath
        }
    }
}
