//
//  DetailScreenVC.swift
//  News
//
//  Created by Sergey Roslyakov on 2/13/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//

import UIKit

class DetailScreenVC: UIViewController {

    static let sbName = "DetailScreen"
    static let sbID = "DetailScreenSBID"
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    
    private let dateFormatter = DateFormatter(withFormat: "dd MMMM YYYY, HH:mm", locale: "ru")
    fileprivate var isFirstload:Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self

    }

    
    func configureWithNewsID(_ id:String) {

        //at first load from cache
        
        
        APIInteractor.shared.getDetailNews(byID: id) { (newsDetail, error) in
            if error == nil {
                guard let newsDetail = newsDetail else { return }
                DispatchQueue.main.async {
                    self.captionLabel.text = newsDetail.title.text
                    let date = Date(timeIntervalSince1970: Double(newsDetail.title.publicationDate.milliseconds)/1000)
                    self.dateTimeLabel.text = self.dateFormatter.string(from: date)
                    self.loadData(withHtmlString: newsDetail.content)
                }
                
            } else {
                //show error
            }
        }
    }
    
    func loadData(withHtmlString string:String) {
        webView.loadHTMLString(string, baseURL: URL.init(string: ""))
        webView.scrollView.isScrollEnabled = false
    }

}

extension DetailScreenVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.isFirstload = false
        var frame = webView.frame
        frame.size.height = 1
        webView.frame = frame
        let fittingSize = webView.sizeThatFits(CGSize.init(width: UIScreen.main.bounds.size.width - 32,
                                                           height: CGFloat.greatestFiniteMagnitude))
        frame.size.height = fittingSize.height
        webView.frame = frame
        webViewHeightConstraint.constant = fittingSize.height
    }
    
    func webView(_ webView: UIWebView,
                 shouldStartLoadWith request: URLRequest,
                 navigationType: UIWebViewNavigationType) -> Bool {
        if self.isFirstload {
            return true
        }
        return false
    }
}
