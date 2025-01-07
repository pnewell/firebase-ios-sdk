// Copyright 2025 Google LLC
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

#ifndef FIREBASE_PIPELINE_SOURCE_H
#define FIREBASE_PIPELINE_SOURCE_H

#include <memory>
#include <vector>
#include "pipeline.h"

namespace firebase {
namespace firestore {

namespace api {

class Firestore;
class DocumentReference;

class PipelineSource {
 public:
  PipelineSource(std::shared_ptr<Firestore> firestore);

  Pipeline GetCollection(std::string collection_path) const;

 private:
  std::shared_ptr<Firestore> firestore_;
};

}  // namespace api

}  // namespace firestore
}  // namespace firebase

#endif  // FIREBASE_PIPELINE_SOURCE_H
