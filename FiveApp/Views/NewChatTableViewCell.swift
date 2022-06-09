//
//  NewChatTableViewCell.swift
//  FiveApp
//
//  Created by Barbara Kos on 08.06.2022..
//

import Foundation
import UIKit
import SnapKit
import SDWebImage

class NewChatTableViewCell: UITableViewCell {
    static let id = "NewChatTableViewCell"
    
    private var userImageView: UIImageView!
    private var usernameLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: SearchResult) {
        usernameLabel.text = model.username
        
        let path = "images/\(model.email)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url)
                }
            case .failure(let error):
                print("Failed to get profile picture download URL: \(error)")
            }
            
        })
    }
    
    func buildViews() {
        createViews()
        styleViews()
        defineLayoutForViews()
    }
    
    func createViews() {
        userImageView = UIImageView()
        contentView.addSubview(userImageView)
        
        usernameLabel = UILabel()
        contentView.addSubview(usernameLabel)
    }
    
    func styleViews() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 35
        userImageView.layer.masksToBounds = true
        
        usernameLabel.font = .systemFont(ofSize: 21, weight: .semibold)
    }
    
    func defineLayoutForViews() {
        userImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(70)
            $0.height.equalTo(70)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }

}

