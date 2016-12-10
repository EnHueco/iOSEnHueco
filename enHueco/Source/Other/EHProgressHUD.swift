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
    class func showSpinnerInView(_ view: UIView, title: String? = nil, animated: Bool = true) {

        MRProgressOverlayView.showOverlayAdded(to: view, title: title ?? "", mode: MRProgressOverlayViewMode.indeterminate, animated: animated).setTintColor(EHInterfaceColor.mainInterfaceColor)
    }

    class func dismissSpinnerForView(_ view: UIView, animated: Bool = true) {

        MRProgressOverlayView.dismissOverlay(for: view, animated: animated)
    }

    class func dismissAllSpinnersForView(_ view: UIView, animated: Bool = true) {

        MRProgressOverlayView.dismissAllOverlays(for: view, animated: animated)
    }
}
