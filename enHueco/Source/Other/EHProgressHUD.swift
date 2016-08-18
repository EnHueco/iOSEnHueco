//
//  EHProgressHUD.swift
//  enHueco
//
//  Created by Diego Montoya Sefair on 3/8/16.
//  Copyright © 2016 Diego Gómez. All rights reserved.
//

import UIKit
import MRProgress

class EHProgressHUD: NSObject {
    class func showSpinnerInView(view: UIView, title: String? = nil, animated: Bool = true) {

        MRProgressOverlayView.showOverlayAddedTo(view, title: title ?? "", mode: MRProgressOverlayViewMode.Indeterminate, animated: animated).setTintColor(EHInterfaceColor.mainInterfaceColor)
    }

    class func dismissSpinnerForView(view: UIView, animated: Bool = true) {

        MRProgressOverlayView.dismissOverlayForView(view, animated: animated)
    }

    class func dismissAllSpinnersForView(view: UIView, animated: Bool = true) {

        MRProgressOverlayView.dismissAllOverlaysForView(view, animated: animated)
    }
}
