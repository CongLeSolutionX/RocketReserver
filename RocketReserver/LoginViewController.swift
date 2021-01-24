//
//  LoginViewController.swift
//  RocketReserver
//
//  Created by Cong Le on 1/18/21.
//

import UIKit

class LoginViewController: UIViewController {
 
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
    label.text = "Error"
    label.textColor = .red
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  lazy private var submitButton: UIButton = {
    let button = UIButton(type: .system)
    button.addTarget(self, action: #selector(handleSubmitButton), for: .touchUpInside)
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
  
  @objc func handleSubmitButton() {
    print("printed")
  }
}
