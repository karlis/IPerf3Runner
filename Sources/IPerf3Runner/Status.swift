//
//  Status.swift
//  
//
//  Created by Karlis Lukstins on 10/05/2020.
//

import Foundation

extension IPerf3Runner {
  public enum Status {
    case completed(Double)
    case next(Double)
    case error(ErrorState)
  }
}
