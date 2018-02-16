//
//  MainScreenVC.swift
//  News
//
//  Created by Sergey Roslyakov on 2/11/18.
//  Copyright © 2018 Sergey Roslyakov. All rights reserved.
//

import UIKit

class MainScreenVC: UIViewController {

    var titles = [Title]()
    var pagination = APIInteractor.Pagination(first: 0, last: 20)
    let paginationStep = 20
    var isFirstLoad = true
    var isRefreshing = false
    
    fileprivate let cellActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
                                 action:#selector(self.handleRefresh(_:)),
                                 for: .valueChanged)
        refreshControl.tintColor = .black
        
        return refreshControl
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Список новостей"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addSubview(self.refreshControl)
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
        self.setupActivityIndicatorForCell()
    }
    
    func loadData() {
        if self.isFirstLoad {
            self.activityIndicator.startAnimating()
            self.titles = CoreDataManager.shared.getAllNewsTitles()
            self.tableView.reloadData()
            if self.titles.count > 0 {
                self.activityIndicator.stopAnimating()
            }
        }
        
        APIInteractor.shared.getNews(pagination: self.pagination) { [unowned self] (news, err) in
            if err == nil {
                DispatchQueue.main.async {
                    self.setupWithData(news)
                }
            } else {
                DispatchQueue.main.async {
                    self.showAlertWithError(err)
                }                
                print(err ?? "Error")
            }
        }
    }
    
    func setupWithData(_ news:[Title]?) {
        self.pagination = self.getNextPagination()
        guard let news = news else { return }
        if news.count > 0 {
            if self.isRefreshing {
                self.titles.removeAll()
                self.isRefreshing = false
            }
            if self.isFirstLoad {
                self.isFirstLoad = false
                self.titles.removeAll()
            }
            self.titles.append(contentsOf: news)
            self.dataIsLoaded()
        } else {
            self.tableView.tableFooterView?.isHidden = true
        }
    }
    
    func showAlertWithError(_ err:NSError?) {
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
        var additionalMessage = ""
        if self.titles.count > 0 {
            additionalMessage = "\nВы по-прежнему можете просматривать сохраненные новости"
        }
        
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
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.pagination = APIInteractor.Pagination(first: 0, last: 20)
        self.isRefreshing = true
        self.loadData()
    }
    
    func dataIsLoaded() {
        self.tableView.reloadData()
        self.activityIndicator.stopAnimating()
        self.refreshControl.endRefreshing()
    }
    
    func getNextPagination() -> APIInteractor.Pagination {
        return APIInteractor.Pagination(first: self.pagination.last,
                                        last: self.pagination.last + self.paginationStep)
    }
    
    func setupActivityIndicatorForCell() {
        self.cellActivityIndicator.color = .black
        self.cellActivityIndicator.startAnimating()
        self.cellActivityIndicator.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
    }
}

extension MainScreenVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenTableViewCell.reuseID,
                                                 for: indexPath) as! MainScreenTableViewCell
        
        cell.configure(with: self.titles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

extension MainScreenVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destinationController = UIStoryboard(name: DetailScreenVC.sbName, bundle: Bundle.main)
            .instantiateViewController(withIdentifier: DetailScreenVC.sbID) as! DetailScreenVC
        
        destinationController.newsId = self.titles[indexPath.row].id
        self.navigationController?.pushViewController(destinationController, animated: true)
        CoreDataManager.shared.increaseTitleViewsCount(byId: self.titles[indexPath.row].id)
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && !self.isFirstLoad {
            self.loadData()
            self.tableView.tableFooterView = self.cellActivityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
    }
}

