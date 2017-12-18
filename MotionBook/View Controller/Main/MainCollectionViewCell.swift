//
//  NTWaterfallViewCell.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import UIKit
import FLAnimatedImage
import NVActivityIndicatorView
import SnapKit

class MainCollectionViewCell :UICollectionViewCell, NTTansitionWaterfallGridViewProtocol {
    var delegate: MainDelegate?
    var gifView: FLAnimatedImageView!
    var snapShotView: UIImageView!

    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var starImageView: UIImageView!
    var starLabel: UILabel!
    
    var libData: LibraryDataModel? {
        didSet {
            bind()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initView()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gifView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height - 58)
        snapShotView.frame = gifView.frame
    }
    
    func snapShotForTransition() -> UIView! {
        guard let data = libData else { return UIView() }
        let snapShotForTransitionView = UIImageView(image: UIImage(data: data.pngData as Data))
        snapShotForTransitionView.frame = gifView.frame
        
        return snapShotForTransitionView
    }
    
    func isCell(needAnimating: Bool) {
        guard let _libData = libData else { return }
        if needAnimating {
            self.gifView.animatedImage = FLAnimatedImage(gifData: _libData.gifData as Data!)
            self.snapShotView.isHidden = true
        } else {
            self.gifView.animatedImage = nil
            self.snapShotView.image = UIImage(data: _libData.pngData as Data)
            self.snapShotView.isHidden = false
        }
    }
    
    func bind() {
        if let _libData = libData, let title = _libData.title, let author = _libData.author {
            
            self.isCell(needAnimating: false)

            self.titleLabel.text = title
            self.authorLabel.text = "by. \(author)"
            
            let font = UIFont.boldSystemFont(ofSize: 12)
            let userAttributes = [NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor: UIColor(hexString: "A6AEB7")]

            let text = DataManager.shared.convertStarCount(count: _libData.gitStar)
            self.starLabel.text = text
            let size = text.size(withAttributes: userAttributes)
            
            self.starLabel.snp.remakeConstraints({ (m) in
                m.width.equalTo(size.width+2)
                m.bottom.equalTo(self).offset(-15)
                m.right.equalTo(self)
                m.height.equalTo(14.5)
            })
            
        }
    }
    
    func initView() {
        backgroundColor = UIColor.white
        
        self.gifView = FLAnimatedImageView()
        self.gifView.layer.cornerRadius = 4
        self.gifView.layer.borderWidth = 0.5
        self.gifView.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        self.gifView.clipsToBounds = true
        contentView.addSubview(self.gifView)
        
        self.snapShotView = UIImageView()
        self.snapShotView.layer.cornerRadius = 4
        self.snapShotView.layer.borderWidth = 0.5
        self.snapShotView.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        self.snapShotView.clipsToBounds = true
        contentView.addSubview(self.snapShotView)

        self.starLabel = UILabel()
        self.starLabel.textAlignment = .right
        self.starLabel.font = UIFont.mediumSystemFont(ofSize: 12)
        self.starLabel.textColor = UIColor(hexString: GrayColor)
        contentView.addSubview(self.starLabel)

        self.starLabel.snp.makeConstraints { (m) in
            m.right.equalTo(self)
            m.bottom.equalTo(self).offset(-13)
            m.width.equalTo(30)
            m.height.equalTo(14.5)
        }
        
        self.starImageView = UIImageView()
        self.starImageView.image = UIImage(named: "icStar")
        contentView.addSubview(self.starImageView)
        
        self.starImageView.snp.makeConstraints { (m) in
            m.right.equalTo(self.starLabel.snp.left)
            m.width.height.equalTo(16)
            m.centerY.equalTo(self.starLabel)
        }
        
        self.authorLabel = UILabel()
        self.authorLabel.font = UIFont.systemFont(ofSize: 12)
        self.authorLabel.textColor = UIColor(hexString: GrayColor)
        contentView.addSubview(self.authorLabel)
        
        self.authorLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self)
            m.centerY.equalTo(self.starLabel)
            m.right.equalTo(self.starImageView.snp.left).offset(-8)
        }

        
        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.mediumSystemFont(ofSize: 14)
        self.titleLabel.textColor = UIColor(hexString: "3D444D")
        contentView.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self)
            m.right.equalTo(self)
            m.bottom.equalTo(self.authorLabel.snp.top).offset(-1)
        }
    }
}
