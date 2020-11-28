# TJRangeSlider
A slider that can customize the interval<br>

### Examples
![image](https://github.com/developerjet/TJRangeSlider/blob/master/Screenshot/SliderScreen.png)


### 一个可以自定义区间的滑杆
- 可随意设置滑杆的区间
- 通过RangeSliderStyle配置滑杆样式，或者你也可以基于它添加其他的属性
- 拓展性强，且无倾入性
- 内部基于frame布局，集成方便

### Use

```swift
private lazy var sliderStyle: RangeSliderStyle = {
    var style = RangeSliderStyle()
    style.xFloats = xFloats
    style.normalColor = UIColor.colorWithHexStr("F6F6F6")
    style.selectedColor = UIColor.colorWithHexStr("00D4BC")
    style.isAdsorption = true
    style.stopSpace = 0.5
    return style
}()
```

```swift
private lazy var sliderView: RangeSliderView = {
    let x: CGFloat = 30
    let w: CGFloat = self.view.frame.width - x * 2
    let frame = CGRect(x: x, y: 140, width: w, height: 50)
    let slider = RangeSliderView(frame: frame, style: sliderStyle)
    slider.delegate = self
    return slider
}()
```

``` swift
extension ExampleViewController: RangSliderDelegate {
    
    func slider(_ silder: RangeSliderView, at config: SliderRangeConfig) {
        print("changed angle is \(config.selectedAngle)")
        
        selectedRange = config
        acceptAngleValue(at: config.selectedAngle)
    }
    
    private func acceptAngleValue(at angle: CGFloat) {
        xAngleLabel.text = String(format: "%.f", (angle * 100))
    }
}
```

### Tips
- 如果你有更好的建议和方案请在lssues提交
- 更多功能，后续会完善

### Star.
- 如果你喜欢的话或对你开发中有帮助的话，麻烦给个🌟Star🌟，非常感谢<br>
