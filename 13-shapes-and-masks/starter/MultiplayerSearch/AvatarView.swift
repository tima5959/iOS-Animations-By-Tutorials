/*
 * Copyright (c) 2014-present Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import QuartzCore

@IBDesignable
class AvatarView: UIView {
    
    //constants
    let lineWidth: CGFloat = 6.0
    let animationDuration = 1.0
    
    //ui
    let photoLayer = CALayer() // Слой фотографии
    let circleLayer = CAShapeLayer() // Слой овальной рамки
    let maskLayer = CAShapeLayer() // Слой маски которая заменяет нам фрейм и позволяет использовать морф эффект
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "ArialRoundedMTBold", size: 18.0)
        label.textAlignment = .center
        label.textColor = UIColor.black
        return label
    }()
    
    //variables
    @IBInspectable
    var image: UIImage? = nil {
        didSet {
            photoLayer.contents = image?.cgImage
        }
    }
    
    @IBInspectable
    var name: String? = nil {
        didSet {
            label.text = name
        }
    }
    
    var shouldTransitionToFinishedState = false
    var isSquare = false
    
    override func didMoveToWindow() {
        layer.addSublayer(photoLayer)
        photoLayer.mask = maskLayer
        layer.addSublayer(circleLayer)
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let image = image else { return }
        
        //Size the avatar image to fit
        photoLayer.frame = CGRect(
            x: (bounds.size.width - image.size.width + lineWidth) / 2,
            y: (bounds.size.height - image.size.height - lineWidth) / 2,
            width: image.size.width,
            height: image.size.height)
        
        //Draw the circle
        circleLayer.path = UIBezierPath(ovalIn: bounds).cgPath
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.lineWidth = lineWidth
        circleLayer.fillColor = UIColor.clear.cgColor
        
        //Size the layer
        maskLayer.path = circleLayer.path
        maskLayer.position = CGPoint(x: 0.0, y: 10.0)
        
        //Size the label
        label.frame = CGRect(x: 0.0, y: bounds.size.height + 10.0, width: bounds.size.width, height: 24.0)
    }
    
    // Функция отвечает за то, на какое расстояние центр аватара переместится и с каким эффектом
    func bounceOff(point: CGPoint, morphSize: CGSize) {
        let originalCenter = center
        UIView.animate(withDuration: animationDuration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8, // Определяет «жесткость пружины». Чем выше значение этого параметра (может быть в диапазоне от 0 до 1), тем быстрее «успокоится» анимация.
                       initialSpringVelocity: 0.0, // Определяет начальную скорость пружины. Значение 1 устанавливает такую скорость анимации, при которой все ее расстояние будет пройдено за одну секунду. Если общее расстояние, на которое перемещается ​view​, равно 100 точкам, то при значении данного параметра 0.7 начальная скорость будет равна 70 точек в секунду.
                       animations: {
                        self.center = point
                       },
                       completion: { _ in
                        if self.shouldTransitionToFinishedState {
                            self.animateToSquare()
                        }
                       } )
        
        UIView.animate(withDuration: animationDuration,
                       delay: animationDuration,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1.0,
                       animations: {
                        self.center = originalCenter
                       },
                       completion: { _ in
                        delay(seconds: 0.1) {
                            if self.isSquare == false {
                                self.bounceOff(point: point, morphSize: morphSize)
                            }
                        }
                       }
        )
        
        let morphedFrame = (originalCenter.x > point.x) ?
            CGRect(x: 0.0,
                   y: bounds.height - morphSize.height,
                   width: morphSize.width,
                   height: morphSize.height)
            :
            CGRect(x: bounds.width - morphSize.width,
                   y: bounds.height - morphSize.height,
                   width: morphSize.width,
                   height: morphSize.height)
        
        let morphAnimation = CABasicAnimation(keyPath: "path")
        morphAnimation.duration = animationDuration
        morphAnimation.toValue = UIBezierPath(ovalIn: morphedFrame).cgPath
        morphAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        circleLayer.add(morphAnimation, forKey: nil)
        maskLayer.add(morphAnimation, forKey: nil)
    }
    
    func animateToSquare() {
        isSquare = true
        let squarePath = CGPath(rect: self.bounds, transform: nil)
        let bezierPath = UIBezierPath(cgPath: squarePath)
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.25
        animation.fromValue = circleLayer
        animation.toValue = bezierPath.cgPath
        circleLayer.add(animation, forKey: nil)
        circleLayer.path = squarePath
        maskLayer.add(animation, forKey: nil)
        maskLayer.path = squarePath
    }
    
}
