//
//  SearchViewCell.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 4. 9..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import SnapKit
import FLAnimatedImage

public class SearchViewCell: UITableViewCell, YNTansitionWaterfallGridViewProtocol {
    static let ID = "SearchViewCell"
    
    let originWidth:CGFloat = 100
    let originHeight:CGFloat = 100

    var gifBackgroundView: UIView!
    var gifView: FLAnimatedImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var authorLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var starLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var bottomLine: UIView!
    
    var libData: LibraryDataModel? {
        didSet {
            self.bind()
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.titleLabel.textColor = UIColor(hexString: "5C6774")
        self.descriptionLabel.textColor = UIColor(hexString: GrayColor)
        self.categoryLabel.textColor = UIColor(hexString: GrayColor)
        self.starLabel.textColor = UIColor(hexString: GrayColor)
        
        self.gifBackgroundView = UIView()
        self.gifBackgroundView.backgroundColor = UIColor(hexString: E1E4E8)
        self.gifBackgroundView.layer.cornerRadius = 4
        self.gifBackgroundView.layer.borderWidth = 0.5
        self.gifBackgroundView.layer.borderColor = UIColor(hexString: E1E4E8).cgColor

        self.addSubview(gifBackgroundView)
        
        self.gifBackgroundView.snp.makeConstraints { (m) in
            m.left.equalTo(self).offset(20)
            m.top.equalTo(self).offset(20)
            m.width.equalTo(originWidth)
            m.height.equalTo(originHeight)
        }
        
        self.gifView = FLAnimatedImageView()
        self.gifView.contentMode = .scaleAspectFill
        self.gifView.clipsToBounds = true
        
        self.addSubview(self.gifView)
        
    }
    
    override public func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        if highlighted {
            self.backgroundColor = UIColor(hexString: "efefef")
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    func snapShotForTransition() -> UIView! {
        guard let data = libData else { return UIView() }
        let snapShotView = UIImageView(image: UIImage(data: data.pngData as Data))
        snapShotView.frame = gifView.frame
        return snapShotView
    }
    
    
    func bind() {
        if let _libData = libData, let title = _libData.title, let author = _libData.author, let detail = _libData.detail, let category = _libData.type, let mainHexcolor = _libData.mainColor {
            self.titleLabel.text = title
            self.authorLabel.text = "by. \(author)"

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.3
            
            let attrString = NSMutableAttributedString(string: detail)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))

            self.descriptionLabel.attributedText = attrString
            
            self.descriptionLabel.sizeToFit()
            self.categoryLabel.text = category
            self.dateLabel.text = DataManager.shared.converDate(date: _libData.updatedDate)
            self.starLabel.text = DataManager.shared.convertStarCount(count: _libData.gitStar)
            
            let image = FLAnimatedImage(gifData: libData?.gifData as Data!)
            self.gifView.animatedImage = image
            
            self.gifBackgroundView.backgroundColor = UIColor(hexString: mainHexcolor)
            guard let _image = image else { return }
            
            let gifWidth = _image.size.width
            let gifHeight = _image.size.height
            let originRatio = originWidth/originHeight
            let gifRatio = gifWidth/gifHeight
            
            let fixedWidth = originWidth - 1
            let fixedHeight = originHeight - 1
            
            if gifRatio > originRatio {
                let changedHeight = fixedWidth * gifHeight / gifWidth
                
                self.gifView.snp.remakeConstraints({ (m) in
                    m.center.equalTo(self.gifBackgroundView)
                    m.width.equalTo(fixedWidth)
                    m.height.equalTo(changedHeight)
                })
                
            } else {
                let changedWidth = fixedHeight * gifWidth / gifHeight
                
                self.gifView.snp.remakeConstraints({ (m) in
                    m.center.equalTo(self.gifBackgroundView)
                    m.width.equalTo(changedWidth)
                    m.height.equalTo(fixedHeight)
                })
            }
            
        }
    }
}
