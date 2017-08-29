//
//  SettingViewController.swift
//  motion-book
//
//  Created by YiSeungyoun on 2017. 3. 26..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import SnapKit
import MessageUI
import StoreKit
import Pastel

// MARK: User facing alerts

class SettingView: UIView, UITableViewDelegate, UITableViewDataSource, MFMailComposeViewControllerDelegate {

    var tableView: UITableView!
    var pastelView: PastelView!
    var refreshDataAction : (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.pastelView = PastelView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 64))
        self.pastelView.animationDuration = 2.0
        self.pastelView.setColors(GradationColors)
        self.pastelView.startAnimation()
        
        self.insertSubview(pastelView, at: 0)
        
        let titleLabel = UILabel()
        titleLabel.text = "Setting"
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.semiboldSystemFont(ofSize: 15)
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { (m) in
            m.centerX.equalTo(self)
            m.centerY.equalTo(pastelView).offset(10)
        }

        self.tableView = UITableView()
        self.tableView.backgroundColor = UIColor(colorLiteralRed: 250/255, green: 250/255, blue: 250/255, alpha: 0.9)
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.register(SettingCell.self, forCellReuseIdentifier: SettingCell.ID)
        self.tableView.register(SettingHeaderCell.self, forCellReuseIdentifier: SettingHeaderCell.ID)
        self.addSubview(self.tableView)
        
        self.tableView.snp.makeConstraints { (m) in
            m.top.equalTo(pastelView.snp.bottom)
            m.left.right.bottom.equalTo(self)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingHeaderCell.ID) as! SettingHeaderCell

        switch section {
        case 0:
            cell.titleLabel.text = "MOTIONBOOK"
        case 1:
            cell.titleLabel.text = "PURCHASE"
        case 2:
            cell.titleLabel.text = "REVIEW"
        case 3:
            cell.titleLabel.text = "DATA"
        default:
            break
        }
        return cell
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return 2
        } else if section == 3 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 3 && indexPath.row == 0 {
            return 50
        }
        
        return 40
    }
    
    lazy var presentationController: IntroViewController = {
        return IntroViewController(pages: [])
    }()

    func refreshData() {
        let sevenDaysAgo = Calendar.current.date(byAdding: .day, value: -8, to: Date())
        
        let settings = Settings()
        var today = Date()
        today.addTimeInterval(-3600 * 24 * 8)
        settings.setDate(value: sevenDaysAgo!)
        
        self.parentViewController?.navigationController?.pushViewController(presentationController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch indexPath.section {
        case 0:
            // Motion Book
            if indexPath.row == 0 {
                Log.contentview(action: "Go to Github Page", location: self.parentViewController, id: nil)
                // Go to Github Page
                if let vc = self.parentViewController {
                    MBSafariViewController.show(viewController: vc, url: "https://github.com/younatics/MotionBook", type: .modal)
                }
            } else if indexPath.row == 1 {
                // Go to Facebook
                Log.contentview(action: "Go to Facebook", location: self.parentViewController, id: nil)

                if let vc = self.parentViewController {
                    MBSafariViewController.show(viewController: vc, url: "https://www.facebook.com/MotionBookiOS", type: .modal)
                }
            }
        case 1:
            // PurchaseViewController
            if indexPath.row == 0 {
                Log.contentview(action: "Go to PurchaseViewController", location: self.parentViewController, id: nil)

                let vc = PurchaseViewController()
                self.parentViewController?.present(vc, animated: true, completion: nil)
            }
        case 2:
            if indexPath.row == 0 {
                Log.contentview(action: "Go to SKStoreReviewController", location: self.parentViewController, id: nil)

                if #available(iOS 10.3, *) {
                    SKStoreReviewController.requestReview()
                } else {
                    if let url = URL(string: "https://appsto.re/kr/8yv1hb.i"),
                        UIApplication.shared.canOpenURL(url){
                        UIApplication.shared.openURL(url)
                    }
                }
            } else if indexPath.row == 1 {
                Log.contentview(action: "E-mail to Developer", location: self.parentViewController, id: nil)

                // E-mail to Developer
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["younatics@gmail.com"])
                    mail.setMessageBody("<p>To MotionBook developer</p>", isHTML: true)
                    
                    self.parentViewController?.navigationController?.present(mail, animated: true)
                } else {
                    Toast.showToast(text: "Please add your email address in Mail applicaion")
                }
            }

        case 3:
            // Data Refresh
            if indexPath.row == 0 {
                self.refreshDataAction?()
                
                Log.contentview(action: "Data Refresh", location: self.parentViewController, id: nil)

                let alert = UIAlertController(title: "MotionBook", message: "Do you want to refresh all data?", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in
                    self.refreshData()
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                
                self.parentViewController?.present(alert, animated: true, completion: nil)
                
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingCell.ID) as! SettingCell
        
        switch indexPath.section {
        case 0:
            // Motion Book
            if indexPath.row == 0 {
                cell.settingLabel.text = "Github"
                cell.bottomLine.isHidden = false
            } else if indexPath.row == 1 {
                cell.settingLabel.text = "Facebook"
            }
        case 1:
            // Donation
            if indexPath.row == 0 {
                cell.settingLabel.textColor = UIColor(hexString: MainColor)
                cell.settingLabel.text = "Unlock examples"
            } else if indexPath.row == 1 {
                cell.settingLabel.text = ""
            }
        case 2:
            if indexPath.row == 0 {
                cell.settingLabel.text = "App Store Review"
                cell.bottomLine.isHidden = false
            } else if indexPath.row == 1 {
                cell.settingLabel.text = "Email to developer"
            }

        case 3:
            if indexPath.row == 0 {
                cell.settingLabel.text = "Refresh all data"
                cell.bottomEndLine.isHidden = false
            }
            
        default:
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
        }
        
        return cell
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }


}

