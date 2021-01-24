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
    label.adjustsFontSizeToFitWidth = true
    label.numberOfLines = 1
    label.lineBreakMode = .byClipping
    label.font = .boldSystemFont(ofSize: 24)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var rocketNameLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontSizeToFitWidth = true
    label.adjustsFontForContentSizeCategory = true
    label.font = .systemFont(ofSize: 20)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy var launchSiteLabel: UILabel = {
    let label = UILabel()
    label.adjustsFontSizeToFitWidth = true
    label.adjustsFontForContentSizeCategory = true
    label.font = .systemFont(ofSize: 14)
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
   // presenting login view controller
    let loginVC = LoginViewController()
    let navigationController = UINavigationController(rootViewController: loginVC)
    navigationController.modalPresentationStyle = .fullScreen
    present(navigationController, animated: true)
  }
}

// MARK: - Setup views using graph data
extension DetailViewController {
  func configureView() {
    view.addSubview(missionPatchImageView)
    view.addSubview(missionNameLabel)
    view.addSubview(rocketNameLabel)
    view.addSubview(launchSiteLabel)
    guard let launch = launch else { return }
    
    guard let missionPatch = launch.mission?.missionPatch else {
      print("Failed to parse the data from graph")
      return
    }
    
    missionPatchImageView.sd_setImage(with: URL(string: missionPatch), placeholderImage: UIImage(named: "placeholder"))
    
    guard let missionName = launch.mission?.name else {
      print("Failed to parse the data from graph")
      return
    }
    missionNameLabel.text = missionName
    title = missionName
    
    guard let rocketName = launch.rocket?.name else {
      print("Failed to parse the data from graph")
      return
    }
    guard let rocketType = launch.rocket?.type else { return }
    rocketNameLabel.text = "🚀 \(rocketName) \(rocketType)"
   
    guard let launchSite = launch.site else { return }
    launchSiteLabel.text = "Launching from \(launchSite)"

    NSLayoutConstraint.activate([
      missionPatchImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      missionPatchImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      missionPatchImageView.heightAnchor.constraint(equalToConstant: 200),
      missionPatchImageView.widthAnchor.constraint(equalToConstant: 200),
      
      missionNameLabel.topAnchor.constraint(equalTo: missionPatchImageView.bottomAnchor, constant: 10),
      missionNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      rocketNameLabel.topAnchor.constraint(equalTo: missionNameLabel.bottomAnchor, constant: 10),
      rocketNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      launchSiteLabel.topAnchor.constraint(equalTo: rocketNameLabel.bottomAnchor, constant: 10),
      launchSiteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
}

// MARK: - Load graph data
extension DetailViewController {
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
  }
}
