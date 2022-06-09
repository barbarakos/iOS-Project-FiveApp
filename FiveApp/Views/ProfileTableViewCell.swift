//
//  ProfileTableViewCell.swift
//  FiveApp
//
//  Created by Barbara Kos on 08.06.2022..
//

import UIKit

class ProfileTableViewCell: UITableViewCell {
    static let id = "ProfileTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    public func setUp(with viewModel: ProfileViewModel) {
        self.textLabel?.text = viewModel.title
        
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
            selectionStyle = .none
//            self.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.2)
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
            textLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        }
    }

}
