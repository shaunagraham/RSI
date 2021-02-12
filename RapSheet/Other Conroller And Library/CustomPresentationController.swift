//
//  CustomPresentationController.swift
//  RapSheet
//

import Foundation
import UIKit

enum Direction {
    case left, right, up, down
    
    var pointVector: CGPoint {
        switch self {
        case .left: return CGPoint(x: -1, y: 0)
        case .right: return CGPoint(x: 1, y: 0)
        case .up: return CGPoint(x: 0, y: -1)
        case .down: return CGPoint(x: 0, y: 1)
        }
    }
}

class CustomPresentationController: UIPresentationController, UIViewControllerTransitioningDelegate {
    
    var dismissInteractionController: PanGestureInteractionController? = nil
    var interactiveDismissal: Bool = false
    let coverDirection: Direction
    
    public var margin: CGFloat = 64.0
    
    lazy private var backgroundView: UIView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.frame = self.containerView?.bounds ?? CGRect()
        view.backgroundColor = nil
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundViewTapped))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }()
    
    init(presentedViewController: UIViewController, presenting: UIViewController?, coverDirection: Direction) {
        self.coverDirection = coverDirection
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.addSubview(backgroundView)
        backgroundView.alpha = 0
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.backgroundView.alpha = 1
            }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentingViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] _ in
            self?.backgroundView.alpha = 0
            }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            backgroundView.removeFromSuperview()
        }
        
        dismissInteractionController = PanGestureInteractionController(view: containerView!, direction: coverDirection)
        dismissInteractionController?.callbacks.didBeginPanning = { [weak self] in
            self?.interactiveDismissal = true
            self?.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        interactiveDismissal = false
        if completed {
            backgroundView.removeFromSuperview()
        }
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        presentedView?.layer.masksToBounds = true
        presentedView?.layer.cornerRadius = 15
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect()
        }
        
        switch coverDirection {
        case .left:
            return CGRect(x: 0, y: 0, width: containerView.bounds.width-margin, height: containerView.bounds.height)
        case .right:
            return CGRect(x: margin, y: 0, width: containerView.bounds.width-margin, height: containerView.bounds.height)
        case .up:
            return CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height-margin)
        case .down:
            return CGRect(x: 0, y: margin, width: containerView.bounds.width, height: containerView.bounds.height-margin)
        }
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveDismissal ? dismissInteractionController : nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInTransition(fromDirection: coverDirection)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInTransition(fromDirection: coverDirection, reverse: true, interactive: interactiveDismissal)
    }
    
    @objc func backgroundViewTapped() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

class CoverPartiallySegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {
    
    var coverDirection: Direction = .left
    var presentationController: CustomPresentationController! = nil
    
    override func perform() {
        destination.modalPresentationStyle = .custom
        destination.transitioningDelegate = self
        super.perform()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let presenting = presenting else { return nil }
        presentationController = CustomPresentationController(
            presentedViewController: presented, presenting: presenting, coverDirection: coverDirection)
        return presentationController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return presentationController.interactiveDismissal ? presentationController.dismissInteractionController : nil
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInTransition(fromDirection: coverDirection)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInTransition(fromDirection: coverDirection, reverse: true, interactive: presentationController.interactiveDismissal)
    }
}

class PanGestureInteractionController: UIPercentDrivenInteractiveTransition {
    struct Callbacks {
        var didBeginPanning: (() -> Void)? = nil
    }
    var callbacks = Callbacks()
    
    let gestureRecognizer: UIPanGestureRecognizer
    
    private let direction: Direction
    
    // MARK: Initialization
    init(view: UIView, direction: Direction) {
        self.direction = direction
        gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        
        super.init()
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(viewPanned(sender:)))
    }
    
    // MARK: User interaction
    @objc func viewPanned(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            callbacks.didBeginPanning?()
        case .changed:
            update(percentCompleteForTranslation(translation: sender.translation(in: sender.view)))
        case .ended:
            if sender.shouldRecognizeForDirection(direction: direction) && percentComplete > 0.25 {
                finish()
            } else {
                cancel()
            }
        case .cancelled:
            cancel()
        default:
            return
        }
    }
    
    private func percentCompleteForTranslation(translation: CGPoint) -> CGFloat {
        let panDistance = direction.panDistanceForView(view: gestureRecognizer.view!)
        return (translation * panDistance) / (panDistance.magnitude * panDistance.magnitude)
    }
}

extension PanGestureInteractionController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return false
        }
        return panGestureRecognizer.shouldRecognizeForDirection(direction: direction)
    }
}

private extension Direction {
    func panDistanceForView(view: UIView) -> CGPoint {
        switch self {
        case .left: return CGPoint(x: -view.bounds.size.width, y: 0)
        case .right: return CGPoint(x: view.bounds.size.width, y: 0)
        case .up: return CGPoint(x: 0, y: -view.bounds.size.height)
        case .down: return CGPoint(x: 0, y: view.bounds.size.height)
        }
    }
}

class SlideInTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let duration: TimeInterval = 0.5
    let reverse: Bool
    let interactive: Bool
    let fromDirection: Direction
    
    init(fromDirection: Direction, reverse: Bool = false, interactive: Bool = false) {
        self.reverse = reverse
        self.interactive = interactive
        self.fromDirection = fromDirection
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let viewControllerKey = reverse ? UITransitionContextViewControllerKey.from : UITransitionContextViewControllerKey.to
        let viewControllerToAnimate = transitionContext.viewController(forKey: viewControllerKey)!
        guard let viewToAnimate = viewControllerToAnimate.view else { return }
        
        let offsetFrame = fromDirection.offsetFrameForView(view: viewToAnimate, containerView: transitionContext.containerView)
        
        if !reverse {
            transitionContext.containerView.addSubview(viewToAnimate)
            viewToAnimate.frame = offsetFrame
        }
        
        let options: UIView.AnimationOptions = interactive ? [.curveLinear] : []
        
        UIView.animate(withDuration: duration, delay: 0, options: options,
                       animations: { [weak self] in
                        if self!.reverse {
                            viewToAnimate.frame = offsetFrame
                        } else {
                            viewToAnimate.frame = transitionContext.finalFrame(for: viewControllerToAnimate)
                        }
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
}

private extension Direction {
    func offsetFrameForView(view: UIView, containerView: UIView) -> CGRect {
        var frame = view.bounds
        switch self {
        case .left:
            frame.origin.x = -frame.width
            frame.origin.y = 0
        case .right:
            frame.origin.x = containerView.bounds.width
            frame.origin.y = 0
        case .up:
            frame.origin.x = 0
            frame.origin.y = -frame.height
        case .down:
            frame.origin.x = 0
            frame.origin.y = containerView.bounds.height
        }
        return frame
    }
}

extension UIPanGestureRecognizer {
    func shouldRecognizeForDirection(direction: Direction) -> Bool {
        guard let view = view else {
            return false
        }
        
        let vel = velocity(in: view)
        let a = angle(vel, direction.pointVector)
        return abs(a) < CGFloat.pi / 4 // Angle should be within 45 degrees
    }
}

func angle(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
    // TODO | - Not sure if this is correct
    return atan2(a.y, a.x) - atan2(b.y, b.x)
}

extension CGPoint {
    
    static func * (left: CGPoint, right: CGPoint) -> CGFloat {
        return left.x * right.x + left.y * right.y
    }
    
    /**
     * Returns the length (magnitude) of the vector described by the CGPoint.
     */
    public var magnitude: CGFloat {
        return sqrt(lengthSquare)
    }
    
    /**
     * Returns the squared length of the vector described by the CGPoint.
     */
    public var lengthSquare: CGFloat {
        return x * x + y * y
    }
}
