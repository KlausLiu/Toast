//
//  Toast.swift
//  Toast
//
//  Created by Klaus on 2018/5/18.
//  Copyright © 2018年 KlausLiu. All rights reserved.
//

import UIKit


public let defaultDuration: TimeInterval = 2

@objc(KLToast)
public class Toast: NSObject {

    private var message: String
    private var duration: TimeInterval
    private var window: ToastWindow?
    
    /// 显示Toast
    ///
    /// - Parameters:
    ///   - _message: Toast显示的内容
    ///   - duration: Toast显示的时间
    @objc(show:)
    public class func show(_ message: String) {
        self.show(message, duration: defaultDuration)
    }
    @objc(show:duration:)
    public class func show(_ message: String, duration: TimeInterval = defaultDuration) {
        let toast = Toast(message, duration: duration)
        toast.show()
    }
    
    private init(_ message: String, duration: TimeInterval = defaultDuration) {
        self.message = message
        self.duration = duration
    }
    
    private func show() {
        
        ToastCenter.default.toasts.forEach { (toast) in
            toast.dismiss()
        }
        ToastCenter.default.removeCurrentToast()
        ToastCenter.default.add(self)
        
        self.window = ToastWindow(message: self.message)
        self.window?.makeKeyAndVisible()
        
        self.window?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animateKeyframes(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState], animations: {
            self.window?.transform = CGAffineTransform.identity
        }) { (_) in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + self.duration) {
                self.window?.alpha = 1
                UIView.animate(withDuration: 0.3, animations: {
                    self.window?.alpha = 0
                }, completion:{ completed in
                    self.dismiss()
                })
            }
        }
    }
    
    private func dismiss() {
        ToastCenter.default.removeOne(self)
        self.window?.dismiss()
        self.window = nil
    }
}

private class ToastCenter: NSObject {
    
    static let `default` = ToastCenter()
    var toasts: [Toast] {
        get { return privateToasts }
    }
    private var privateToasts:[Toast] = [Toast]()
    
    private override init() {}
    
    /// 添加Toast对象入队列
    ///
    /// - Parameter toast: Toast对象
    func add(_ toast: Toast) {
        privateToasts.append(toast)
    }
    
    func removeCurrentToast() {
        privateToasts.removeAll()
    }
    func removeOne(_ toast: Toast) {
        privateToasts = privateToasts.filter{ $0 !== toast }
    }
}


/// 每一个Toast都会有一个独立的window
private class ToastWindow: UIWindow {
    weak var oldKeyWindow: UIWindow?
    
    init(message: String) {
        super.init(frame: CGRect.zero)
        
        let size = ToastDimension.boundingSize(message: message)
        
        self.windowLevel = UIWindowLevelAlert + 1
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        
        self.bounds = CGRect(origin: CGPoint.zero, size: size)
        self.center = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
        let rootViewController = ToastViewController(message: message)
        self.rootViewController = rootViewController
    }
    func dismiss() {
        self.isHidden = true
        self.rootViewController = nil
        self.removeFromSuperview()
    }
    override var alpha: CGFloat {
        get {
            return self.rootViewController!.view.alpha
        }
        set {
            self.rootViewController?.view.alpha = newValue
        }
    }
    override func makeKeyAndVisible() {
        oldKeyWindow = UIApplication.shared.keyWindow
        
        super.makeKeyAndVisible()
        
        self.rootViewController?.view.frame = self.bounds
        
        if let oldKeyWindow = oldKeyWindow {
            oldKeyWindow.makeKeyAndVisible()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


private class ToastViewController: UIViewController {
    
    private var message: String
    
    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 5.0
        self.view.layer.masksToBounds = true
        self.view.backgroundColor = UIColor(white: 0.7, alpha: 0.35)
        
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.layer.cornerRadius = 5.0
        effectView.layer.masksToBounds = true
        effectView.isUserInteractionEnabled = false
        view.addSubview(effectView)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[effectView(view)]",
                                                                metrics: nil,
                                                                views: ["effectView": effectView,
                                                                        "view": self.view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[effectView(view)]",
                                                                metrics: nil,
                                                                views: ["effectView": effectView,
                                                                        "view": self.view]))
        
        let label = UILabel()
        label.text = self.message
        label.textColor = UIColor(red: 102.0/255.0, green: 102.0/255.0, blue: 102.0/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: ToastDimension.FontSize)
        label.numberOfLines = 0
        label.textAlignment = .center
        effectView.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(ToastDimension.SideSpacing)-[label]-\(ToastDimension.SideSpacing)-|",
            metrics: nil,
            views: ["label": label]))
        effectView.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(ToastDimension.TopSpacing)-[label]-\(ToastDimension.TopSpacing)-|",
            metrics: nil,
            views: ["label": label]))
    }
    override var prefersStatusBarHidden: Bool {
        get {
            return UIApplication.shared.isStatusBarHidden
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return UIApplication.shared.statusBarStyle
        }
        
    }
}

public struct ToastDimension {
    
    static let SizePadding: CGFloat = 24
    
    static let DefaultHeight: CGFloat = 56
    
    static let DefaultWidth: CGFloat = 220
    
    static let MinWidth: CGFloat = 60
    
    static let MinHeight: CGFloat = 47
    
    static let MaxWidth: CGFloat = UIScreen.main.bounds.width - 32 - 40
    
    static let MaxHeight: CGFloat = 85
    
    static let SideSpacing: CGFloat = 20
    
    static let TopSpacing: CGFloat = 15
    
    static let FontSize: CGFloat = 15
    
    static func boundingSize(message: String) -> CGSize {
        var size = CGSize.zero
        
        size = message.boundingRect(with: CGSize(width: ToastDimension.MaxWidth,
                                                 height:ToastDimension.MaxHeight -  (ToastDimension.TopSpacing * 2)),
                                    options: .usesLineFragmentOrigin,
                                    attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: ToastDimension.FontSize)],
                                    context: nil).size
        
        let evaluateSize = message.boundingRect(with: CGSize(width: ToastDimension.MaxWidth * 2,
                                                             height: ToastDimension.MaxHeight - (ToastDimension.TopSpacing * 2)),
                                                options: .usesLineFragmentOrigin,
                                                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: ToastDimension.FontSize)],
                                                context: nil).size
        
        if (evaluateSize.width > ToastDimension.MaxWidth && (evaluateSize.width - ToastDimension.MaxWidth < ToastDimension.MaxWidth * 0.1)) {
            size = message.boundingRect(with: CGSize(width: ToastDimension.MaxWidth * 0.8,
                                                     height: ToastDimension.MaxHeight - (ToastDimension.TopSpacing * 2)),
                                        options: .usesLineFragmentOrigin,
                                        attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: ToastDimension.FontSize)],
                                        context: nil).size
        }
        if size.width < ToastDimension.MinWidth {
            size.width = ToastDimension.MinWidth
        }
        size.width += ToastDimension.SideSpacing * 2
        size.height += ToastDimension.TopSpacing * 2
        
        size.width = ceil(size.width)
        size.height = ceil(size.height)
        
        return size
    }
}

