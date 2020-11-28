//
//  RangeSlider.swift
//  TJRangeSlider
//
//  Created by codertj on 2020/11/28.
//

import UIKit

struct RangeSliderStyle {
    /// 未选中颜色
    var normalColor: UIColor = .gray
    /// 选中样式
    var selectedColor: UIColor = .green
    /// 标识文字未选中字体颜色
    var textNormalColor: UIColor = .lightGray
    /// 滑杆系数配置
    var xFloats: [CGFloat] = []
    /// 是否需要吸附
    var isAdsorption: Bool = false
    /// 吸附范围设置（0.1～1.0）
    var stopSpace: CGFloat = 0.35
}

struct SliderRangeConfig {
    var firstFloatX: CGFloat = 0
    var endFloatX: CGFloat = 0
    
    var firstX: CGFloat = 0
    var centerX: CGFloat = 0
    var endX: CGFloat = 0
    /// 当前区间选择标签位置
    var selectedX: CGFloat = 0
    
    var firstIndex: Int = 0
    var endIndex: Int = 0
    
    /// 当前区间选择标签索引
    var selectedIndex: Int = 0
    /// 是否支持滑动自由停靠
    var isPanStop: Bool = false
    /// 是否必须吸附停靠
    var isMustStop: Bool = false
    /// 当前自由停靠的刻度值
    var stopOffsetX: CGFloat = 0
    
    /// 某个区间内的刻度值
    var scales: [MLSmallRange] = []
    
    /// 某个区间内的小刻度值
    var indexScale: CGFloat = 0
    /// 滑动停止后获取的刻度值
    var selectedAngle: CGFloat = 0
}

struct MLSmallRange {
    var keyX: CGFloat = 0
    var valueX: CGFloat = 0
}

protocol RangSliderDelegate: class {
    func slider(_ silder: RangeSliderView, at config: SliderRangeConfig)
}

extension RangSliderDelegate {
    func slider(_ silder: RangeSliderView, at config: SliderRangeConfig) { }
}

class RangeSliderView: UIView {
    /// 外部设置刻度
    public var sliderRange: SliderRangeConfig? {
        didSet {
            guard let range = sliderRange else {
                return
            }
            
            if (range.isMustStop) {
                selectedCenterWithSafeIndex(centerX: range.centerX, safeIndex: range.selectedIndex)
            }else {
                if (range.selectedAngle <= 0.01) {
                    if let centerX = buttonViews.first?.centerX {
                        selectedCenterWithSafeIndex(centerX: centerX, safeIndex: range.selectedIndex)
                    }
                }else {
                    let findIndex = sliderStyle.xFloats.firstIndex(where: { (xFloat) -> Bool in
                        return xFloat == range.selectedAngle
                    })
                    
                    if let safeIndex = findIndex {
                        selectedCenterWithSafeIndex(safeIndex: safeIndex)
                    }else {
                        let xRadius = selectedView.width * 0.5
                        selectedView.x = calculateDotScaleCenterX(angle: range.selectedAngle) - xRadius
                        clearSelectedIndexColor()
                    }
                }
            }
            
            changedColorLayerOffsetX(offsetX: selectedView.centerX)
        }
    }
    
    // MARK: - Lazy var
    
    weak var delegate: RangSliderDelegate?
    
    private var labelViews: [UILabel] = []
    private var buttonViews: [UIButton] = []
    private var sliderRanges: [SliderRangeConfig] = []
    
    private var sliderStyle = RangeSliderStyle()
    
    private lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: 18))
        return view
    }()
    
    private lazy var sliderLineView: UIView = {
        let height: CGFloat = 2
        let frame = CGRect(x: 0, y: (contentView.height - height) * 0.5, width: contentView.width, height: height)
        let bototmLine = UIView(frame: frame)
        bototmLine.backgroundColor = sliderStyle.normalColor
        return bototmLine
    }()
    
    private lazy var layerColorView: UIView = {
        let height: CGFloat = sliderLineView.height
        let frame = CGRect(x: 0, y: 0, width: 0, height: height)
        let colorView = UIView(frame: frame)
        colorView.backgroundColor = sliderStyle.selectedColor
        return colorView
    }()
    
    private lazy var selectedView: UIView = {
        let selectView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        selectView.borderWidth = 4
        selectView.cornerRadius = 9
        selectView.borderColor = sliderStyle.selectedColor
        selectView.backgroundColor = .white
        return selectView
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(sliderPanGestureChange(_:)))
        return pan
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(sliderTapGestureChange(_:)))
        return tap
    }()
    
    // MARK: - Life cycle
    
    public init(frame: CGRect, style: RangeSliderStyle) {
        super.init(frame: frame)
        self.sliderStyle.xFloats = style.xFloats
        self.sliderStyle.normalColor = style.normalColor
        self.sliderStyle.selectedColor = style.selectedColor
        self.sliderStyle.isAdsorption = style.isAdsorption
        
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func buildUI() {
        sliderLineView.addSubview(layerColorView)
        contentView.addSubview(sliderLineView)
        addSubview(contentView)
        
        setupSliderGestureSettings()
        drawSpaceDotOrScale(xFloats: sliderStyle.xFloats)
    }
    
    private func setupSliderGestureSettings() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)
        self.addGestureRecognizer(panGesture)
    }
    
    /// 绘制分割点和分割标点
    /// - Parameter xFloats: 具体间隔参数
    private func drawSpaceDotOrScale(xFloats: [CGFloat]) {
        guard xFloats.count > 0 else {
            return
        }
        
        for index in 0..<xFloats.count {
            let dotWH: CGFloat = 10
            let dotY: CGFloat = (contentView.height - dotWH) / 2
            let dotButton = UIButton(type: .custom)
            dotButton.cornerRadius = dotWH * 0.5
            dotButton.tag = index
            dotButton.isUserInteractionEnabled = false
            dotButton.backgroundColor = sliderStyle.selectedColor
            
            let offsetX = calculateAccuracyX(xFloats[index], selectedRadius: selectedView.width * 0.5)
            
            if (index == 0) {
                dotButton.frame = CGRect(x: 0, y: dotY, width: dotWH, height: dotWH)
                selectedView.centerX = dotButton.centerX
                selectedView.centerY = dotButton.centerY
            }else {
                dotButton.frame = CGRect(x: offsetX, y: dotY, width: dotWH, height: dotWH)
            }
            
            contentView.addSubview(dotButton)
            buttonViews.append(dotButton)
            
            /// 绘制刻度
            let scaleLabel = UILabel()
            scaleLabel.font = UIFont.systemFont(ofSize: 11)
            scaleLabel.textColor = sliderStyle.textNormalColor
            
            let scale = String(format:"%.d", Int(xFloats[index] * 100))
            scaleLabel.text = scale
            scaleLabel.textAlignment = .center
            scaleLabel.frame = CGRect(x: dotButton.x, y: contentView.maxY + 3, width: 23, height: 23)
            scaleLabel.centerX = dotButton.centerX
            addSubview(scaleLabel)
            labelViews.append(scaleLabel)
        }
        
        contentView.addSubview(selectedView)
        contentView.bringSubviewToFront(selectedView)
        
        // 设置吸附区间
        createSliderButtonRanges(buttonViews)
    }
    
    
    /// 设置吸附区间
    /// - Parameter buttons: 所有按钮
    private func createSliderButtonRanges(_ buttons: [UIButton]) {
        guard buttons.count == sliderStyle.xFloats.count else { return }
        
        for index in 0..<buttons.count {
            var range = SliderRangeConfig()
            if (index < buttons.count - 1) {
                range.firstX = buttonViews[index].centerX
                range.endX = buttonViews[index + 1].centerX
                range.centerX = ((range.endX - range.firstX) * 0.5) + range.firstX
                range.firstIndex = index
                range.endIndex = index + 1
                
                // 刻度间距大于1的时候可以自由停靠
                range.firstFloatX = sliderStyle.xFloats[index]
                range.endFloatX = sliderStyle.xFloats[index + 1]
                if ((range.endFloatX - range.firstFloatX) > 0.01) {
                    range.isPanStop = true
                    let distance = range.endX - range.firstX
                    let offsetCount = Int((range.endFloatX - range.firstFloatX) * 100)
                    let baseX: CGFloat = 0.01
                    let equalX = distance / CGFloat(offsetCount)
                    
                    var keyX = range.firstX
                    var valueX: CGFloat = range.firstFloatX
                    for _ in 0..<offsetCount {
                        keyX += equalX
                        valueX += baseX
                        
                        var smallRange = MLSmallRange()
                        smallRange.keyX = keyX
                        smallRange.valueX = valueX
                        range.scales.append(smallRange)
                    }
                    
                    // 该小区间内的两点之间的距离
                    range.indexScale = equalX
                    
                }else {
                    
                    range.isPanStop = false
                }
            }else {
                range.firstX = buttonViews[index].centerX
                range.endX = range.firstX
                range.centerX = range.firstX
                range.firstIndex = index
                range.endIndex = index
                
                range.isPanStop = true
            }
            
            sliderRanges.append(range)
        }
    }
    
    private func calculateDotScaleCenterX(angle: CGFloat) -> CGFloat {
        guard sliderRanges.count > 0 else {
            return selectedView.width * 0.5
        }
        
        let delta: CGFloat = 0.0000000000000001
        var currentRange = SliderRangeConfig()
        for index in 0..<sliderRanges.count {
            if let range = sliderRanges[safe: index] {
                if angle >= range.firstFloatX && angle <= range.endFloatX {
                    //print("firstFloat：\(range.firstFloatX)")
                    for item in range.scales {
                        //print("keyX：\(item.keyX)\nvalueX：\(item.valueX)")
                        if ((angle - item.valueX) <= delta) {
                            currentRange.centerX = item.keyX
                            break
                        }
                    }
                }
            }
        }
        
        return currentRange.centerX
    }
    
    
    /// 计算某个百分比的实际位置
    ///
    /// - Parameter percent: 指定百分比
    /// - Returns: 返回精确的x坐标
    private func calculateAccuracyX(_ percent: CGFloat, selectedRadius: CGFloat) -> CGFloat {
        return percent * (self.bounds.width - selectedRadius * 2) + selectedRadius
    }
    
    /// 设置刻度字体高亮显示
    /// - Parameter selectedIndex: 对应的刻度索引
    private func makeScaleHighlightColor(index: Int) {
        guard labelViews.count > 0 else { return }
        
        for idx in 0..<labelViews.count {
            if let label = labelViews[safe: idx] {
                if (idx == index) {
                    label.textColor = sliderStyle.selectedColor
                 }else {
                    label.textColor = sliderStyle.textNormalColor
                }
            }
        }
    }
    
    private func clearSelectedIndexColor() {
        guard labelViews.count > 0 else { return }
        
        for index in 0..<labelViews.count {
            if let label = labelViews[safe: index] {
                label.textColor = .colorWithHexStr("77808A")
            }
        }
    }
    
    @objc
    private func setupSelectedOffsetX(index: Int) {
        guard buttonViews.count > 0 else { return }
        
        if let selectedBtn = buttonViews[safe: index] {
            UIView.animate(withDuration: 0.01) {
                self.selectedView.centerX = selectedBtn.centerX
            }
        }
    }
    
    // MARK: - Silder Gesture change handler
    
    @objc
    private func sliderTapGestureChange(_ sender: UITapGestureRecognizer) {
        let offsetX = sender.location(in: self).x
        sliderChangeHandler(offsetX: offsetX, sender: self.tapGesture, isTap: true)
    }
    
    @objc
    private func sliderPanGestureChange(_ sender: UIPanGestureRecognizer) {
        let offsetX = sender.location(in: self).x
        sliderChangeHandler(offsetX: offsetX, sender: self.panGesture, isTap: sliderStyle.isAdsorption)
    }
    
    private func sliderChangeHandler(offsetX: CGFloat, sender: UIGestureRecognizer, isTap: Bool) {
        // 处理边界值
        if (offsetX <= 0) {
            if let firstButton = buttonViews.first {
                selectedView.x = 0
                selectedCenterWithSafeIndex(centerX: firstButton.centerX, safeIndex: firstButton.tag)
            }
            return
        }else if (offsetX >= (self.width - selectedView.width * 0.5)) {
            if let lastButton = buttonViews.last {
                selectedView.x = self.width - selectedView.width * 0.5
                selectedCenterWithSafeIndex(centerX: lastButton.centerX, safeIndex: lastButton.tag)
            }
            return
        }
        
        selectedView.x = offsetX - (selectedView.width * 0.5)
        let range = configAutomaticAdsorption(offsetX)
        if (range.isPanStop) {
            if (range.isMustStop && isTap) {
                selectedCenterWithSafeIndex(centerX: range.selectedX, safeIndex: range.selectedIndex)
                return
            }
            
            if range.selectedAngle > 0.01 {
                selectedView.x = offsetX - (selectedView.width * 0.5)
                var selectedRange = SliderRangeConfig()
                selectedRange.selectedAngle = range.selectedAngle
                selectedRange.centerX = selectedView.x
                clearSelectedIndexColor()
                delegate?.slider(self, at: selectedRange)
            }else {

                selectedCenterWithSafeIndex(centerX: range.selectedX, safeIndex: range.selectedIndex)
            }
        }else {
            
            selectedCenterWithSafeIndex(centerX: range.selectedX, safeIndex: range.selectedIndex)
        }
        
        
        changedColorLayerOffsetX(offsetX: selectedView.centerX)
    }
    
    private func selectedCenterWithSafeIndex(centerX: CGFloat = 0, safeIndex: Int) {
        if let button = buttonViews[safe: safeIndex] {
            selectedView.centerX = button.centerX
        }
        
        makeScaleHighlightColor(index: safeIndex)
        adjustSliderDidEndEditing(index: safeIndex)
    }
    
    /// 设置底部渲染距离
    private func changedColorLayerOffsetX(offsetX: CGFloat) {
        layerColorView.width = offsetX
        layerColorView.layoutIfNeeded()
    }
    
    /// 设置点击自动吸附
    private func configAutomaticAdsorption(_ offsetX: CGFloat) -> SliderRangeConfig {
        guard sliderRanges.count > 0 else {
            return SliderRangeConfig()
        }
        
        let stopSpace = selectedView.width * sliderStyle.stopSpace
        var currentRange = SliderRangeConfig()
        for index in 0..<sliderRanges.count {
            if let range = sliderRanges[safe: index] {
                currentRange.scales = range.scales
                currentRange.isPanStop = range.isPanStop
                // 是否可自由停靠
                if (range.isPanStop) {
                    if offsetX >= range.firstX && offsetX <= range.endX {
                        if (offsetX - range.firstX) <= stopSpace {
                            currentRange.isMustStop = true
                            currentRange.selectedX = range.firstX
                            currentRange.selectedIndex = range.firstIndex
                        }else if (range.endX - offsetX) <= stopSpace  {
                            currentRange.isMustStop = true
                            currentRange.selectedX = range.endX
                            currentRange.selectedIndex = range.endIndex
                        }
                        
                        for item in range.scales {
                            if ((offsetX - item.keyX) <= range.indexScale) {
                                //print("keyX：\(item.keyX)\nvalueX：\(item.valueX)")
                                currentRange.centerX = item.keyX
                                currentRange.selectedAngle = item.valueX
                                break
                            }
                        }
                    }
                    
                }else {
                    currentRange.isPanStop = false
                    // 停靠在特定的刻度上
                    if offsetX >= range.firstX && offsetX <= range.centerX {
                        currentRange.selectedX = range.firstX
                        currentRange.selectedIndex = range.firstIndex
                    }else if (offsetX > range.centerX && offsetX <= range.endX) {
                        currentRange.selectedX = range.endX
                        currentRange.selectedIndex = range.endIndex
                    }else if (offsetX == range.centerX) {
                        let random = arc4random()%100 + 1
                        if (random%2 == 0) {
                            currentRange.selectedX = range.firstX
                            currentRange.selectedIndex = range.firstIndex
                        }else {
                            currentRange.selectedX = range.endX
                            currentRange.selectedIndex = range.endIndex
                        }
                    }
                }
            }
        }
        
        return currentRange
    }
    
    private func adjustSliderDidEndEditing(index: Int) {
        guard sliderStyle.xFloats.count > 0 else { return }
        
        if let selectedAngle = sliderStyle.xFloats[safe: index] {
            var selectedRange = SliderRangeConfig()
            selectedRange.isMustStop = true
            selectedRange.selectedAngle = selectedAngle
            selectedRange.centerX = selectedView.centerX
            selectedRange.selectedIndex = index
            delegate?.slider(self, at: selectedRange)
        }
        
        changedColorLayerOffsetX(offsetX: selectedView.centerX)
    }
}
