//
//  File.swift
//  
//
//  Created by Aashish Patil on 10/18/23.
//

import Foundation

import FirebaseCore


@available (macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public class DataConnect {

  private var app: FirebaseApp
  fileprivate var serverSettings: ServerSettings = ServerSettings.defaults
  private var serviceConfig: ServiceConfig

  private var emulatorSettings: ServerSettings?

  private var grpcClient: GrpcClient
  private var operationsManager: OperationsManager

  //MARK: Init

  public class func dataConnect(app: FirebaseApp, serverSettings: ServerSettings, serviceConfig: ServiceConfig) -> DataConnect {

    let dataConnect = DataConnect(app: app, serviceConfig: serviceConfig, serverSettings: serverSettings)
    return dataConnect
  }


  public class func dataConnect(serverSettings: ServerSettings, serviceConfig: ServiceConfig) throws -> DataConnect {

    guard let app = FirebaseApp.app() else {
      throw DataConnectError.appNotConfigured
    }

    return DataConnect(app: app, serviceConfig: serviceConfig, serverSettings: serverSettings)
  }

  public class func dataConnect(serviceConfig: ServiceConfig) -> DataConnect{
    guard let app = FirebaseApp.app() else {
      fatalError("No default Firebase App present")
    }

    return DataConnect(app: app, serviceConfig: serviceConfig, serverSettings: ServerSettings.defaults)
  }

  public class func dataConnect(app: FirebaseApp, serviceConfig: ServiceConfig) -> DataConnect {
    return DataConnect(app: app, serviceConfig: serviceConfig, serverSettings: ServerSettings.defaults)
  }

  internal init(app: FirebaseApp, serviceConfig: ServiceConfig, serverSettings: ServerSettings ) {
    self.app = app
    self.serverSettings = serverSettings
    self.serviceConfig = serviceConfig

    guard let projectID = app.options.projectID else {
      fatalError("Firebase DataConnect requires the projectID to be set in the app options")
    }

    self.grpcClient = GrpcClient(projectId: projectID, serverSettings: serverSettings, serviceConfig: serviceConfig)
    self.operationsManager = OperationsManager(grpcClient: grpcClient)
  }

  public func useEmulator(host: String = "localhost",
                          port: Int = 9400) {
    emulatorSettings = ServerSettings(hostName: host, port: port, sslEnabled: false)

    //TODO - shutdown grpc client 
    //self.grpcClient.close
    //self.operations.close

    guard let projectID = app.options.projectID else {
      fatalError("Firebase DataConnect requires the projectID to be set in the app options")
    }

    self.grpcClient = GrpcClient(projectId: projectID, serverSettings: emulatorSettings!, serviceConfig: serviceConfig)
    self.operationsManager = OperationsManager(grpcClient: grpcClient)
  }

  //MARK: Operations
  public func getQueryRef<ResultDataType: Codable>(request: QueryRequest, resultsDataType: ResultDataType.Type) -> QueryRef<ResultDataType> {
    return operationsManager.queryRef(for: request, with: resultsDataType)
    //return QueryRef(request: request, dataType: resultsDataType, grpcClient: grpcClient)
  }

  public func getMutationRef<ResultDataType: Codable>(request: MutationRequest, resultsDataType: ResultDataType.Type) -> MutationRef<ResultDataType> {
    return operationsManager.mutationRef(for: request, with: resultsDataType)
  }

}
