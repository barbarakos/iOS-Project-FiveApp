//
//  MainViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 31.05.2022..
//

import UIKit
import SnapKit

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let navBarAppearance = UINavigationBarAppearance()
        navigationController?.navigationBar.isTranslucent = false
        navBarAppearance.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.9)
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.barStyle = .black
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
        let uiview = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 100))
        let image = UIImage (named: "FivePng")
        imageView.image = image
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        imageView.contentMode = .scaleAspectFill
        uiview.addSubview(imageView)
        imageView.clipsToBounds = true
        navigationItem.titleView = uiview
        imageView.snp.makeConstraints {
            $0.centerX.centerY.top.bottom.equalToSuperview()
            $0.width.equalTo(150)
//            $0.height.equalTo(100)
        }
        
        navigationController?.navigationBar.barStyle = .default
        navigationItem.backButtonTitle = ""
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.backgroundColor : UIColor.white]
    }
    


}
