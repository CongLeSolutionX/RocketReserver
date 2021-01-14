//
//  Network.swift
//  RocketReserver
//
//  Created by Cong Le on 11/13/20.
//

import Foundation
import Apollo

/*
 We will use this playground for GraphQL:
 https://apollo-fullstack-tutorial.herokuapp.com/


 Use following documentation make GraphQL syntax highlighted:
 https://github.com/apollographql/xcode-graphql
 Notes:
 - In Swift, if you don't annotate a property's type with either a question mark or an exclamation point, that property is non-nullable.
 - In GraphQL, if you don't annotate a field's type with an exclamation point, that field is considered nullable. This is because GraphQL fields are nullable by default.
 */


class Network {
  static let shared = Network()
    
  private(set) lazy var apollo = ApolloClient(url: URL(string:"https://apollo-fullstack-tutorial.herokuapp.com")!)
}
