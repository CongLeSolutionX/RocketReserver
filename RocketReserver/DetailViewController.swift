//
//  DetailViewController.swift
//  RocketReserver
//
//  Created by Cong Le on 12/3/20.
//

import UIKit
import Apollo
import SDWebImage

class DetailViewController: UIViewController {
  lazy var missionPatchImageView: UIImageView = {
    let image = UIImageView()
    image.translatesAutoresizingMaskIntoConstraints = false
    return image
  }()
  
  lazy var missionNameLabel: UILabel = {
    let label = UILabel()
    label.text = "Loading..."
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var rocketNameLabel: UILabel = {
    let label = UILabel()
    label.text = nil
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var launchSiteLabel: UILabel = {
    let label = UILabel()
    label.text = nil
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var bookCancelButton: UIBarButtonItem = {
    let button = UIBarButtonItem()
    button.title = "Book now!"
    button.style = .plain
    button.target = self
    button.action = #selector(bookTapped)
    return button
  }()
  
  var launchId: GraphQLID? {
    didSet {
      loadLaunchDetails()
    }
  }
  
  lazy var detailDescriptionLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private var launch: LaunchDetailsQuery.Data.Launch? {
    didSet {
      configureView()
    }
  }
  
  override func loadView() {
    super.loadView()
    title = "Detail View Controller"
    view.backgroundColor = .green
    navigationItem.rightBarButtonItem = bookCancelButton
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }
  
  @objc func bookTapped() {
    print("I am here babe!")
  }
}

// MARK: - setup views
extension DetailViewController {
  func configureView() {
    view.addSubview(missionPatchImageView)
    guard
      let launch = launch else {
      return
    }
    
    guard let missionPatch = launch.mission?.missionPatch else {
      print("Failed to parse the data from graph")
      return
    }
    
    missionPatchImageView.sd_setImage(with: URL(string: missionPatch), placeholderImage: UIImage(named: "placeholder"))

    NSLayoutConstraint.activate([
      missionPatchImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      missionPatchImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
      missionPatchImageView.heightAnchor.constraint(equalToConstant: 128),
      missionPatchImageView.widthAnchor.constraint(equalToConstant: 128)
    ])
  }
  
  private func loadLaunchDetails(forceReload: Bool = false) {
    // update the user interface for the detail item
    let label = detailDescriptionLabel
    
    guard let launchId = launchId else { return }
    
    label.text = "Launch \(launchId)"
    
    let cachePolicy: CachePolicy
    if forceReload {
      cachePolicy = .fetchIgnoringCacheCompletely
    } else {
      cachePolicy = .returnCacheDataElseFetch
    }
    
    let query = LaunchDetailsQuery(id: launchId)
    
    Network.shared.apollo.fetch(query: query, cachePolicy: cachePolicy) { [weak self] result in
      
      guard let self = self else { return }
      switch result {
      case .success(let graphQLResult):
        // Assiging the data received from server
        guard let launch = graphQLResult.data?.launch else {
          print("Failed to parse the launch data")
          return
        }
        self.launch = launch
        
        // In case, GraphQL return errors
        if let errors = graphQLResult.errors {
          self.showAlertForErrors(errors)
        }
        
      case .failure(let error):
        self.showAlert(title: "Network Error", message: error.localizedDescription)
      }
    }
    
    
    view.addSubview(detailDescriptionLabel)
    NSLayoutConstraint.activate([
      detailDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      detailDescriptionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ]
    )
  }
}
