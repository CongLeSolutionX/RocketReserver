//
//  UIImage+Extensions.swift
//  RocketReserver
//
//  Created by Cong Le on 12/3/20.
//

import UIKit

extension UIImage {
  /// Safely unwrap image with error handling
  static func safetyUnwrap(withName name: String) -> UIImage {
    guard let correctImage = UIImage(named: name) else {
      assertionFailure("Fail to initialized \(UIImage.self) named \(name).")
      // return an empty image as a placeholder
      return UIImage()
    }
    return correctImage
  }
}
