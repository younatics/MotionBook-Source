//
//  IntroViewController.swift
//  MotionBook
//
//  Created by Seungyoun Yi on 2017. 5. 25..
//  Copyright © 2017년 SeungyounYi. All rights reserved.
//

import UIKit
import Hue
import Presentation
import RealmSwift
import FLAnimatedImage
import SnapKit
import Pastel
import LTMorphingLabel

class IntroViewController: PresentationController {
    struct BackgroundImage {
        let name: String
        let left: CGFloat
        let top: CGFloat
        let speed: CGFloat
        
        init(name: String, left: CGFloat, top: CGFloat, speed: CGFloat) {
            self.name = name
            self.left = left
            self.top = top
            self.speed = speed
        }
        
        func positionAt(_ index: Int) -> Position? {
            var position: Position?
            
            if index == 0 || speed != 0.0 {
                let currentLeft = left + CGFloat(index) * speed
                position = Position(left: currentLeft, top: top)
            }
            
            return position
        }
    }
    var firstDownload = false

    var window: UIWindow!
    var progressView: UIView!
    var progressLabel: LTMorphingLabel!
    var progressBubble: UIImageView!
    var progressBar: UIView!
    var startButton: UIButton!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationTitle = false
        configureSlides()
        configureBackground()
        
        self.initProgressView()
        self.loadData()

        let pastelView = PastelView(frame: view.bounds)
        pastelView.animationDuration = 2.0
        pastelView.setColors(GradationColors)
        pastelView.startAnimation()
        view.insertSubview(pastelView, at: 0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setViewControllers([self], animated: false)

    }
    
    // MARK: - Configuration
    func configureSlides() {
        let ratio: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0.6
        let font = UIFont(name: "HelveticaNeue", size: 34.0 * ratio)!
        let color = UIColor(hexString: "FFE8A9")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        let attributes = [NSFontAttributeName: font, NSForegroundColorAttributeName: color,
                          NSParagraphStyleAttributeName: paragraphStyle]
        
        let titles = [
        "",
        "",
        "",
        ""].map { title -> Content in
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: 550 * ratio, height: 200 * ratio))
                label.numberOfLines = 4
                label.attributedText = NSAttributedString(string: title, attributes: attributes)
                let position = Position(left: 0.7, top: 0.35)
                
                return Content(view: label, position: position)
        }
        
        var slides = [SlideController]()
        
        for index in 0...3 {
            let controller = SlideController(contents: [titles[index]])
            controller.add(animations: [Content.centerTransition(forSlideContent: titles[index])])
            
            slides.append(controller)
        }
        
        add(slides)
    }
    
    func configureBackground() {
        var contents = [Content]()
        
        let backgroundImages = [
            BackgroundImage(name: "person1", left: -0.6, top: 0.73, speed: 0.2),
            BackgroundImage(name: "person2", left: 1.1, top: 0.45, speed: -0.23),
            BackgroundImage(name: "tea1", left: 0.1, top: 0.627, speed: 0.04),
            BackgroundImage(name: "tea2", left: 0.58, top: 0.51, speed: 0.35),
            BackgroundImage(name: "tea3", left: 0.75, top: 0.6, speed: 0.0),
            BackgroundImage(name: "chat1", left: 0.0, top: 0.05, speed: -1.0),
            BackgroundImage(name: "chat2", left: 1.0, top: 0.05, speed: -1.0),
            BackgroundImage(name: "chat3", left: 2.0, top: 0.05, speed: -1.0),
            BackgroundImage(name: "chat4", left: 3.0, top: 0.05, speed: -1.0),
            BackgroundImage(name: "table", left: 0.0, top: 0.5, speed: 0.0)
        ]
        
        for backgroundImage in backgroundImages {
            let imageView = UIImageView()
            guard let image = UIImage(named: backgroundImage.name) else { return }
            imageView.image = image
            
            if backgroundImage.name == "chat1" || backgroundImage.name == "chat2" || backgroundImage.name == "chat3" || backgroundImage.name == "chat4" || backgroundImage.name == "table" {
                let imageheight = screenWidth / image.size.width * image.size.height
                imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: imageheight)
            } else {
                imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            }
            if let position = backgroundImage.positionAt(0) {
                contents.append(Content(view: imageView, position: position, centered: false))
            }
        }
        
        addToBackground(contents)
        
        for row in 1...4 {
            for (column, backgroundImage) in backgroundImages.enumerated() {
                if let position = backgroundImage.positionAt(row), let content = contents.at(column) {
                    addAnimation(TransitionAnimation(content: content, destination: position,
                                                     duration: 2.0, damping: 1.0), forPage: row)
                }
            }
        }
        
    }
}

extension IntroViewController {
    func initProgressView() {
        window = UIApplication.shared.keyWindow
        
        self.startButton = UIButton(frame: CGRect(x: 0, y: screenHeight - 49, width: screenWidth, height: 49))
        self.startButton.backgroundColor = UIColor.black.withAlphaComponent(0.1)
        self.startButton.titleLabel?.font = UIFont.mediumSystemFont(ofSize: 13)
        self.startButton.setTitle("START", for: .normal)
        self.startButton.setTitleColor(UIColor.white, for: .normal)
        self.startButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .highlighted)
        self.startButton.isHidden = true
        self.startButton.addTarget(self, action: #selector(startButtonClicked), for: .touchUpInside)
        window?.addSubview(self.startButton)

        self.progressView = UIView(frame: CGRect(x: 0, y: 0 , width: screenWidth, height: 4))
        self.progressView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        window?.addSubview(self.progressView)
        
        self.progressBar = UIView()
        self.progressBar.backgroundColor = UIColor.white
        self.progressView.addSubview(progressBar)
        
        self.progressBar.snp.makeConstraints { (m) in
            m.left.top.bottom.equalTo(self.progressView)
            m.width.equalTo(1)
        }
        
        self.progressBubble = UIImageView(image: UIImage(named: "bgBubbleLoading"))
        window?.addSubview(self.progressBubble)

        self.progressBubble.snp.makeConstraints { (m) in
            m.left.equalTo(self.progressBar.snp.right)
            m.top.equalTo(self.progressBar.snp.bottom).offset(11)
            m.width.equalTo(30)
            m.height.equalTo(17)
        }
        
        self.progressLabel = LTMorphingLabel()
        self.progressLabel.textColor = UIColor.white
        self.progressLabel.font = UIFont.systemFont(ofSize: 10)
        self.progressLabel.text = "0%"
        self.progressLabel.morphingEffect = .evaporate
        self.progressBubble.addSubview(self.progressLabel)
        
        self.progressLabel.snp.makeConstraints { (m) in
            m.center.equalTo(self.progressBubble)
        }

    }
}

extension IntroViewController {
    func loadData() {
        let today = Date()
        let settings = Settings()
        if var lastDate = settings.getDate() {
            lastDate.addTimeInterval(3600 * 24 * 7)
            if lastDate < today {
                self.startDataConnection(date: today)
            } else {
                self.everythingDone(date: nil)
            }
            
        } else {
            let alert = UIAlertController(title: "MotionBook", message: "Do you want to download initial data? (Wifi recommand)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in
                self.firstDownload = true
                self.startDataConnection(date: today)
            }))
            alert.view.tintColor = UIColor(hexString: MainColor)
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    func checkGifDatas(date: Date?) {
        let realm = try! Realm()
        let datas = realm.objects(LibraryDataModel.self)
        
        var titleArray = [String]()
        var dataArray = [String]()
        for data in datas {
            
            let image = FLAnimatedImage(animatedGIFData: data.gifData as Data!)
            if image == nil {
                if let url = data.gifUrl, let title = data.title {
                    dataArray.append(url)
                    titleArray.append(title)
                }
            }
        }
        
        if dataArray.count > 0 {
            self.getGifDatas(dataArray: dataArray, titleArray: titleArray, date: date)
        } else {
            self.everythingDone(date: date)
        }
    }
    
    func getGifDatas(dataArray: [String], titleArray: [String], date: Date?) {
        if dataArray.count > 0 {
            let networkManager = NetworkManager()
            
            let downloadGroup = DispatchGroup()
            var blocks: [DispatchWorkItem] = []
            
            
            var index = 1
            for i in 0 ..< dataArray.count {
                guard let url = URL(string: dataArray[i]) else { return }
                downloadGroup.enter()
                let block = DispatchWorkItem(flags: .inheritQoS) {
                    networkManager.downloadImage(title: titleArray[i], url: url, completion: { (error) in
                        if error == nil {
                            DispatchQueue.main.async {
                                index += 1
                                UIView.animate(withDuration: 0.3, animations: {
                                    let percent = CGFloat(index)/CGFloat(dataArray.count)
                                    let progressBarWidth = self.progressView.frame.width * percent
                                    
                                    self.progressLabel.text = "\(Int(percent * 100))%"
                                    self.progressBar.snp.remakeConstraints({ (m) in
                                        m.left.top.bottom.equalTo(self.progressView)
                                        m.width.equalTo(progressBarWidth)
                                    })
                                    if progressBarWidth + 30 > self.progressView.frame.width {
                                        self.progressBubble.image = UIImage(named: "bgBubbleLoading_over")
                                        self.progressBubble.snp.remakeConstraints({ (m) in
                                            m.right.equalTo(self.progressBar.snp.right)
                                            m.width.equalTo(30)
                                            m.height.equalTo(17)
                                            m.top.equalTo(self.progressBar.snp.bottom).offset(11)
                                        })
                                    }
                                    self.window.layoutIfNeeded()
                                })
                                
                            }
                        } else {
                            self.restartGifData(blocks: blocks, date: date, error: error!)
                        }
                        downloadGroup.leave()
                        
                    })
                }
                blocks.append(block)
                DispatchQueue.main.async(execute: block)
            }
            
            downloadGroup.notify(queue: DispatchQueue.main) {
                self.everythingDone(date: date)
            }
        } else {
            self.everythingDone(date: date)
        }
        
    }
    
    func restartGifData(blocks: [DispatchWorkItem], date: Date?, error: String) {
        for block in blocks {
            block.cancel()
        }
        let alert = UIAlertController(title: "MotionBook", message: error, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.destructive, handler: { action in
            self.retry()
        }))
    }
    
    func startButtonClicked() {
        Log.contentview(action: "startButtonClicked", location: self, id: nil)
        
        let vc = MainViewController()
        self.navigationController?.pushViewController(vc, animated: true)
        
        self.startButton.removeFromSuperview()
        self.progressBubble.removeFromSuperview()
        self.progressLabel.removeFromSuperview()
        self.progressView.removeFromSuperview()
    }
    
    func everythingDone(date: Date?) {
        DispatchQueue.main.async {
            self.startButton.alpha = 0
            self.startButton.isHidden = false
            self.pageControl?.isHidden = true

            UIView.animate(withDuration: 0.1, animations: {
                self.startButton.alpha = 1
                self.progressLabel.text = "100%"

                self.progressBar.snp.remakeConstraints({ (m) in
                    m.edges.equalTo(self.progressView)
                })
                
                self.progressBubble.image = UIImage(named: "bgBubbleLoading_over")
                self.progressBubble.snp.remakeConstraints({ (m) in
                    m.right.equalTo(self.progressBar.snp.right)
                    m.width.equalTo(30)
                    m.height.equalTo(17)
                    m.top.equalTo(self.progressBar.snp.bottom).offset(11)
                })

                self.window.layoutIfNeeded()
            }, completion: { (animated) in
                if let _date = date {
                    let settings = Settings()
                    settings.setDate(value: _date)
                    settings.setFullyDownloaded(value: true)
                }
                
                if !self.firstDownload {
                    self.startButtonClicked()
                }
            })
        }
        
    }
    
    func initialProgressBar(width: CGFloat) {
        let percent = width / self.progressView.frame.width
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.progressLabel.text = "\(Int(percent * 100))%"
                
                self.progressBar.snp.remakeConstraints({ (m) in
                    m.left.top.bottom.equalTo(self.progressView)
                    m.width.equalTo(width)
                })
                self.window.layoutIfNeeded()
                
            })
            
        }
    }
    
    func startDataConnection(date: Date?) {
        NetworkManager.shared.getInitialData { (error) in
            if let _error = error {
                self.showNetworkAlert(error: _error)

            } else {
                self.initialProgressBar(width: 5)
                NetworkManager.shared.updateUserData(completion: { (error) in
                    if let _error = error {
                        self.showNetworkAlert(error: _error)
                        
                    } else {
                        self.initialProgressBar(width: 10)

                        NetworkManager.shared.updateLibraryData(completion: { (error) in
                            if let _error = error {
                                self.showNetworkAlert(error: _error)
                                
                            } else {
                                self.initialProgressBar(width: 15)

                                NetworkManager.shared.updateGithubLicense(completion: { (error) in
                                    if let _error = error {
                                        self.showNetworkAlert(error: _error)
                                        
                                    } else {
                                        self.checkGifDatas(date: date)
                                    }
                                })
                            }
                        })
                    }
                })
                
            }
        }
    }
    
    func showNetworkAlert(error: String) {
        let settings = Settings()
        
        var alertString = "Network error occured due to '\(error)' reason.\n Do you want to use it without nerwork?"
        if !settings.getFullyDownloaded() {
            alertString = "Network error occured due to '\(error)' reason.\n Initial download is needed first"
        }
        
        let alert = UIAlertController(title: "MotionBook", message: alertString, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.destructive, handler: { action in
            self.retry()
        }))
        if settings.getFullyDownloaded() {
            alert.addAction(UIAlertAction(title: "Proceed", style: UIAlertActionStyle.default, handler: { action in
                self.proceed()
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func retry() {
        self.moveBack()
        self.loadData()
    }
    
    func proceed() {
        Log.contentview(action: "Loading done", location: self, id: nil)
        self.everythingDone(date: nil)
    }

}

extension Array {
    
    func at(_ index: Int?) -> Element? {
        var object: Element?
        if let index = index , index >= 0 && index < endIndex {
            object = self[index]
        }
        
        return object
    }
}
