//
//  VYAlertController.swift
//  VYAlertController
//
//  Created by Vladyslav Yakovlev on 9/28/18.
//  Copyright © 2018 Vladyslav Yakovlev. All rights reserved.
//

import UIKit

extension VYAlertController {
    
    public enum Style {
        
        case actionSheet
        
        case alert
    }
}

public final class VYAlertController: UIViewController {
    
    public let message: String?

    public let style: VYAlertController.Style
    
    public private(set) var actions = [VYAlertAction]()
    
    public private(set) var textFields: [UITextField]?
    
    
    public var messageFont = UIFont.systemFont(ofSize: 19)
    
    public var actionTitleFont = UIFont.systemFont(ofSize: 19)
    
    
    public var separatorColor = UIColor(r: 245, g: 245, b: 245)
    
    public var actionBackgroundColor = UIColor.white
    
    public var messageBackgroundColor = UIColor.white
    
    public var messageColor = UIColor.black
    
    public var actionTitleColor = UIColor.black
    
    
    public var presentAnimationDuration: Double?
    
    public var dismissAnimationDuration: Double?
    
    
    public var cornerRadius: CGFloat = 12
    
    public var roundCorners: UIRectCorner = []
    
    public var separatorWidth: CGFloat = 2
    
    public var actionCellHeight: CGFloat = 60
    
    public var textFieldHeight: CGFloat = 34
    
    public var messageLineSpacing: CGFloat = 6
    
    public var allowEmptyTextField = true
    
    
    private var window: UIWindow?
    
    private let messageViewReuseId = "messageView"
    
    private var hasMessage: Bool {
        return message != nil && !message!.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var hasTextField: Bool {
        return textFields != nil && !textFields!.isEmpty
    }
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    public init(message: String? = nil, style: VYAlertController.Style) {
        self.message = message
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(white: 0, alpha: 0)
        
        view.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ActionCell.self, forCellWithReuseIdentifier: ActionCell.reuseId)
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: messageViewReuseId)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }
        
        if hasMessage {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = messageLineSpacing
            let attributes = [NSAttributedString.Key.font : messageFont,
                              NSAttributedString.Key.foregroundColor : messageColor,
                              NSAttributedString.Key.paragraphStyle : paragraphStyle]
            let attributedText = NSAttributedString(string: message!, attributes: attributes)
            messageLabel.attributedText = attributedText
        }
        
        if hasTextField {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        }
    }
    
    private func layoutViews() {
        let alertWidth = style == .alert ? view.frame.width - 50 : view.frame.width
        let messageHorizontalInset: CGFloat = 20
        let messageVerticalInset: CGFloat = currentDevice == .iPhone5 ? 28 : 32
        let textFieldHorizontalInset: CGFloat = 24
        
        var messageViewHeight: CGFloat = 0
        messageViewHeight += messageVerticalInset
        
        if hasMessage {
            let messageSize = messageLabel.sizeThatFits(CGSize(width: alertWidth - 2*messageHorizontalInset, height: CGFloat.greatestFiniteMagnitude))
            messageLabel.frame.size = messageSize
            messageLabel.frame.origin.y = messageVerticalInset
            messageLabel.center.x = alertWidth/2
            messageViewHeight += messageSize.height + messageVerticalInset
        }
        
        if hasTextField {
            for textField in textFields! {
                textField.frame.size = CGSize(width: alertWidth - 2*textFieldHorizontalInset, height: textFieldHeight)
                textField.center.x = alertWidth/2
                textField.frame.origin.y = messageViewHeight
                messageViewHeight += textField.frame.height + messageVerticalInset
            }
        }
        
        if !hasMessage, !hasTextField {
            messageViewHeight = 0
        }
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        
        if messageViewHeight != 0 {
            layout.headerReferenceSize = CGSize(width: alertWidth, height: messageViewHeight)
            layout.sectionInset.top = separatorWidth
        }
        
        if style == .alert, actions.count == 2 {
            layout.minimumInteritemSpacing = separatorWidth
            layout.itemSize = CGSize(width: (alertWidth - separatorWidth)/2, height: actionCellHeight)
        } else {
            layout.minimumLineSpacing = separatorWidth
            layout.itemSize = CGSize(width: alertWidth, height: actionCellHeight)
        }
        
        if separatorWidth == 0 {
            if !hasMessage, !hasTextField {
                layout.sectionInset.top = actionCellHeight/6
            }
            layout.sectionInset.bottom = actionCellHeight/6
            collectionView.backgroundColor = actionBackgroundColor
        } else {
            collectionView.backgroundColor = separatorColor
        }
        
        let contentHeight = calculateContentHeight()
        
        collectionView.frame.size.height = contentHeight
        collectionView.frame.origin.y = view.frame.height
        collectionView.frame.size.width = alertWidth
        collectionView.center.x = view.center.x
        
        if style == .alert, hasTextField {
            textFields!.first!.becomeFirstResponder()
        } else {
            let maxHeight = style == .alert ? 8*view.frame.height/10 : 9*view.frame.height/10
            setupAlertHeight(contentHeight: contentHeight, maxHeight: maxHeight)
            roundAlertCorners()
            
            if style == .alert {
                UIView.animate(0.24) {
                    self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
                }
                UIView.animate(presentAnimationDuration ?? 0.42, damping: 0.82, velocity: 0.78) {
                    self.collectionView.center = self.view.center
                }
            } else {
                UIView.animate(0.2) {
                    self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
                }
                UIView.animate(presentAnimationDuration ?? 0.42, damping: 0.78, velocity: 0.78) {
                    self.collectionView.frame.origin.y -= self.collectionView.frame.height
                }
            }
        }
    }
    
    private func calculateContentHeight() -> CGFloat {
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let height: CGFloat
        if style == .alert, actions.count == 2 {
            height = layout.itemSize.height
        } else {
            height = layout.itemSize.height*CGFloat(actions.count) + layout.minimumLineSpacing*CGFloat(actions.count - 1)
        }
        return height + layout.sectionInset.top + layout.sectionInset.bottom + layout.headerReferenceSize.height
    }
    
    private func roundAlertCorners() {
        if cornerRadius != 0 {
            if roundCorners.isEmpty {
                roundCorners = style == .alert ? [.allCorners] : [.topRight, .topLeft]
            }
            collectionView.roundCorners(corners: roundCorners, radius: cornerRadius)
        }
    }
    
    private func setupAlertHeight(contentHeight: CGFloat, maxHeight: CGFloat) {
        if contentHeight > maxHeight {
            collectionView.frame.size.height = maxHeight
            collectionView.isScrollEnabled = true
            
            let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
            let messageViewHeight = layout.headerReferenceSize.height
            
            if messageViewHeight < collectionView.frame.height/3 {
                layout.sectionHeadersPinToVisibleBounds = true
            }
        } else {
            collectionView.frame.size.height = contentHeight
            collectionView.isScrollEnabled = false
        }
    }
    
    @objc private func keyboardWillChangeFrame(notification: Notification) {
        let frame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue!
        if frame.origin.y == view.frame.height { return }
        let contentHeight = collectionView.collectionViewLayout.collectionViewContentSize.height
        let keyboardInset: CGFloat = 40
        let maxHeight = frame.origin.y - keyboardInset - (currentDevice == .iPhoneX ? 48 : 40)

        setupAlertHeight(contentHeight: contentHeight, maxHeight: maxHeight)
        roundAlertCorners()
        
        UIView.animate(0.24) {
            self.view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        }
        UIView.animate(presentAnimationDuration ?? 0.48, damping: 0.8, velocity: 0.8) {
            self.collectionView.frame.origin.y = frame.origin.y - keyboardInset - self.collectionView.frame.height
        }
    }
    
    public func addAction(_ action: VYAlertAction) {
        actions.append(action)
    }
    
    public func addTextField(configurationHandler: ((UITextField) -> ())? = nil) {
        if style == .actionSheet {
            fatalError("ActionSheet cannot include text field.")
        }
        if textFields == nil {
            textFields = []
        }
        let textField = UITextField()
        if let handler = configurationHandler {
            handler(textField)
        } else {
           addDefaultConfiguration(to: textField)
        }
        textFields?.append(textField)
    }
    
    public func present() {
        if actions.isEmpty {
            fatalError("AlertController must include at least one action.")
        }
        let cancelActions = actions.filter {
            $0.style == .cancel
        }
        if cancelActions.count > 1 {
            fatalError("AlertController can only have one cancel action.")
        }
        window = UIWindow()
        window!.rootViewController = self
        window!.backgroundColor = .clear
        window!.windowLevel = .alert
        window!.makeKeyAndVisible()
        if cancelActions.count == 1 {
            if actions.count > 1 {
                let cancelAction = cancelActions.first!
                let actionIndex = actions.firstIndex {
                    $0.style == .cancel
                }
                actions.remove(at: actionIndex!)
                actions.append(cancelAction)
            }
            if style == .actionSheet {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapCancelAction))
                tapGesture.delegate = self
                view.addGestureRecognizer(tapGesture)
            }
        }
    }
    
    @objc private func dismiss() {
        let duration: Double
        if style == .alert {
            duration = hasTextField ? 0.5 : (currentDevice == .iPhone5 ? 0.42 : 0.46)
        } else {
            duration = 0.38
        }

        UIView.animate(dismissAnimationDuration ?? duration, damping: 1, velocity: 0.8, animation: {
            self.collectionView.frame.origin.y = self.view.frame.height
            self.view.backgroundColor = UIColor(white: 0, alpha: 0)
            if self.hasTextField { self.view.endEditing(true) }
        }, completion: { _ in
            self.window = nil
        })
    }
    
    private func addDefaultConfiguration(to textField: UITextField) {
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearButtonMode = .never
        textField.borderStyle = .roundedRect
        textField.textAlignment = .left
    }
    
    @objc private func tapCancelAction() {
        let cancelAction = actions.first {
            $0.style == .cancel
        }
        cancelAction!.handler?(cancelAction!)
        dismiss()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension VYAlertController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActionCell.reuseId, for: indexPath) as! ActionCell
        let action = actions[indexPath.item]
        cell.setupTitle(action.title)
        cell.setupTitleFont(actionTitleFont)
        cell.backgroundColor = actionBackgroundColor
        cell.setupTitleColor(action.style == .destructive ? .red : actionTitleColor)
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: messageViewReuseId, for: indexPath)
        view.backgroundColor = messageBackgroundColor
        if hasMessage {
            view.addSubview(messageLabel)
        }
        if hasTextField {
            for textField in textFields! {
                view.addSubview(textField)
            }
        }
        return view
    }
}

extension VYAlertController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let action = actions[indexPath.item]
        if hasTextField, !allowEmptyTextField, action.style != .cancel {
            for textField in textFields! {
                if textField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                    return
                }
            }
        }
        action.handler?(action)
        dismiss()
    }
}

extension VYAlertController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == view
    }
}
