//
//  LoginViewController.swift
//  RocketReserver
//
//  Created by Cong Le on 1/18/21.
//

import UIKit
import KeychainSwift

class LoginViewController: UIViewController {
 
  static let loginKeychainKey = "login"
  
  lazy private var emailTextField: UITextField = {
    let text = UITextField()
    text.placeholder = "Enter your email..."
    text.borderStyle = .roundedRect
    text.backgroundColor = .white
    text.translatesAutoresizingMaskIntoConstraints = false
    return text
  }()
  
  lazy private var errorLabel: UILabel = {
    let label = UILabel()
    label.textColor = .red
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy private var submitButton: UIButton = {
    let button = UIButton(type: .system)
    button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  lazy var cancelButton: UIBarButtonItem = {
    let button = UIBarButtonItem()
    button.title = "Cancel"
    button.style = .plain
    button.target = self
    button.action = #selector(cancelTapped)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Login"
    view.backgroundColor = .systemBackground
    navigationItem.leftBarButtonItem = cancelButton
    enableSubmitButton(true)
    setupView()
  }
  
}

extension LoginViewController {
  func setupView() {
    view.addSubview(emailTextField)
    view.addSubview(errorLabel)
    view.addSubview(submitButton)
    
    NSLayoutConstraint.activate([
      emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
      emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
      emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
      
      errorLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10),
      errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      
      submitButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
      submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
    ])
  }
}

extension LoginViewController {
  private func enableSubmitButton(_ isEnabled: Bool) {
    submitButton.isEnabled = isEnabled
    
    if isEnabled {
      submitButton.setTitle("Submit", for: .normal)
    } else {
      submitButton.setTitle("Submitting...", for: .normal)
    }
  }
  
  // simple validation for email
  private func validate(email: String) -> Bool {
    return email.contains("@")
  }
}

extension LoginViewController {
  @objc func cancelTapped() {
    self.dismiss(animated: true)
  }
  
  @objc func submitTapped() {
    errorLabel.text = nil
    enableSubmitButton(false)
    
    guard let email = emailTextField.text else {
      errorLabel.text = "Please enter an email address..."
      enableSubmitButton(true)
      return
    }
    
    guard validate(email: email) else {
      errorLabel.text = "Please enter a valid email."
      enableSubmitButton(true)
      return
    }
    
    Network.shared.apollo.perform(mutation: LoginMutation(email: email)) {[weak self] result in
      defer {
        self?.enableSubmitButton(true)
      }
      
      switch result {
      case .success(let graphQLResult):
        if let token = graphQLResult.data?.login {
          let keychain = KeychainSwift()
          keychain.set(token, forKey: LoginViewController.loginKeychainKey)
          self?.dismiss(animated: true)
        }
        
        if let errors = graphQLResult.errors {
          print("Errors from GraphQl server are: \(errors)")
        }
      case .failure(let error):
        print("Failed to login to GraphQL server with given email with error: \(error.localizedDescription)")
      }
    }
  }
}
