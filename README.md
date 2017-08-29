# Official MotionBook Source Code

[![Platform](http://img.shields.io/badge/platform-ios-green.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
![Language](https://img.shields.io/badge/language-Swift-brightgreen.svg?style=flat)
[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=PAKBM2K9YU6QN)

#### I decided to open my [MotionBook](https://appsto.re/kr/8yv1hb.i) source. It is little bit messy :(
#### Hopes this repo help someone :) 

## Getting Started

### 1. Submodule https://github.com/younatics/MotionBook.git
`git submodule add https://github.com/younatics/MotionBook.git git/`

### 2. Add Github Personal access token
Github Personal settings -> Personal access tokens -> Generate new token
Edit `user` and `token` in `NetworkManager.swift`

```Swift
class NetworkManager: NSObject {
    let user = "younatics"
    let token = "b908fde1073fb488eeee32b9213c0542b410876a"
}
```

### 3. Pod install
`pod install`

#### Done! You can now use MotionBook source!
See more information in [Wiki](https://github.com/younatics/MotionBook-Source/wiki)

## Author
[younatics 🇰🇷](http://younatics.github.io)

## License
MotionBook-Source is available under the GNU General Public License v3.0 license. See the [LICENSE](LICENSE) file for more info.
