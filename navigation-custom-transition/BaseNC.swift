//
//  BaseNC.swift
//  NavigationTransitions
//
//  Copyright © 2018 Chili. All rights reserved.
//

import UIKit

public class BaseNC: UINavigationController {
    public enum NavigationTransitionStyle {
        case sideBySide
    }

    private var backgroundStartOffset: CGFloat = 0
    private var scrollableBackground: UIScrollView?

    fileprivate var interactors: [NavigationInteractionProxy?] = []
    private var transitionStyle: NavigationTransitionStyle?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public init(rootViewController: UIViewController, transitionStyle: NavigationTransitionStyle? = nil) {
        super.init(rootViewController: rootViewController)
        self.transitionStyle = transitionStyle
        self.addBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        transitionStyle = .sideBySide
        super.init(coder: aDecoder)
        self.addUniversalBackground()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        self.makeNavigationBarTransparent()
    }
}

extension BaseNC: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {

        let interactor = interactors.last
        return interactor??.isPerforming == true ? (interactor as? UIViewControllerInteractiveTransitioning) : nil
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if viewController == navigationController.viewControllers.first {
            interactors.removeAll()
        }
    }

    public func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        switch operation {
        case .push:
            initializeInteractorFor(toVC)
            return pushOperationTransitionAnimator(for: toVC)
        default:
            return defaultAnimator(for: fromVC)
        }

    }

    func initializeInteractorFor(_ vc: UIViewController) {
        guard let style = transitionStyle else { return }
        switch style {
        case .sideBySide: addSideBySideInteractorFor(vc)
        }
    }

    private func addSideBySideInteractorFor(_ vc: UIViewController) {
        let interactor = SideBySidePushInteractor(attachTo: vc)
        interactor?.completion = { [weak self] in
            self?.interactors.removeLast()
        }

        interactors.append(interactor)
    }

    private func pushOperationTransitionAnimator(for vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let style = transitionStyle else { return nil }
        switch style {
        case .sideBySide: return SideBySidePushTransitionAnimator(direction: .left, navigationControl: self)
        }
    }

    private func defaultAnimator(for vc: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let style = transitionStyle else { return nil }
        switch style {
        case .sideBySide: return SideBySidePushTransitionAnimator(direction: .right, navigationControl: self)
        }
    }

    var bgMovementValue: CGFloat {
        return view.frame.width / 2
//        return 100
    }

    /// MARK: turn increase offset.x to negative for reverse scroll effect
    func increaseBackgroundOffset() {
        guard var offset = scrollableBackground?.contentOffset else { return }
        offset.x -= bgMovementValue
        scrollableBackground?.contentOffset = offset
    }

    /// MARK: turn decrease offset.x to positive for reverse scroll effect
    func decreaseBackgroundOffset() {
        guard var offset = scrollableBackground?.contentOffset else { return }
        offset.x += bgMovementValue
        scrollableBackground?.contentOffset = offset
    }

    func resetBackgroundOffset() {
        guard var offset = scrollableBackground?.contentOffset else { return }
        offset.x = backgroundStartOffset
        scrollableBackground?.contentOffset = offset
    }
}

extension BaseNC {
    func addUniversalBackground() {

        let scrollView = UIScrollView(frame: view.frame)
        let img = #imageLiteral(resourceName: "main_bg")
        let imgView = UIImageView(image: img.resizedImageWithinRect(rectSize: CGSize(width: img.size.width, height: UIScreen.main.bounds.height + 200)))

        imgView.contentMode = .center
        scrollView.addSubview(imgView)
        scrollView.isUserInteractionEnabled = false
        let offset = 0.2 * (imgView.image?.size.width ?? 0)
        backgroundStartOffset = offset
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)

        self.view.insertSubview(scrollView, at: 0)
        scrollableBackground = scrollView
    }
    
    func addBackground() {
        let leftBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.red
            return view
        }()
        
        let rightBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.white
            return view
        }()
        
        let scrollView = UIScrollView(frame: view.frame)
        
        leftBackgroundView.frame = CGRect(x: -(view.bounds.width), y: 0, width: view.bounds.width + (view.bounds.width/2), height: view.bounds.height)
        rightBackgroundView.frame = CGRect(x: view.bounds.width/2, y: 0, width: view.bounds.width + 300, height: view.bounds.height)

        scrollView.addSubview(leftBackgroundView)
        scrollView.addSubview(rightBackgroundView)
        
        scrollView.isUserInteractionEnabled = false
        let offset = 0.2 * (leftBackgroundView.frame.size.width)
        backgroundStartOffset = offset
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)

        self.view.insertSubview(scrollView, at: 0)
        scrollableBackground = scrollView
    }
}

extension UIImage {
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage? {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height

        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }

        let newSize = CGSize(width: size.width / resizeFactor, height: size.height / resizeFactor)
        let resized = scaleDown(to: newSize)
        return resized
    }

    func scaleDown(to size: CGSize) -> UIImage? {

        UIGraphicsBeginImageContextWithOptions(size, true, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension UINavigationController {
    func makeNavigationBarTransparent() {
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = true
    }
    func resetNavigationBar() {
        self.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationBar.shadowImage = nil
        self.navigationBar.isTranslucent = false
    }
}
