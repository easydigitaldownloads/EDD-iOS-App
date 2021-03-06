//
//  LoginSubmitButton.swift
//  Easy Digital Downloads
//
//  Created by Sunny Ratilal on 25/05/2016.
//  Copyright © 2016 Easy Digital Downloads. All rights reserved.
//

import UIKit

class LoginSubmitButton: UIButton {

    var isAnimating: Bool {
        get {
            return activityIndicator.isAnimating
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override var isHighlighted: Bool {
        didSet {
            if (isHighlighted) {
                backgroundColor = .EDDBlueHighlightColor()
            } else {
                backgroundColor = .EDDBlueColor()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        addSubview(activityIndicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if activityIndicator.isAnimating {
            titleLabel?.frame = CGRect.zero
            
            var frm = activityIndicator.frame
            frm.origin.x = (frame.width - frm.width) / 2.0
            frm.origin.y = (frame.height - frm.height) / 2.0
            activityIndicator.frame = frm
        }
    }
    
    func showActivityIndicator(_ show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        setNeedsLayout()
    }

}
