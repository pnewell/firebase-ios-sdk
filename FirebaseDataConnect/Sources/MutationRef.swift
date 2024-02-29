// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct MutationRequest: OperationRequest {
  public var operationName: String
  public var variables: (any Codable)?

  public init(operationName: String, variables: (any Codable)? = nil) {
    self.operationName = operationName
    self.variables = variables
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public class MutationRef<ResultDataType: Codable>: OperationRef {
  public var request: any OperationRequest 

  var dataType: ResultDataType.Type

  private var grpcClient: GrpcClient

  init(request: any OperationRequest, dataType: ResultDataType.Type, grpcClient: GrpcClient) {
    self.request = request
    self.dataType = dataType
    self.grpcClient = grpcClient
  }

  public func execute() async throws -> OperationResult<ResultDataType> {
    let results = try await grpcClient.executeMutation(
      request: request as! MutationRequest,
      resultType: ResultDataType.self
    )
    return results
  }
}
