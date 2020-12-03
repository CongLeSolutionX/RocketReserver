//
//  ViewController.swift
//  RocketReserver
//
//  Created by Cong Le on 11/13/20.
//

import UIKit
// Example of creating a tableView programmatically
class ViewController: UIViewController {
  let tableView = UITableView()
  
  var character = ["Link", "Zelda", "Ganondorf", "Midna"]
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = .systemBackground
    setupTableView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Detail View Controller" // or 
    //self.navigationController?.navigationBar.topItem?.title = "View Controller"
    tableView.dataSource = self
    
  }
}

//MARK: - setupTableView
extension ViewController {
  func setupTableView() {
    view.addSubview(tableView)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate(
      [
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor)
      ]
    )
  }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return character.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    cell.textLabel?.text = character[indexPath.row]
    return cell
  }
}
