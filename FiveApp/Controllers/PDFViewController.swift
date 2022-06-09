//
//  PDFViewController.swift
//  FiveApp
//
//  Created by Barbara Kos on 09.06.2022..
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    var data: Data!
    var mainView: PDFView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func setData(data: Data) {
        self.data = data
        buildViews()
    }
    
    func buildViews() {
        mainView = PDFView()
        
        if let pdfDocument = PDFDocument(data: data) {
            mainView.autoScales = true
            mainView.displayMode = .singlePageContinuous
            mainView.displayDirection = .vertical
            mainView.document = pdfDocument
            
        }
        view.addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
    
    


}
