//
//  ExampleViewController.swift
//  TJRangeSlider
//
//  Created by codertj on 2020/11/28.
//

import UIKit

class ExampleViewController: UIViewController {
    
    static func getVc(rangeConfig: SliderRangeConfig, closure: @escaping (SliderRangeConfig)->Void) -> ExampleViewController {
        let vc = ExampleViewController()
        vc.selectedRange = rangeConfig
        vc.didAdjustSliderClosure = closure
        return vc
    }
    
    // MARK: - Lazy var
    
    private var xFloats: [CGFloat] {
        return [0.01, 0.1, 0.2, 0.3, 0.5, 0.7, 1]
    }
    
    private lazy var sliderStyle: RangeSliderStyle = {
        var style = RangeSliderStyle()
        style.xFloats = xFloats
        style.normalColor = UIColor.colorWithHexStr("F6F6F6")
        style.selectedColor = UIColor.colorWithHexStr("00D4BC")
        style.isAdsorption = true
        style.stopSpace = 0.5
        return style
    }()
    
    private lazy var sliderView: RangeSliderView = {
        let x: CGFloat = 30
        let w: CGFloat = self.view.frame.width - x * 2
        let frame = CGRect(x: x, y: 140, width: w, height: 50)
        let slider = RangeSliderView(frame: frame, style: sliderStyle)
        slider.delegate = self
        return slider
    }()
    
    private lazy var xAngleLabel: UILabel = {
        let w: CGFloat = 120
        let x: CGFloat = self.view.frame.width - w * 2
        let label = UILabel(frame: CGRect(x: x, y: sliderView.maxY + 50, width: w, height: 50))
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        label.textAlignment = .center
        label.text = "1"
        return label
    }()
    
    private var selectedRange: SliderRangeConfig!
    private var didAdjustSliderClosure: ((SliderRangeConfig) -> Void)?
    
    // MARK: - Life cycle
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        didAdjustSliderClosure?(selectedRange)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Example"
        
        makeUI()
        bindDataSource()
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(sliderView)
        view.addSubview(xAngleLabel)
    }
    
    private func bindDataSource() {
        if selectedRange.selectedAngle <= 0.1 {
            sliderView.sliderRange = selectedRange
        }
        
        // configure
        sliderView.sliderRange = selectedRange
        acceptAngleValue(at: selectedRange.selectedAngle)
    }
}


// MARK: - RangSliderDelegate

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
