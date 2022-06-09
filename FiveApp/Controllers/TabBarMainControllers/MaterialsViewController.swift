//
//  MaterialsViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 30.05.2022..
//

import UIKit
import UniformTypeIdentifiers
import JGProgressHUD

class MaterialsViewController: MainViewController {
    private let spinner = JGProgressHUD(style: .dark)
    let type: [UTType] = [UTType.pdf]
    
    var homeworkTableView: HomeworkTableView!
    var presentationsTableView: PresentationsTableView!
    var scriptsTableView: ScriptsTableView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        buildViews()
    }
    
    func buildViews() {
        createViews()
        styleViews()
        defineLayoutForViews()
    }
    
    func createViews() {
        homeworkTableView = HomeworkTableView()
        homeworkTableView.setNavController(navigationController: navigationController!)
        homeworkTableView.homeworkDelegate = self
        view.addSubview(homeworkTableView)
        
        presentationsTableView = PresentationsTableView()
        presentationsTableView.setNavController(navigationController: navigationController!)
        presentationsTableView.presentationDelegate = self
        view.addSubview(presentationsTableView)
        
        scriptsTableView = ScriptsTableView()
        scriptsTableView.setNavController(navigationController: navigationController!)
        scriptsTableView.scriptDelegate = self
        view.addSubview(scriptsTableView)
    }
    
    func styleViews() {
        
    }
    
    func defineLayoutForViews() {
        homeworkTableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(-5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(presentationsTableView.snp.top)
            $0.height.equalTo(200)
        }
        presentationsTableView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(homeworkTableView.snp.bottom)
            $0.bottom.equalTo(scriptsTableView.snp.top)
            $0.height.equalTo(200)
        }
        scriptsTableView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.top.equalTo(presentationsTableView.snp.bottom)
            $0.height.equalTo(200)
        }
    }
    

}

extension MaterialsViewController: HomeworkDelegate, PresentationsDelegate, ScriptDelegate {
    
    func addHomeworkButtonWasTapped() {
        print("didTapPlus")
        
        let actionSheet = UIAlertController(title: "Attach homework", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Go to documents folder", style: .default, handler: { [weak self] _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: self!.type)
            picker.delegate = self?.homeworkTableView
            picker.allowsMultipleSelection = false
            picker.modalPresentationStyle = .formSheet
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    func addPresetationButtonWasTapped() {
        print("didTapPlus")
        
        let actionSheet = UIAlertController(title: "Attach a presentation", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Go to documents folder", style: .default, handler: { [weak self] _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: self!.type)
            picker.delegate = self?.presentationsTableView
            picker.allowsMultipleSelection = false
            picker.modalPresentationStyle = .formSheet
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    func addScriptButtonWasTapped() {
        print("didTapPlus")
        
        let actionSheet = UIAlertController(title: "Attach a document", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Go to documents folder", style: .default, handler: { [weak self] _ in
            let picker = UIDocumentPickerViewController(forOpeningContentTypes: self!.type)
            picker.delegate = self?.scriptsTableView
            picker.allowsMultipleSelection = false
            picker.modalPresentationStyle = .formSheet
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    
}
