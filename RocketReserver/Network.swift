//
//  Network.swift
//  RocketReserver
//
//  Created by Cong Le on 11/13/20.
//

import Foundation
import Apollo


class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string:"https://apollo-fullstack-tutorial.herokuapp.com")!)
}
