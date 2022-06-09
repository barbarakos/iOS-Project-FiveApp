//
//  HomeworkTableView.swift
//  FiveApp
//
//  Created by Barbara Kos on 08.06.2022..
//

import UIKit

protocol HomeworkDelegate: AnyObject {
    func addHomeworkButtonWasTapped()
}

struct HomeworkCellModel {
    let title: String
    let data: Data
}

class HomeworkTableView: UITableView {
    var navigationController: UINavigationController!
    
    var homeworkModels = [HomeworkCellModel]()
    
    weak var homeworkDelegate: HomeworkDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        configure()
        fetchHomeworkData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNavController(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func configure() {
        
        delegate = self
        dataSource = self
        register(HomeworkCell.self, forCellReuseIdentifier: "cellId")
    }
    
    func createTableHeader() -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 40))
        header.layer.borderWidth = 1.5
        header.layer.borderColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 1).cgColor
        header.backgroundColor = UIColor(red: 149/255, green: 93/255, blue: 55/255, alpha: 0.7)
        
        let plusImageView = UIImageView(image: UIImage(systemName: "plus"))
        plusImageView.contentMode = .scaleAspectFill
        plusImageView.tintColor = .white
        
        let labelTitle = UILabel()
        labelTitle.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        labelTitle.textColor = .white
        labelTitle.text = "Domaće zadaće"
        
        
        plusImageView.isUserInteractionEnabled = true
        self.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddHomeworkButton))
        plusImageView.addGestureRecognizer(gesture)
        header.addSubview(labelTitle)
        labelTitle.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview().inset(7)
        }
        
        guard let admin = UserDefaults.standard.value(forKey: "admin") as? Bool else {
            return nil
        }
        if admin {
            header.addSubview(plusImageView)
            plusImageView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(7)
                $0.trailing.bottom.equalToSuperview().inset(7)
            }
        }
        
        return header
        
    }
    
    @objc private func didTapAddHomeworkButton() {
        homeworkDelegate?.addHomeworkButtonWasTapped()
    }
    
    func reload(downloadURL: String) {
        guard let url = URL(string: downloadURL) else {
            return
        }
        URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, _ , error in
            guard let strongSelf = self, let data = data, error == nil else {
                return
            }
            print("\(url.lastPathComponent) \(data)")
            
            strongSelf.homeworkModels.append(HomeworkCellModel(title: url.lastPathComponent, data: data))
            DispatchQueue.main.async {
                strongSelf.reloadData()
            }
        }).resume()
    }
    
    func fetchHomeworkData() {
        print("fetching homework data")
        let path = "homework/"
        StorageManager.shared.downloadURLS(for: path, completion: { [weak self] result in
            switch result {
            case .success(let URLS):
                self?.downloadDocuments(urls: URLS)
                DispatchQueue.main.async {
                    
                    self?.reloadData()
                }
            case .failure(let error):
                print("Error getting the download URL: \(error)")
            }
        })
    }
    
    func downloadDocuments(urls: [URL]) {
        for url in urls {
            print("dohvaceni url: \(url)")
            URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, _ , error in
                guard let strongSelf = self, let data = data, error == nil else {
                    return
                }
                print("\(url.lastPathComponent) \(data)")
                
                strongSelf.homeworkModels.append(HomeworkCellModel(title: url.lastPathComponent, data: data))
                DispatchQueue.main.async {
                    strongSelf.reloadData()
                }
            }).resume()
        }
    }

}

extension HomeworkTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createTableHeader()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        homeworkModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! HomeworkCell
        cell.setup(model: homeworkModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let pdfVC = PDFViewController()
        pdfVC.setData(data: homeworkModels[indexPath.row].data)
        navigationController.pushViewController(pdfVC, animated: true)
    }
    
}

extension HomeworkTableView: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            return
        }
        
        do {
            let data = try Data.init(contentsOf: url)
            
            //now i have data of selected file
            let fileName = "homework/\(url.lastPathComponent)"
            StorageManager.shared.uploadDocument(with: data, fileName: fileName, completionHandler: { [weak self] result in
                switch result {
                case .success(let downloadURL):
                    print("successfully uploaded homework")
                    self?.reload(downloadURL: downloadURL)
                case .failure(let error):
                    print("Storage manager error: \(error)")
                }
            })
        } catch {
            print(error.localizedDescription)
        }
        
        do { url.stopAccessingSecurityScopedResource() }
    }
    
}

class HomeworkCell: UITableViewCell {
    
    let docTitle = UILabel()
    let icon = UIImageView(image: UIImage(systemName: "doc.text.fill"))
    
    func setup(model: HomeworkCellModel) {
        docTitle.text = model.title
        contentView.addSubview(docTitle)
        contentView.addSubview(icon)
        editViews()
    }
    
    func editViews() {
        docTitle.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        
        icon.tintColor = .systemGray
        
        icon.snp.makeConstraints {
            $0.leading.top.equalToSuperview().offset(7)
            $0.bottom.equalToSuperview().inset(7)
            $0.width.equalTo(30)
            $0.height.equalTo(30)
        }
        docTitle.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview().inset(7)
            $0.leading.equalTo(icon.snp.trailing).offset(7)
        }
    }
    
}
