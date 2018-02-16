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
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private let dateFormatter = DateFormatter(withFormat: "dd MMMM YYYY, HH:mm", locale: "ru")
    fileprivate var isFirstload:Bool = true

    var newsId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        self.activityIndicator.startAnimating()
        self.loadData()
    }

    
    fileprivate func setupWithData(_ newsDetail:NewsDetail?) {
        guard let newsDetail = newsDetail else {
            return
        }
        self.captionLabel.text = newsDetail.title.text
        let date = Date(timeIntervalSince1970: newsDetail.title.publicationDate.milliseconds/1000)
        self.dateTimeLabel.text = self.dateFormatter.string(from: date)
        self.loadData(withHtmlString: newsDetail.content)
    }
    
    fileprivate func loadData() {
        self.setupWithData(CoreDataManager.shared.getNewsDetail(byTitleId: self.newsId))
        APIInteractor.shared.getNewsDetail(byID: self.newsId) { (newsDetail, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.setupWithData(newsDetail)
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlertWithError(error)
                }
            }
        }
    }
    
    fileprivate func loadData(withHtmlString string:String) {
        webView.loadHTMLString(string, baseURL: URL.init(string: ""))
        webView.scrollView.isScrollEnabled = false
    }
    
    fileprivate func showAlertWithError(_ err:NSError?) {
        self.activityIndicator.stopAnimating()
        let additionalMessage = "\nВы по-прежнему можете просматривать сохраненные новости"
        let errorMessage = "\(err?.localizedDescription ?? "") \(additionalMessage)"
        let alert = UIAlertController(title: "Возникла ошибка", message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: {
                
            })
        }))
        alert.addAction(UIAlertAction(title: "Попробовать снова", style: .`default`, handler: { (action) in
            self.loadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }

}

extension DetailScreenVC: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityIndicator.stopAnimating()
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
