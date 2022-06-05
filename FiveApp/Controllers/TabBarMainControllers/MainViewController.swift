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
        
        let image = UIImageView(image: UIImage (named: "FivePng"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        navigationController?.navigationBar.addSubview(image)
        image.snp.makeConstraints {
            $0.centerX.top.bottom.equalToSuperview()
            $0.width.equalTo(150)
//            $0.height.equalTo(45)
        }
    }
    


}
