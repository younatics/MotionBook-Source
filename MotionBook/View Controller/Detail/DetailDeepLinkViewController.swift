//
//  DetailDeepLinkViewController.swift
//  MotionBook
//
//  Created by Seungyoun Yi on 2017. 6. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit

class DetailDeepLinkViewController: UIViewController {
    var data: LibraryDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let detailCell = DetailCell(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight))
        detailCell.pullAction = { offset in
            self.dismiss(animated: true, completion: nil)
        }

        detailCell.data = data
        detailCell.backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        self.view = detailCell
        self.view.layoutIfNeeded()
    }
    
    func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}
