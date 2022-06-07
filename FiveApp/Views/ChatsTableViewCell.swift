//
//  ChatsTableViewCell.swift
//  FiveApp
//
//  Created by Barbara Kos on 05.06.2022..
//

import UIKit
import SDWebImage

class ChatsTableViewCell: UITableViewCell {
    static let id = "ChatsTableViewCell"
    
    private var userImageView: UIImageView!
    private var usernameLabel: UILabel!
    private var userMessageLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func configure(with model: Conversation) {
        self.userMessageLabel.text = model.latestMessage.text
        self.usernameLabel.text = model.name
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
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
        
        userMessageLabel = UILabel()
        contentView.addSubview(userMessageLabel)
    }
    
    func styleViews() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 50
        userImageView.layer.masksToBounds = true
        
        usernameLabel.font = .systemFont(ofSize: 21, weight: .semibold)
        
        userMessageLabel.font = .systemFont(ofSize: 19, weight: .regular)
        userMessageLabel.numberOfLines = 0
    }
    
    func defineLayoutForViews() {
        userImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.width.equalTo(100)
            $0.height.equalTo(100)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(10)
            $0.top.equalToSuperview().offset(20)
        }
        
        userMessageLabel.snp.makeConstraints {
            $0.leading.equalTo(userImageView.snp.trailing).offset(10)
            $0.top.equalTo(usernameLabel.snp.bottom).offset(20)
        }
    }

}
