//
//  BubbleTransitions.swift
//  Wellness-iOS
//
//  Created by Gohar on 13/02/2019.
//  Copyright © 2019 Wellness. All rights reserved.
//

import UIKit

public enum TransitionMode: Int {
    case Present
    case Dismiss
}

open class BubbleTransition: NSObject {
    
    open var startingPoint = CGPoint.zero {
        didSet {
            bubble.center = startingPoint
        }
    }
    open var startingSecondPoint = CGPoint.zero {
        didSet {
            secondBubble.center = startingSecondPoint
        }
    }
    open var duration = 3.0
    open var transitionMode: BubbleTransitionMode = .present
    open var bubbleColor: UIColor = .white
    open fileprivate(set) var bubble = UIView()
    open fileprivate(set) var secondBubble = UIView()
    public enum BubbleTransitionMode: Int {
        case present, dismiss, pop
    }
}

public enum BubbleInteractiveTransitionSwipeDirection: CGFloat {
    case up = -1
    case down = 1
}

open class BubbleInteractiveTransition: UIPercentDrivenInteractiveTransition {
    fileprivate var interactionStarted = false
    fileprivate var interactionShouldFinish = false
    fileprivate var controller: UIViewController?
    open var interactionThreshold: CGFloat = 0.3
    open var swipeDirection: BubbleInteractiveTransitionSwipeDirection = .down
    open func attach(to: UIViewController) {
        controller = to
        controller?.view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(BubbleInteractiveTransition.handlePan(gesture:))))
        if #available(iOS 10.0, *) {
            wantsInteractiveStart = false
        }
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        guard let controller = controller, let view = controller.view else { return }
        
        let translation = gesture.translation(in: controller.view.superview)
        
        let delta = swipeDirection.rawValue * (translation.y / view.bounds.height)
        let movement = fmaxf(Float(delta), 0.0)
        let percent = fminf(movement, 1.0)
        let progress = CGFloat(percent)
        
        switch gesture.state {
        case .began:
            interactionStarted = true
            controller.dismiss(animated: true, completion: nil)
        case .changed:
            interactionShouldFinish = progress > interactionThreshold
            update(progress)
        case .cancelled:
            interactionShouldFinish = false
            fallthrough
        case .ended:
            interactionStarted = false
            interactionShouldFinish ? finish() : cancel()
        default:
            break
        }
    }
}

extension BubbleTransition: UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        bubble = UIView()
        bubble.center = startingPoint
        secondBubble = UIView()
        secondBubble.center = startingSecondPoint
        let fromViewController = transitionContext.viewController(forKey: .from)
        let toViewController = transitionContext.viewController(forKey: .to)
        
        fromViewController?.beginAppearanceTransition(false, animated: true)
        if toViewController?.modalPresentationStyle == .custom {
            toViewController?.beginAppearanceTransition(true, animated: true)
        }
        let presentedControllerView = transitionContext.view(forKey: .to)!
        let originalCenter = presentedControllerView.center
        let originalSize = presentedControllerView.frame.size
        
        UIView.animate(withDuration: duration, delay: 0, options: [], animations: {
            self.bubble.frame = self.frameForBubble(originalCenter, size: originalSize, start: self.startingPoint)
            self.bubble.layer.cornerRadius = self.bubble.frame.size.height / 2
            self.bubble.center = self.startingPoint
            self.bubble.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.bubble.transform = CGAffineTransform.identity
            self.bubble.backgroundColor = self.bubbleColor
            containerView.addSubview(self.bubble)
        })
        
        UIView.animate(withDuration: duration, delay: 0.15, options: [], animations: {
            self.secondBubble.frame = self.frameForBubble(self.startingSecondPoint, size: originalSize, start: self.startingSecondPoint)
            self.secondBubble.layer.cornerRadius = self.secondBubble.frame.size.height / 2
            self.secondBubble.center = self.startingSecondPoint
            self.secondBubble.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.secondBubble.transform = CGAffineTransform.identity
            //self.secondBubble.backgroundColor = .white
            self.secondBubble.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            containerView.addSubview(self.secondBubble)
        })
        
        containerView.addSubview(presentedControllerView)
        presentedControllerView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        UIView.animate(withDuration: 0.3, delay: 0.6, options: [], animations: {
            presentedControllerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        }, completion: { _ in
            self.bubble.removeFromSuperview()
            self.secondBubble.removeFromSuperview()
            transitionContext.completeTransition(true)
            if toViewController?.modalPresentationStyle == .custom {
                toViewController?.endAppearanceTransition()
            }
            fromViewController?.endAppearanceTransition()
        })
    }
}

private extension BubbleTransition {
    func frameForBubble(_ originalCenter: CGPoint, size originalSize: CGSize, start: CGPoint) -> CGRect {
        let lengthX = fmax(start.x, originalSize.width - start.x)
        let lengthY = fmax(start.y, originalSize.height - start.y)
        let offset = sqrt(lengthX * lengthX + lengthY * lengthY) * 2
        let size = CGSize(width: offset, height: offset)
        
        return CGRect(origin: CGPoint.zero, size: size)
    }
}
