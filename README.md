# Official MotionBook Source Code 

[![Platform](http://img.shields.io/badge/platform-ios-green.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
![Language](https://img.shields.io/badge/language-Swift-brightgreen.svg?style=flat)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PAKBM2K9YU6QN)

#### Welocome to MotionBook!
- GitHub URL: https://github.com/younatics/MotionBook
- App Store URL: https://appsto.re/kr/8yv1hb.i
- Facebook URL: https://www.facebook.com/MotionBookiOS/

Before start, MotionBook source is complicated and little bit messy. Please help us to develop this source much better than before! 
MotionBook is open source based project. Because of that, I decided to open MotionBook source.

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

### 1. Submodule https://github.com/younatics/MotionBook.git
`git submodule add https://github.com/younatics/MotionBook.git git/`

### 2. Add Github Personal access token
Github Personal settings -> Personal access tokens -> Generate new token -> Edit `user` and `token` in `NetworkManager.swift`

```Swift
class NetworkManager: NSObject {
    let user = "younatics"
    let token = "b908fde1073fb488eeee32b9213c0542b410876a"
}
```

### 3. Pod install
`pod install`

## Basic Logic

#### 1. Get data from MotionBook README.md
Get basic data and store in `RealmSwift`

#### 2. Update latest data from GitHub Api
Once a week, MotionBook will check date and update Github data(Stars, Issues, Forks) using GitHub Api.

#### 3. Get Gif data using submodule
Submodule https://github.com/younatics/MotionBook this repository and get gif data

#### 4. Use On-Demand Resources for faster download speed
[On-Demand Resources](https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/On_Demand_Resources_Guide/index.html#//apple_ref/doc/uid/TP40015083-CH2-SW1) make faster download speed. 

#### 5. Update Gif data to Realm
Update Gif data to `Realm` and store.



## Author
[younatics 🇰🇷](http://younatics.github.io)

## License
MotionBook-Source is available under the GNU General Public License v3.0 license. See the [LICENSE](LICENSE) file for more info.
