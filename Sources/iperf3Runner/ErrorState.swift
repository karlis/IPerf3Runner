//
//  ErrorState.swift
//
//
//  Created by Karlis Lukstins on 10/05/2020.
//

extension IPerf3Runner {
  public enum ErrorState: Int {
    case noError = 0
    case couldntInitializeTest = 1
    case serverIsBusy = 2
    case cannotConnectToTheServer = 3
    case unknown = 4
  }
}
