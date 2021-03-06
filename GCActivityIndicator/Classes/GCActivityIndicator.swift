//
//  GCActivityIndicator.swift
//  GCActivityIndicator
//
//  Created by Graham Chance on 7/29/18.
//  Copyright © 2018 Graham Chance. All rights reserved.
//

import Foundation
import UIKit

/// Models a view with some number of activity indicator rings.
public class GCActivityIndicator: UIView {

    /// Whether the view should hide when animation stops.
    public var hidesWhenStopped: Bool = true

    /// Whether the view is currently animating.
    public private(set) var isAnimating: Bool = false

    /// The ActivityRings belonging to the view.
    public var rings: [ActivityRing] = [] {
        didSet {
            configureRings()
        }
    }


    /// Required constructor
    ///
    /// - Parameter aDecoder: An unarchiver object.
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureView()
    }


    /// Construct with a frame
    ///
    /// - Parameter frame: Frame to assign to the view.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    /// Stops all animation of ActivityRings.
    public func stopAnimating() {
        isAnimating = false
        isHidden = hidesWhenStopped
        ringLayers.forEach {
            $0.currentAnimation = nil
        }
    }

    /// Starts animating all ActivityRings.
    public func startAnimating() {
        isAnimating = true
        isHidden = false
        addAnimations()
    }

    private func configureView() {
        backgroundColor = UIColor.clear
        configureRings()
    }

    private var ringLayers: [ActivityRingLayer] {
        return (layer.sublayers ?? []).compactMap {
            return $0 as? ActivityRingLayer
        }
    }

    private func configureRings() {
        removeAllRings()
        addRingLayers()
    }

    private func addAnimations() {
        ringLayers.forEach {
            $0.startAnimating()
        }
    }

    private func removeAllRings() {
        ringLayers.forEach {
            $0.removeFromSuperlayer()
        }
    }

    private func addRingLayers() {
        let radii = calculateRadii()
        for i in 0..<rings.count {
            let ring = rings[i]
            let ringLayer = ActivityRingLayer(frame: bounds, ring: ring, radius: radii[i])
            layer.addSublayer(ringLayer)
        }
    }

    private func calculateRadii() -> [CGFloat] {
        var radii = [CGFloat]()
        let maxDiameter = min(bounds.width, bounds.height)
        let maxRadius = maxDiameter / 2
        for i in 0..<rings.count {
            let ring = rings[i]
            let radius: CGFloat
            if i == 0 {
                radius = maxRadius - ring.lineWidth * maxRadius
            } else if rings[i].overlaps {
                radius = radii[i-1] - (ring.lineWidth - rings[i-1].lineWidth) * maxRadius
            } else {
                radius = radii[i-1]
                    - (rings[i-1].lineWidth * maxDiameter) / 2
                    - (ring.lineWidth * maxDiameter) / 2
            }
            radii.append(radius)
        }
        return radii
    }

}
