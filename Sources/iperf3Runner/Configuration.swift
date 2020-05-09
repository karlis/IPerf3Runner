//
//  Configuration.swift
//
//
//  Created by Karlis Lukstins on 10/05/2020.
//

extension IPerf3Runner {
  public struct Configuration {
    public enum TestType {
      case download, upload
    }

    public var hostname: String
    public var port: Int
    public var duration: Int
    public var streams: Int
    public var type: TestType

    public init(
      hostname: String,
      port: Int,
      duration: Int,
      streams: Int,
      type: TestType
    ) {
      self.hostname = hostname
      self.port = port
      self.duration = duration
      self.streams = streams
      self.type = type
    }
  }
}
