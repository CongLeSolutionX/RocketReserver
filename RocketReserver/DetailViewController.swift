//
//  DetailViewController.swift
//  RocketReserver
//
//  Created by Cong Le on 12/3/20.
//

import UIKit
import Apollo

class DetailViewController: UIViewController {
  var launchID: GraphQLID? {
    didSet {
      self.configureView()
    }
  }
  
  lazy var detailDescriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  override func loadView() {
    super.loadView()
    view.backgroundColor = .green
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Detail View Controller"
  }
  
  func configureView() {
    view.addSubview(detailDescriptionLabel)
    
    NSLayoutConstraint.activate([
        detailDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        detailDescriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
      ]
    )
    // update the user interface for the detail item
    let label = detailDescriptionLabel
    
    guard let id = self.launchID else { return }
    
    label.text = "Launch \(id)"
  }
}
