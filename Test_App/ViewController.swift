//
//  ViewController.swift
//  Test_App
//
//  Created by Rani Singh on 26/03/21.
//  Copyright © 2021 InnoCric. All rights reserved.
//

import UIKit

final class TossingBehavior: UIDynamicBehavior {
    enum Direction {
        case top, left, bottom, right
    }
    
    private let snap: UISnapBehavior
    private let item: UIDynamicItem
    private var bounds: CGRect?
    
    var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                addChildBehavior(snap)
            } else {
                removeChildBehavior(snap)
            }
        }
    }
    
    init(item: UIDynamicItem, snapTo: CGPoint) {
        self.item = item
        self.snap = UISnapBehavior(item: item, snapTo: snapTo)
        
        super.init()
        
        addChildBehavior(snap)
        
        snap.action = { [weak self] in
            guard let bounds = self?.bounds, let item = self?.item else { return }
            guard let direction = self?.direction(from: item.center, in: bounds) else { return }
            guard let vector = self?.vector(from: direction) else { return }
            
            self?.isEnabled = false
            
            let gravity = UIGravityBehavior(items: [item])
            gravity.gravityDirection = vector
            gravity.magnitude = 5
            gravity.action = {
                print("Falling")
            }
            
            self?.addChildBehavior(gravity)
        }
    }
    
    // MARK: UIDynamicBehavior
    
    override func willMove(to dynamicAnimator: UIDynamicAnimator?) {
        super.willMove(to: dynamicAnimator)
        bounds = dynamicAnimator?.referenceView?.bounds
    }
    
    // MARK: Helpers
    
    private func direction(from center: CGPoint, in bounds: CGRect) -> Direction? {
        if center.x > bounds.width * 0.8 {
            return .right
        } else if center.x < bounds.width * 0.2 {
            return .left
        } else if center.y < bounds.height * 0.2 {
            return .top
        } else if center.y > bounds.height * 0.8 {
            return .bottom
        }
        
        return nil
    }
    
    private func vector(from direction: Direction) -> CGVector {
        switch direction {
        case .top:
            return CGVector(dx: 0, dy: -1)
        case .left:
            return CGVector(dx: -1, dy: 0)
        case .bottom:
            return CGVector(dx: 0, dy: 1)
        case .right:
            return CGVector(dx: 1, dy: 0)
        }
    }
}


class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var movingView: UIView!
    
    private var animator: UIDynamicAnimator!
    private var tossing: TossingBehavior!
        
    //MARK: - ViewController Life Cycle Methods
        override func viewDidLoad() {
            super.viewDidLoad()
            
            animator = UIDynamicAnimator(referenceView: view)
            tossing = TossingBehavior(item: movingView, snapTo: view.center)
            animator.addBehavior(tossing)
            
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pannedView))
            movingView.addGestureRecognizer(panGesture)
            movingView.isUserInteractionEnabled = true
        }
        
    
        @objc func pannedView(recognizer: UIPanGestureRecognizer) {
            switch recognizer.state {
            case .began:
                tossing.isEnabled = false
            case .changed:
                let translation = recognizer.translation(in: view)
                movingView.center = CGPoint(x: movingView.center.x + translation.x,
                                       y: movingView.center.y + translation.y)
                recognizer.setTranslation(.zero, in: view)
                
            case .ended, .cancelled, .failed:
                tossing.isEnabled = true
            case .possible:
                break
            }
        }
    }

