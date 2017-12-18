# Official MotionBook Source Code 

![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg)
[![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PAKBM2K9YU6QN)

#### Welocome to MotionBook!
- GitHub URL: https://github.com/younatics/MotionBook
- App Store URL: https://appsto.re/kr/8yv1hb.i
- Facebook URL: https://www.facebook.com/MotionBookiOS/

Before start, MotionBook source is complicated and little bit messy. Please help us to develop this source much better than before! 
MotionBook is an open source based project. Because of that, I decided to open MotionBook source.

Hopes this repo help someone :)

## Documentation
- [Full documentaion](https://github.com/younatics/MotionBook-Source/wiki)
- [Contribution Guide](https://github.com/younatics/MotionBook-Source/wiki/Contribution-Guide)
- [Installation](https://github.com/younatics/MotionBook-Source/wiki/Installation)
- [Basic Logic](https://github.com/younatics/MotionBook-Source/wiki/Basic-Logic)

## Contributing to MotionBook
Contributions to MotionBook are welcomed and encouraged! Please see the [Contribution Guide](https://github.com/younatics/MotionBook-Source/wiki/Contribution-Guide)

We welcome code refactor or any other changes. Please do not hesitate.

## Getting Started
Installation is needed befor you start. please see the [Installation Guide](https://github.com/younatics/MotionBook-Source/wiki/Installation)

### Add Github Personal access token and user Id in `Key.swift`

```Swift 
enum Key: String {
    case gitHubId = "younatics"
    case githubToken = ""
    case firbaseKey = ""
}
```

## Basic Logic

#### 1. Get data from MotionBook README.md
Get basic data and store in `RealmSwift`

#### 2. Update latest data from GitHub Api
Once a week, MotionBook will check date and update Github data(Stars, Issues, Forks) using GitHub Api.

#### 3. Use On-Demand Resources for faster download speed
[On-Demand Resources](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/index.html#//apple_ref/doc/uid/TP40015083-CH2-SW1) make faster download speed. 

#### 4. Update Gif data to Realm
Update Gif data to `Realm` and store.

## Author
[younatics](https://twitter.com/younatics)
<a href="http://twitter.com/younatics" target="_blank"><img alt="Twitter" src="https://img.shields.io/twitter/follow/younatics.svg?style=social&label=Follow"></a>

## License
MotionBook-Source is available under the Apache License 2.0. See the [LICENSE](LICENSE) file for more info.
