//
//  String.swift
//  
//
//  Created by Karlis Lukstins on 10/05/2020.
//

import Foundation

extension String {
  var pointer: UnsafeMutablePointer<Int8>? {
    UnsafeMutablePointer<Int8>(mutating: (self as NSString).utf8String)
  }
}
