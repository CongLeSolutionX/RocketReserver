//
//  MasterViewController.swift
//  RocketReserver
//
//  Created by Cong Le on 11/13/20.
//

import UIKit
import Apollo
import SDWebImage

class MasterViewController: UIViewController {
  let tableView = UITableView()
  
  var launches = [LaunchListQuery.Data.Launch.Launch]()
  private var lastConnection: LaunchListQuery.Data.Launch?
  private var activeRequest: Cancellable?
  
  
  enum ListSection: Int, CaseIterable {
    case launches
    //TODO: Handling Pigination for Graph
    // case loading
  }
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = .yellow
    setupTableView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.navigationBar.topItem?.title = "Master View Controller - Table"
    
    tableView.dataSource = self
    tableView.delegate = self
    
    // Make the network call to GraphQL
    loadMoreeLaunchesIfTheyExist()
  }
}
// MARK: - setupTableView
extension MasterViewController {
  func setupTableView() {
    view.addSubview(tableView)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
      ]
    )
  }
}

extension MasterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    guard let listSection = ListSection(rawValue: indexPath.section) else {
      assertionFailure("Invalid section")
      return
    }
    switch listSection {
    case .launches:
      let detailVC = DetailViewController()
      let launch = launches[indexPath.row]
      detailVC.launchID = launch.id
      
      /// Reference: https://www.swiftbysundell.com/tips/showing-view-controllers
      /// not prefer to use push
      //navigationController?.pushViewController(detailVC, animated: true)
      /// prefer using show view controller
      show(detailVC, sender: self)
    }
  }
}
// MARK: - UITableViewDataSource
extension MasterViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return  ListSection.allCases.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let listSection = ListSection(rawValue: section) else {
      assertionFailure("Invalid section")
      return 0
    }
    
    switch listSection {
    case .launches:
      return self.launches.count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =  tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    
    cell.imageView?.image = nil
    cell.textLabel?.text = nil
    cell.detailTextLabel?.text = nil
    
    guard let listSection = ListSection(rawValue: indexPath.section) else {
      assertionFailure("Invalid section")
      return cell
    }
    
    switch listSection {
    case .launches:
      let launch = self.launches[indexPath.row]
      cell.textLabel?.text = launch.mission?.name
      cell.detailTextLabel?.text = launch.site
      
      let placeHolder = UIImage.safetyUnwrap(withName: "placeholder")
      
      if let missionPatch = launch.mission?.missionPatch {
        if let imageUrlString = URL(string: missionPatch) {
          cell.imageView?.sd_setImage(with: imageUrlString, placeholderImage: placeHolder)
        }
      } else {
        cell.imageView?.image = placeHolder
      }
    }
    return cell
  }
}

// MARK: - Helpers
extension MasterViewController {
  private func showErrorAlert(title: String, message: String) {
    let alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    self.present(alert, animated: true)
  }
  
  private func loadMoreLaunches(from cursor: String?) {
    activeRequest = Network.shared.apollo.fetch(
      query: LaunchListQuery(cursor: cursor)
    ) { [weak self] result in
        
        guard let self = self else { return }
        
      self.activeRequest = nil
        defer {
          self.tableView.reloadData()
        }
        
        switch result {
        case .success(let graphQLResult):
          // Get the data result from GraphQL
          if let launchConnection = graphQLResult.data?.launches {
            self.lastConnection = launchConnection
            self.launches.append(contentsOf: launchConnection.launches.compactMap { $0 })
          }
          
          // Get the errors received from GraphQL and pop up alert message
          if let errors = graphQLResult.errors {
            let message = errors
              .map { $0.localizedDescription}
              .joined(separator: "\n")
            self.showErrorAlert(title: "GraphQL Error(s)", message: message)
          }
        case .failure(let error):
          self.showErrorAlert(title: "Network Error", message: error.localizedDescription)
        }
      }
  }
  
  private func loadMoreeLaunchesIfTheyExist() {
    guard let connection = self.lastConnection else {
      // We dont have stored launch details, load from scratch
      self.loadMoreLaunches(from: nil)
      return
    }
    
    guard connection.hasMore else {
      // No more launches to fetch
      return
    }
    
    loadMoreLaunches(from: connection.cursor)
  }
}
