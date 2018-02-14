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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Список новостей"
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadData()
    }
    
    func loadData() {
        if self.isFirstLoad {
            //load from cache
        }
        
        APIInteractor.shared.getNews(pagination: self.pagination) { [unowned self] (news, err) in
            if err == nil {
                self.isFirstLoad = false
                self.pagination = self.getNextPagination()
                guard let news = news else { return }
                if news.count > 0 {
                    self.titles.append(contentsOf: news)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            } else {
                //show error
            }
        }
        
    }
    
    func getNextPagination() -> APIInteractor.Pagination {
        return APIInteractor.Pagination(first: self.pagination.last,
                                        last: self.pagination.last + self.paginationStep)
    }
}

extension MainScreenVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row >= self.titles.count-1 {
            self.loadData()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: MainScreenTableViewCell.reuseID,
                                                 for: indexPath) as! MainScreenTableViewCell
        
        cell.configure(with: self.titles[indexPath.row])
        return cell
    }
    
    
}

extension MainScreenVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destinationController = UIStoryboard(name: DetailScreenVC.sbName, bundle: Bundle.main)
            .instantiateViewController(withIdentifier: DetailScreenVC.sbID) as! DetailScreenVC
        
        destinationController.configureWithNewsID(self.titles[indexPath.row].id)
        
        self.navigationController?.pushViewController(destinationController, animated: true)
        
        
        // go to details
    }
}

