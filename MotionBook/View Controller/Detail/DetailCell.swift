//
//  DetailCell.swift
//  MotionBook
//
//  Created by YiSeungyoun on 2017. 5. 1..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import Foundation
import UIKit
import FLAnimatedImage
import RealmSwift
import SDWebImage
import SafariServices
import SwiftyAttributes

let cellIdentify = "cellIdentify"

class DetailCell : UICollectionViewCell, UIScrollViewDelegate {
    static let ID = "DetailCell"
    var data: LibraryDataModel? {
        didSet{
            self.bind()
        }
    }
    var pullAction : ((_ offset : CGPoint) -> Void)?
    var bookmarkAction : ((_ selected : Bool) -> Void)?
    var settings = Settings()
    var navigationBar: UIView!
    
    var scrollView: UIScrollView!
    var containerView: UIView!
    
    var bookmarkButton: UIButton!
    var shareButton: UIButton!
    var backButton: UIButton!
    
    var gifView: FLAnimatedImageView!
    var titleLabel: UILabel!
    var exampleButton: DetailExampleButton!
    var descriptionLabel: UILabel!
    var categoryLabel: UILabel!
    var pushedLabel: UILabel!
    var githubButton: DetailGithubButton!
    var starLabel: UILabel!
    var watchLabel: UILabel!
    var forkLabel: UILabel!
    var issueLabel: UILabel!
    var cocoapodsLabel: UILabel!
    var carthageLabel: UILabel!
    var languageLabel: UILabel!
    var languageImageView: UIImageView!
    var licenseLabel: UILabel!
    
    var authorBackgroundView: UIView!
    var authorButton: UIButton!
    var authorLabel: UILabel!
    var authorImageView: UIImageView!
    var authorBio: UILabel!
    var authorAdditionalLabel: UILabel!
    
    var seperator5: UIView!
    var actIndicator: UIActivityIndicatorView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        
        self.initView()
        self.initNavigationBar()

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerView.frame.size = CGSize(width: screenWidth, height: self.authorAdditionalLabel.frame.origin.y + self.authorAdditionalLabel.frame.height + 41.5)
        self.scrollView.contentSize = self.containerView.frame.size
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView : UIScrollView){
        if scrollView.contentOffset.y < -navigationHeaderAndStatusbarHeight {
            self.popAction()
            Log.contentview(action: "scrollViewWillBeginDecelerating", location: self.parentViewController, id: data?.title)
        }
    }
    
    func backButtonClicked() {
        self.backButton.imageView!.playBounceAnimation()
        self.popAction()
        
    }
    
    func shareButtonClicked() {
        self.shareButton.imageView!.playBounceAnimation()

        self.actIndicator.startAnimating()

        guard let title = data?.title, let desciption = data?.detail, let url = data?.gifUrl, let gitUrl = data?.gitUrl else { return }
        NetworkManager.shared.deepLinkUrl(title: title, description: desciption, url: url, gitUrl: gitUrl) { (url) in
            guard let urlString = url else {
                Toast.showToast(text: "Network is not stable. Please try again later")
                self.actIndicator.stopAnimating()

                return
            }
            Log.share(name: title, location: self.parentViewController, id: title)
            let vc = UIActivityViewController(activityItems: [urlString], applicationActivities: [])
            self.parentViewController?.present(vc, animated: true)
            self.actIndicator.stopAnimating()

        }
    }
    
    func bookmarkButtonClicked() {
        if let title = data?.title {
            Log.contentview(action: "bookmarkButtonClicked", location: self.parentViewController, id: "\(title)")
            let realm = try! Realm()
            
            self.bookmarkButton.imageView!.playBounceAnimation()
            
            if self.bookmarkButton.isSelected {
                try! realm.write {
                    realm.create(LibraryDataModel.self, value: ["title": title, "favorite": false], update: true)
                }
            } else {
                try! realm.write {
                    realm.create(LibraryDataModel.self, value: ["title": title, "favorite": true], update: true)
                }
            }
            self.bookmarkButton.isSelected = !self.bookmarkButton.isSelected
            bookmarkAction?(self.bookmarkButton.isSelected)

        }
    }
    
    func exampleButtonClicked() {
        Log.addToCart(price: 0.99, action: "exampleButtonClicked", location: self.parentViewController, id: data?.title)
        
        if settings.getInappPurchased() {
            if let title = data?.title {
                if let vc = OpenSourceManager.getViewControllerWith(title: title) {
                    self.parentViewController?.navigationController?.pushViewController(vc, animated: true)
                    
                } else if let text = OpenSourceManager.getWhyNotWith(title: title) {
                    let alert = UIAlertController(title: "MotionBook", message: "This open source don't have example because of '\(text)' reason.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil))
                    self.parentViewController?.present(alert, animated: true, completion: nil)
                    alert.view.tintColor = UIColor(hexString: MainColor)
                } else {
                    Toast.showToast(text: "Not available")
                }
            }
        } else {
            let vc = PurchaseViewController()
            self.parentViewController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func githubButtonClicked() {
        if let url = data?.gitUrl, let vc = self.parentViewController {
            MBSafariViewController.show(viewController: vc, url: url, type: .push)
        } else {
            Toast.showToast(text: "Please retry again")
        }
    }
    
    func authorButtonClicked() {
        if let author = data?.author, let vc = self.parentViewController {
            MBSafariViewController.show(viewController: vc, url: "https://github.com/\(author)", type: .push)
        } else {
            Toast.showToast(text: "Please retry again")
        }
    }
    
    func popAction() {
        self.gifView.animatedImage = nil
        pullAction?(scrollView.contentOffset)

    }
    
    
    func bind() {
        let image = FLAnimatedImage(gifData: data?.gifData as Data!)
        self.gifView.animatedImage = image
        
        guard let size = image?.size else { return }
        let imageHeight = size.height*(screenWidth - 40)/size.width
        
        self.gifView.snp.remakeConstraints { (m) in
            m.left.equalTo(self.contentView).offset(20)
            m.right.equalTo(self.contentView).offset(-20)
            m.top.equalTo(self.containerView).offset(84)
            m.height.equalTo(imageHeight)
        }
        
        guard let _data = data else { return }
        let realm = try! Realm()
        
        if let title = _data.title {
            if OpenSourceManager.getViewControllerWith(title: title) != nil {
                if settings.getInappPurchased() {
                    self.exampleButton.setType(type: .normal)
                } else {
                    self.exampleButton.setType(type: .locked)
                }
                
            } else if OpenSourceManager.getWhyNotWith(title: title) != nil {
                if settings.getInappPurchased() {
                    self.exampleButton.setType(type: .explainNormal)
                } else {
                    self.exampleButton.setType(type: .explainLocked)
                }
            } else {
                self.exampleButton.setType(type: .disable)
            }

            self.titleLabel.text = title
            let getData = realm.object(ofType: LibraryDataModel.self, forPrimaryKey: (title))
            guard let _getData = getData else { return }

            if _getData.favorite {
                self.bookmarkButton.isSelected = true
            } else {
                self.bookmarkButton.isSelected = false
            }

        }
        
        if let description = _data.detail {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = 1.3
            
            let attrString = NSMutableAttributedString(string: description)
            attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
            
            self.descriptionLabel.attributedText = attrString
            self.descriptionLabel.sizeToFit()
            
        }
        
        if let type = _data.type {
            self.categoryLabel.text = type
        }
        
        self.starLabel.text = "\(DataManager.shared.convertStarCount(count: _data.gitStar))"
        self.watchLabel.text = "\(_data.subscribersCount)"
        self.forkLabel.text = "\(_data.forkCount)"
        self.issueLabel.text = "\(_data.openIssuesCount)"
        self.pushedLabel.text = DataManager.shared.converDate(date: _data.updatedDate)
        
        if let language = _data.language {
            self.languageLabel.text = language
            
            if language != "Swift" {
                self.languageImageView.image = UIImage(named:"icSupportLanguageObjc")
            }
        } else {
            self.languageLabel.text = "-"
        }
        
        if _data.cocoapodsInstall {
            self.cocoapodsLabel.text = "Compatible"
        } else {
            self.cocoapodsLabel.text = "Incompatible"
        }
        
        if _data.carthageInstall {
            self.carthageLabel.text = "Compatible"
        } else {
            self.carthageLabel.text = "Incompatible"
        }
        
        if let license = _data.license {
            self.licenseLabel.text = license
        } else {
            self.licenseLabel.text = "-"
        }
        
        
        if let author = _data.author {
            self.authorLabel.text = author
            
            let userData = realm.objects(UserModel.self).filter("user = '\(author)'")[0]
            if let avatar_url = userData.avatar_url, let url = URL(string: avatar_url) {
                self.authorImageView.sd_setImage(with: url, placeholderImage: nil, options: .refreshCached)
            }
            
            if let bio = userData.bio {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineHeightMultiple = 1.3
                
                let attrString = NSMutableAttributedString(string: bio)
                attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
                
                self.authorBio.attributedText = attrString
                self.authorBio.sizeToFit()
            }
            
            let additionalColor = UIColor(colorLiteralRed: 225/255, green: 228/255, blue: 231/255, alpha: 1)
            
            var finalString = NSMutableAttributedString()
            
            let dotString = "·  ".withAttributes([.textColor(UIColor(hexString: MainColor)), .font(UIFont.systemFont(ofSize: 15))])
            
            let organizationTextAttribute = "Organization ".withAttributes([.textColor(additionalColor), .font(UIFont.systemFont(ofSize: 12))])

            let followerTextAttribute = "Followers ".withAttributes([.textColor(additionalColor), .font(UIFont.systemFont(ofSize: 12))])
            let followerAttribute = "\(userData.followers)  ".withAttributes([.textColor(additionalColor), .font(UIFont.semiboldSystemFont(ofSize: 12))])
            
            let reposTextAttribute = "Repos ".withAttributes([.textColor(additionalColor), .font(UIFont.systemFont(ofSize: 12))])
            let reposAttribute = "\(userData.public_repos) ".withAttributes([.textColor(additionalColor), .font(UIFont.semiboldSystemFont(ofSize: 12))])
            
            guard let type = userData.type else { return }
            if type == "Organization" {
                guard let location = userData.location else { return }
                if !location.isEmpty {
                    let locationAttribute = "\(location)  ".withAttributes([.textColor(additionalColor), .font(UIFont.systemFont(ofSize: 12))])
                    finalString = locationAttribute + dotString + organizationTextAttribute + dotString + reposTextAttribute + reposAttribute
                } else {
                    finalString = organizationTextAttribute + dotString + reposTextAttribute + reposAttribute
                }
            
        } else {
                guard let location = userData.location else { return }
                if !location.isEmpty {
                    let locationAttribute = "\(location)  ".withAttributes([.textColor(additionalColor), .font(UIFont.systemFont(ofSize: 12))])
                    finalString = locationAttribute + dotString + followerTextAttribute + followerAttribute + dotString + reposTextAttribute + reposAttribute
                } else {
                    finalString = followerTextAttribute + followerAttribute + dotString + reposTextAttribute + reposAttribute
                }
            }
            
            self.authorAdditionalLabel.attributedText = finalString
        }
    }
    
    
    func initNavigationBar() {
        self.navigationBar = UIView()
        self.navigationBar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.contentView.addSubview(self.navigationBar)
        
        self.navigationBar.snp.makeConstraints { (m) in
            m.left.right.top.equalTo(self)
            m.height.equalTo(64)
        }
        
        self.backButton = UIButton()
        self.backButton.setImage(UIImage(named: "icNavbarBackNormal"), for: .normal)
        self.backButton.setImage(UIImage(named: "icNavbarBackSelected"), for: .highlighted)
        self.backButton.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        self.navigationBar.addSubview(self.backButton)
        
        self.backButton.snp.makeConstraints { (m) in
            m.left.equalTo(self.navigationBar).offset(15)
            m.bottom.equalTo(self.navigationBar)
            m.width.height.equalTo(30)
        }
        
        self.bookmarkButton = UIButton()
        self.bookmarkButton.setImage(UIImage(named: "icNavbarBookmarkNormal"), for: .normal)
        self.bookmarkButton.setImage(UIImage(named: "icNavbarBookmarkSelected"), for: .highlighted)
        self.bookmarkButton.setImage(UIImage(named: "icNavbarBookmarkSelected"), for: .selected)
        self.bookmarkButton.addTarget(self, action: #selector(bookmarkButtonClicked), for: .touchUpInside)
        self.navigationBar.addSubview(self.bookmarkButton)
        
        self.bookmarkButton.snp.makeConstraints { (m) in
            m.right.equalTo(self.navigationBar).offset(-15)
            m.bottom.equalTo(self.navigationBar)
            m.width.height.equalTo(30)
        }
        
        self.shareButton = UIButton()
        self.shareButton.setImage(UIImage(named: "icNavbarShareNormal"), for: .normal)
        self.shareButton.setImage(UIImage(named: "icNavbarSharePress"), for: .highlighted)
        self.shareButton.addTarget(self, action: #selector(shareButtonClicked), for: .touchUpInside)
        self.navigationBar.addSubview(self.shareButton)
        
        self.shareButton.snp.makeConstraints { (m) in
            m.right.equalTo(self.bookmarkButton.snp.left).offset(-15)
            m.bottom.equalTo(self.navigationBar)
            m.width.height.equalTo(30)
        }
    }
    
    func initView() {
        self.containerView = UIView()
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = self.containerView.frame.size
        self.scrollView.showsVerticalScrollIndicator = false

        self.scrollView.addSubview(self.containerView)
        self.contentView.addSubview(self.scrollView)

        self.scrollView.snp.makeConstraints { (m) in
            m.edges.equalTo(self)
        }
        
        self.gifView = FLAnimatedImageView()
        self.gifView.backgroundColor = UIColor.black
        self.gifView.contentMode = .scaleAspectFill
        self.gifView.clipsToBounds = true
        self.gifView.layer.cornerRadius = 4
        self.gifView.layer.borderWidth = 0.5
        self.gifView.layer.borderColor = UIColor(hexString: E1E4E8).cgColor
        self.containerView.addSubview(self.gifView)
        
        self.exampleButton = DetailExampleButton()
        self.exampleButton.addTarget(self, action: #selector(exampleButtonClicked), for: .touchUpInside)

        self.containerView.addSubview(self.exampleButton)
        
        self.exampleButton.snp.makeConstraints { (m) in
            m.right.equalTo(self).offset(-20)
            m.width.equalTo(80)
            m.height.equalTo(30)
            m.top.equalTo(self.gifView.snp.bottom).offset(20)
        }

        self.titleLabel = UILabel()
        self.titleLabel.font = UIFont.semiboldSystemFont(ofSize: 29)
        self.titleLabel.textColor = UIColor.init(red: 61/255, green: 69/255, blue: 77/255, alpha: 1)
        self.titleLabel.numberOfLines = 2
        self.containerView.addSubview(self.titleLabel)
        
        self.titleLabel.snp.makeConstraints { (m) in
            m.top.equalTo(self.exampleButton)
            m.right.equalTo(self.exampleButton.snp.left).offset(-15)
            m.left.equalTo(self).offset(20)
        }
        
        self.descriptionLabel = UILabel()
        self.descriptionLabel.textColor = UIColor(hexString: "5C6774")
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        self.descriptionLabel.numberOfLines = 7
        self.containerView.addSubview(self.descriptionLabel)
        
        self.descriptionLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.titleLabel)
            m.right.equalTo(self.exampleButton)
            m.top.equalTo(self.titleLabel.snp.bottom).offset(10)
        }
        
        let seperator = UIView()
        seperator.backgroundColor = UIColor(hexString: E1E4E8)
        self.containerView.addSubview(seperator)
        
        seperator.snp.makeConstraints { (m) in
            m.left.right.equalTo(self.descriptionLabel)
            m.top.equalTo(self.descriptionLabel.snp.bottom).offset(20)
            m.height.equalTo(0.5)
        }
        
        let hastTagImageView = UIImageView(image: UIImage(named: "icHashtag"))
        self.containerView.addSubview(hastTagImageView)
        
        hastTagImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(16)
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(seperator.snp.bottom).offset(20)
        }
        
        self.categoryLabel = UILabel()
        self.categoryLabel.textColor = UIColor(hexString: GrayColor)
        self.categoryLabel.font = UIFont.mediumSystemFont(ofSize: 11)
        self.containerView.addSubview(self.categoryLabel)
        
        self.categoryLabel.snp.makeConstraints { (m) in
            m.left.equalTo(hastTagImageView.snp.right).offset(2)
            m.centerY.equalTo(hastTagImageView)
        }
        
        let pushedImageView = UIImageView(image: UIImage(named: "icListUpdated"))
        self.containerView.addSubview(pushedImageView)
        
        pushedImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(16)
            m.left.equalTo(self.categoryLabel.snp.right).offset(10)
            m.centerY.equalTo(hastTagImageView)
        }
        
        self.pushedLabel = UILabel()
        self.pushedLabel.textColor = UIColor(hexString: GrayColor)
        self.pushedLabel.font = UIFont.mediumSystemFont(ofSize: 11)
        self.containerView.addSubview(self.pushedLabel)
        
        self.pushedLabel.snp.makeConstraints { (m) in
            m.left.equalTo(pushedImageView.snp.right).offset(2)
            m.centerY.equalTo(hastTagImageView)
        }
        
        self.githubButton = DetailGithubButton()
        self.githubButton.addTarget(self, action: #selector(githubButtonClicked), for: .touchUpInside)

        self.containerView.addSubview(self.githubButton)
        
        self.githubButton.snp.makeConstraints { (m) in
            m.right.equalTo(self.descriptionLabel)
            m.width.equalTo(60)
            m.height.equalTo(20)
            m.centerY.equalTo(hastTagImageView)
        }
        
        let broadSeperator = UIView()
        broadSeperator.backgroundColor = UIColor(colorLiteralRed: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        self.containerView.addSubview(broadSeperator)
        
        broadSeperator.snp.makeConstraints { (m) in
            m.left.right.equalTo(self)
            m.top.equalTo(hastTagImageView.snp.bottom).offset(20)
            m.height.equalTo(10)

        }
        
        let seperator2 = UIView()
        seperator2.backgroundColor = UIColor(hexString: E1E4E8)
        broadSeperator.addSubview(seperator2)
        
        seperator2.snp.makeConstraints { (m) in
            m.left.right.equalTo(broadSeperator)
            m.top.equalTo(broadSeperator)
            m.height.equalTo(0.5)
        }
        
        let statusLabel = UILabel()
        statusLabel.font = UIFont.semiboldSystemFont(ofSize: 12)
        statusLabel.textColor = UIColor(hexString: GrayColor)
        statusLabel.text = "STATUS"
        self.containerView.addSubview(statusLabel)
        
        statusLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(broadSeperator.snp.bottom).offset(30)
        }
        
        let dividedMargin = (((screenWidth - 40)/4) - 40)/2

        let starImageView = UIImageView(image: UIImage(named: "icStatusStar"))
        self.containerView.addSubview(starImageView)
        
        starImageView.snp.makeConstraints { (m) in
            m.top.equalTo(statusLabel.snp.bottom).offset(20)
            m.left.equalTo(self.descriptionLabel).offset(dividedMargin)
            m.width.height.equalTo(40)
        }
        
        let watchImageView = UIImageView(image: UIImage(named: "icStatusWatch"))
        self.containerView.addSubview(watchImageView)
        
        watchImageView.snp.makeConstraints { (m) in
            m.top.equalTo(statusLabel.snp.bottom).offset(20)
            m.left.equalTo(starImageView.snp.right).offset(dividedMargin*2)
            m.width.height.equalTo(40)
        }
        
        let forkImageView = UIImageView(image: UIImage(named: "icStatusFork"))
        self.containerView.addSubview(forkImageView)
        
        forkImageView.snp.makeConstraints { (m) in
            m.top.equalTo(statusLabel.snp.bottom).offset(20)
            m.left.equalTo(watchImageView.snp.right).offset(dividedMargin*2)
            m.width.height.equalTo(40)
        }
        
        let issueImageView = UIImageView(image: UIImage(named: "icStatusIssues"))
        self.containerView.addSubview(issueImageView)
        
        issueImageView.snp.makeConstraints { (m) in
            m.top.equalTo(statusLabel.snp.bottom).offset(20)
            m.left.equalTo(forkImageView.snp.right).offset(dividedMargin*2)
            m.width.height.equalTo(40)
        }

        self.starLabel = UILabel()
        self.starLabel.textColor = UIColor(hexString: MainColor)
        self.starLabel.font = UIFont.mediumSystemFont(ofSize: 14)
        self.containerView.addSubview(self.starLabel)
        
        self.starLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(starImageView)
            m.top.equalTo(starImageView.snp.bottom).offset(3)
        }
        
        self.watchLabel = UILabel()
        self.watchLabel.textColor = UIColor(hexString: TitleColor)
        self.watchLabel.font = UIFont.mediumSystemFont(ofSize: 14)
        self.containerView.addSubview(self.watchLabel)
        
        self.watchLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(watchImageView)
            m.top.equalTo(watchImageView.snp.bottom).offset(3)
        }
        
        self.forkLabel = UILabel()
        self.forkLabel.textColor = UIColor(hexString: TitleColor)
        self.forkLabel.font = UIFont.mediumSystemFont(ofSize: 14)
        self.containerView.addSubview(self.forkLabel)
        
        self.forkLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(forkImageView)
            m.top.equalTo(forkImageView.snp.bottom).offset(3)
        }

        self.issueLabel = UILabel()
        self.issueLabel.textColor = UIColor(hexString: TitleColor)
        self.issueLabel.font = UIFont.mediumSystemFont(ofSize: 14)
        self.containerView.addSubview(self.issueLabel)
        
        self.issueLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(issueImageView)
            m.top.equalTo(issueImageView.snp.bottom).offset(3)
        }
        
        let starTitleLabel = UILabel()
        starTitleLabel.text = "Star"
        starTitleLabel.textColor = UIColor(hexString: TitleColor)
        starTitleLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(starTitleLabel)
        
        starTitleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self.starLabel)
            m.top.equalTo(self.starLabel.snp.bottom).offset(2)
        }
        
        let watchTitleLabel = UILabel()
        watchTitleLabel.text = "Watch"
        watchTitleLabel.textColor = UIColor(hexString: TitleColor)
        watchTitleLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(watchTitleLabel)
        
        watchTitleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self.watchLabel)
            m.top.equalTo(self.watchLabel.snp.bottom).offset(2)
        }
        
        let forkTitleLabel = UILabel()
        forkTitleLabel.text = "Fork"
        forkTitleLabel.textColor = UIColor(hexString: TitleColor)
        forkTitleLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(forkTitleLabel)
        
        forkTitleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self.forkLabel)
            m.top.equalTo(self.forkLabel.snp.bottom).offset(2)
        }

        let issueTitleLabel = UILabel()
        issueTitleLabel.text = "Issues"
        issueTitleLabel.textColor = UIColor(hexString: TitleColor)
        issueTitleLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(issueTitleLabel)
        
        issueTitleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self.issueLabel)
            m.top.equalTo(self.issueLabel.snp.bottom).offset(2)
        }
        
        let seperator3 = UIView()
        seperator3.backgroundColor = UIColor(hexString: E1E4E8)
        self.containerView.addSubview(seperator3)
        
        seperator3.snp.makeConstraints { (m) in
            m.left.right.equalTo(self.descriptionLabel)
            m.top.equalTo(starTitleLabel.snp.bottom).offset(25)
            m.height.equalTo(0.5)
        }

        let supportLabel = UILabel()
        supportLabel.font = UIFont.semiboldSystemFont(ofSize: 12)
        supportLabel.textColor = UIColor(hexString: GrayColor)
        supportLabel.text = "SUPPORT"
        self.containerView.addSubview(supportLabel)
        
        supportLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(seperator3.snp.bottom).offset(25)
        }
        
        languageImageView = UIImageView(image: UIImage(named: "icSupportLanguageSwift"))
        self.containerView.addSubview(languageImageView)
        
        languageImageView.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(supportLabel.snp.bottom).offset(20)
        }
        
        let titleLanguageLabel = UILabel()
        titleLanguageLabel.text = "Language"
        titleLanguageLabel.textColor = UIColor(hexString: TitleColor)
        titleLanguageLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(titleLanguageLabel)
        
        titleLanguageLabel.snp.makeConstraints { (m) in
            m.left.equalTo(languageImageView.snp.right).offset(10)
            m.centerY.equalTo(languageImageView)
            m.width.equalTo(64.5)
        }
        
        self.languageLabel = UILabel()
        self.languageLabel.textColor = UIColor(hexString: TitleColor)
        self.languageLabel.font = UIFont.mediumSystemFont(ofSize: 12)
        self.containerView.addSubview(self.languageLabel)
        
        self.languageLabel.snp.makeConstraints { (m) in
            m.left.equalTo(titleLanguageLabel.snp.right).offset(20)
            m.centerY.equalTo(titleLanguageLabel)
        }
        
        let cocoapodsImageView = UIImageView(image: UIImage(named: "icSupportPods"))
        self.containerView.addSubview(cocoapodsImageView)
        
        cocoapodsImageView.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(languageImageView.snp.bottom).offset(15)
        }
        
        let titleCocoapodsLabel = UILabel()
        titleCocoapodsLabel.text = "Cocoapods"
        titleCocoapodsLabel.textColor = UIColor(hexString: TitleColor)
        titleCocoapodsLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(titleCocoapodsLabel)
        
        titleCocoapodsLabel.snp.makeConstraints { (m) in
            m.left.equalTo(cocoapodsImageView.snp.right).offset(10)
            m.centerY.equalTo(cocoapodsImageView)
        }
        
        self.cocoapodsLabel = UILabel()
        self.cocoapodsLabel.textColor = UIColor(hexString: TitleColor)
        self.cocoapodsLabel.font = UIFont.mediumSystemFont(ofSize: 12)
        self.containerView.addSubview(self.cocoapodsLabel)
        
        self.cocoapodsLabel.snp.makeConstraints { (m) in
            m.left.equalTo(languageLabel)
            m.centerY.equalTo(titleCocoapodsLabel)
        }
        
        let carthageImageView = UIImageView(image: UIImage(named: "icSupportCarthage"))
        self.containerView.addSubview(carthageImageView)
        
        carthageImageView.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(cocoapodsImageView.snp.bottom).offset(15)
        }
        
        let titleCarthageLabel = UILabel()
        titleCarthageLabel.text = "Carthage"
        titleCarthageLabel.textColor = UIColor(hexString: TitleColor)
        titleCarthageLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(titleCarthageLabel)
        
        titleCarthageLabel.snp.makeConstraints { (m) in
            m.left.equalTo(carthageImageView.snp.right).offset(10)
            m.centerY.equalTo(carthageImageView)
        }
        
        self.carthageLabel = UILabel()
        self.carthageLabel.textColor = UIColor(hexString: TitleColor)
        self.carthageLabel.font = UIFont.mediumSystemFont(ofSize: 12)
        self.containerView.addSubview(self.carthageLabel)
        
        self.carthageLabel.snp.makeConstraints { (m) in
            m.left.equalTo(languageLabel)
            m.centerY.equalTo(titleCarthageLabel)
        }

        let licenseImageView = UIImageView(image: UIImage(named: "icSupportLicense"))
        self.containerView.addSubview(licenseImageView)
        
        licenseImageView.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(carthageImageView.snp.bottom).offset(15)
        }
        
        let titleLicenseLabel = UILabel()
        titleLicenseLabel.text = "License"
        titleLicenseLabel.textColor = UIColor(hexString: TitleColor)
        titleLicenseLabel.font = UIFont.systemFont(ofSize: 12)
        self.containerView.addSubview(titleLicenseLabel)
        
        titleLicenseLabel.snp.makeConstraints { (m) in
            m.left.equalTo(licenseImageView.snp.right).offset(10)
            m.centerY.equalTo(licenseImageView)
        }
        
        self.licenseLabel = UILabel()
        self.licenseLabel.textColor = UIColor(hexString: TitleColor)
        self.licenseLabel.font = UIFont.mediumSystemFont(ofSize: 12)
        self.containerView.addSubview(self.licenseLabel)
        
        self.licenseLabel.snp.makeConstraints { (m) in
            m.left.equalTo(languageLabel)
            m.centerY.equalTo(titleLicenseLabel)
        }

        let seperator4 = UIView()
        seperator4.backgroundColor = UIColor(hexString: E1E4E8)
        self.containerView.addSubview(seperator4)
        
        seperator4.snp.makeConstraints { (m) in
            m.left.right.equalTo(self)
            m.top.equalTo(licenseImageView.snp.bottom).offset(30)
            m.height.equalTo(0.5)
        }
        
        self.authorBackgroundView = UIView()
        self.authorBackgroundView.backgroundColor = UIColor(colorLiteralRed: 61/255, green: 68/255, blue: 77/255, alpha: 1)
        self.containerView.addSubview(authorBackgroundView)
        
        let authorTitleLabel = UILabel()
        authorTitleLabel.font = UIFont.mediumSystemFont(ofSize: 12)
        authorTitleLabel.textColor = UIColor(hexString: GrayColor)
        authorTitleLabel.text = "AUTHOR"
        self.containerView.addSubview(authorTitleLabel)
        
        authorTitleLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(seperator4.snp.bottom).offset(25)
        }
        
        self.authorImageView = UIImageView()
        self.authorImageView.layer.cornerRadius = 25
        self.authorImageView.clipsToBounds = true
        self.containerView.addSubview(authorImageView)
        
        self.authorImageView.snp.makeConstraints { (m) in
            m.width.height.equalTo(50)
            m.right.equalTo(self.descriptionLabel)
            m.top.equalTo(authorTitleLabel.snp.bottom).offset(20)
        }

        
        self.authorLabel = UILabel()
        self.authorLabel.font = UIFont.mediumSystemFont(ofSize: 17)
        self.authorLabel.textColor = UIColor.white
        self.containerView.addSubview(self.authorLabel)
        
        self.authorLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.top.equalTo(self.authorImageView)
            
        }
        
        let arrowImageView = UIImageView(image: UIImage(named: "icEnterWhite"))
        self.containerView.addSubview(arrowImageView)
        
        arrowImageView.snp.makeConstraints { (m) in
            m.left.equalTo(self.authorLabel.snp.right).offset(7)
            m.centerY.equalTo(self.authorLabel)
            m.width.height.equalTo(14)
        }
        
        self.authorBio = UILabel()
        self.authorBio.font = UIFont.systemFont(ofSize: 12)
        self.authorBio.textColor = UIColor(hexString: "e1e4e7")
        self.authorBio.numberOfLines = 10
        self.containerView.addSubview(self.authorBio)
        
        self.authorBio.snp.makeConstraints { (m) in
            m.left.equalTo(self.authorLabel)
            m.top.equalTo(self.authorLabel.snp.bottom).offset(3)
            m.right.equalTo(self.authorImageView.snp.left).offset(-35)
        }
        
        self.authorButton = UIButton()
        self.authorButton.addTarget(self, action: #selector(authorButtonClicked), for: .touchUpInside)

        self.containerView.addSubview(authorButton)
        
        self.authorButton.snp.makeConstraints { (m) in
            m.left.right.equalTo(self.descriptionLabel)
            m.top.equalTo(authorImageView)
            m.bottom.equalTo(self.authorBio.snp.bottom)
        }
        
        let smallSeperator = UIView()
        smallSeperator.backgroundColor = UIColor(hexString: E1E4E8)
        self.containerView.addSubview(smallSeperator)
        
        smallSeperator.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.width.equalTo(30)
            m.height.equalTo(1)
            m.top.equalTo(self.authorBio.snp.bottom).offset(40)
        }
        
        self.authorAdditionalLabel = UILabel()
        self.containerView.addSubview(self.authorAdditionalLabel)
        
        self.authorAdditionalLabel.snp.makeConstraints { (m) in
            m.left.equalTo(self.descriptionLabel)
            m.right.equalTo(self.authorImageView.snp.right)
            m.top.equalTo(smallSeperator.snp.bottom).offset(12)
        }
        
        self.authorBackgroundView.snp.makeConstraints { (m) in
            m.left.right.equalTo(self.containerView)
            m.top.equalTo(seperator4.snp.bottom)
            m.bottom.equalTo(self.authorAdditionalLabel.snp.bottom).offset(41.5)
        }
        
        self.actIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        self.actIndicator.color = UIColor(hexString: MainColor)
        self.actIndicator.hidesWhenStopped = true
        self.addSubview(self.actIndicator)
        
        self.actIndicator.snp.makeConstraints { (m) in
            m.center.equalTo(self)
        }


    }
}
