//
//  HalfPresentationController.swift
//  Campus Walk
//
//  Created by Andrew D. Sail on 10/31/16.
//
//  Copyright © 2016 Andrew Sail. All rights reserved.
//

import UIKit

class HalfPresentationController: UIPresentationController {

    override func frameOfPresentedViewInContainerView() -> CGRect {
        let width = containerView!.frame.width
        let height = containerView!.frame.height/2

        return CGRect(x: 0, y: height, width: width, height: height)
    }
}
