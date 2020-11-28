//
//  ViewController.swift
//  TJRangeSlider
//
//  Created by codertj on 2020/11/28.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var exampleBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: (self.view.frame.width - 100) * 0.5, y: 120, width: 100, height: 30)
        button.setTitleColor(.blue, for: .normal)
        button.setTitle("Example", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private var rangeConfig = SliderRangeConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        
        exampleBtn.center = view.center
        view.addSubview(exampleBtn)
    }
    
    @objc
    func buttonAction(_ button: UIButton) {
        let exampleVc = ExampleViewController.getVc(rangeConfig: rangeConfig) { [weak self] (endRange) in
            guard let self = self else { return }
            self.rangeConfig = endRange
        }
        navigationController?.pushViewController(exampleVc, animated: true)
    }
}
