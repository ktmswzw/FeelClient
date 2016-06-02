//
//  RadarView.swift
//  FeelingClient
//
//  Created by Vincent on 6/1/16.
//  Copyright © 2016 xecoder. All rights reserved.
//
//
import UIKit

class RadarViewBiBi: UIView {
    var radarTimer: NSTimer?
    var radarClickButton: UIButton?
    override func drawRect(rect: CGRect) {
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        radarClickButton = UIButton(type: .System)
        radarClickButton?.frame = self.bounds
        radarClickButton?.layer.cornerRadius = (radarClickButton?.frame.size.width)!/2
        radarClickButton?.layer.masksToBounds = true
        radarClickButton?.addTarget(self, action: #selector(RadarViewBiBi.radarClickButton(_:)), forControlEvents: .TouchUpInside)
        self.addSubview(radarClickButton!)
        
        raderColor = UIColor ( red: 0.0, green: 0.502, blue: 1.0, alpha: 0.5 )
    }
    func radarClickButton(sender: UIButton){
        print("radarClickButton")
    }
    // 实现雷达画圈功能
    func drawCircle (){
        
        let center = CGPointMake(self.bounds.size.height/2, self.bounds.size.width/2)
        let path = UIBezierPath.init(arcCenter: center, radius: 25.0, startAngle: 0, endAngle:CGFloat(M_PI+M_PI), clockwise: true)
        let shapeLayer = CAShapeLayer.init()
        shapeLayer.frame = self.bounds
        shapeLayer.fillColor = raderColor?.CGColor
        shapeLayer.opacity = 0.2
        shapeLayer.path = path.CGPath
        self.layer.insertSublayer(shapeLayer, below: radarClickButton?.layer)
        addAnimation(shapeLayer)
    }
    func addAnimation(shapeLayer: CAShapeLayer){
        // 雷达圈的大小变化
        let basicAnimation = CABasicAnimation.init()
        basicAnimation.keyPath = "path"
        let center =  CGPointMake(self.bounds.size.height/2, self.bounds.size.width/2)
        let pathOne = UIBezierPath.init(arcCenter: center, radius: 1, startAngle: 0, endAngle: CGFloat(M_PI+M_PI), clockwise: true)
        let pathTwo = UIBezierPath.init(arcCenter: center, radius: UIScreen.mainScreen().bounds.size.width, startAngle: 0, endAngle: CGFloat(M_PI+M_PI), clockwise: true)
        basicAnimation.fromValue = pathOne.CGPath
        basicAnimation.toValue = pathTwo.CGPath
        basicAnimation.fillMode = kCAFillModeForwards
        
        
        // 雷达圈的透明度变化
        let opacityAnimation = CABasicAnimation.init()
        opacityAnimation.keyPath = "opacity"
        opacityAnimation.fromValue = 0.2
        opacityAnimation.toValue = 0.0
        opacityAnimation.fillMode = kCAFillModeForwards
        
        
        // 动画组
        let group = CAAnimationGroup.init()
        group.animations = [basicAnimation,opacityAnimation]
        group.duration = 5
        group.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseOut)
        group.delegate = self
        group.removedOnCompletion = true
        shapeLayer.addAnimation(group, forKey: nil)
    }
    override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag == true{
            if self.layer.sublayers![0].isKindOfClass(CAShapeLayer){
                let shaperLayer: CAShapeLayer = self.layer.sublayers![0] as! CAShapeLayer
                shaperLayer.removeFromSuperlayer()
            }
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // setter 方法的实现
    var normalImage: UIImage?{// 正常状态下的图片
        willSet{
            radarClickButton?.setBackgroundImage(newValue, forState: .Normal)
        }didSet{
            
        }
    }
    var selectImage: UIImage?{// 选中状态下的图片
        willSet{
            radarClickButton?.setBackgroundImage(newValue, forState: .Highlighted)
        }didSet{
            
        }
    }
    var isStart: Bool?{// 是否直接开始雷达  默认no
        willSet{
            if newValue == true{
                radarTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(RadarViewBiBi.drawCircle), userInfo: nil, repeats: true)
            }else{
                radarTimer?.invalidate()
                radarTimer = nil
            }
        }didSet{
            
        }
    }
    var raderColor: UIColor?{// 波纹颜色
        willSet{
            
        }didSet{
            
        }
    }
}
