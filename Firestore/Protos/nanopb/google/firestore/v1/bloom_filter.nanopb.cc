/*
 * Copyright 2025 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* Automatically generated nanopb constant definitions */
/* Generated by nanopb-0.3.9.8 */

#include "bloom_filter.nanopb.h"

#include "Firestore/core/src/nanopb/pretty_printing.h"

namespace firebase {
namespace firestore {

using nanopb::PrintEnumField;
using nanopb::PrintHeader;
using nanopb::PrintMessageField;
using nanopb::PrintPrimitiveField;
using nanopb::PrintTail;

/* @@protoc_insertion_point(includes) */
#if PB_PROTO_HEADER_VERSION != 30
#error Regenerate this file with the current version of nanopb generator.
#endif



const pb_field_t google_firestore_v1_BitSequence_fields[3] = {
    PB_FIELD(  1, BYTES   , SINGULAR, POINTER , FIRST, google_firestore_v1_BitSequence, bitmap, bitmap, 0),
    PB_FIELD(  2, INT32   , SINGULAR, STATIC  , OTHER, google_firestore_v1_BitSequence, padding, bitmap, 0),
    PB_LAST_FIELD
};

const pb_field_t google_firestore_v1_BloomFilter_fields[3] = {
    PB_FIELD(  1, MESSAGE , OPTIONAL, STATIC  , FIRST, google_firestore_v1_BloomFilter, bits, bits, &google_firestore_v1_BitSequence_fields),
    PB_FIELD(  2, INT32   , SINGULAR, STATIC  , OTHER, google_firestore_v1_BloomFilter, hash_count, bits, 0),
    PB_LAST_FIELD
};


/* Check that field information fits in pb_field_t */
#if !defined(PB_FIELD_32BIT)
/* If you get an error here, it means that you need to define PB_FIELD_32BIT
 * compile-time option. You can do that in pb.h or on compiler command line.
 *
 * The reason you need to do this is that some of your messages contain tag
 * numbers or field sizes that are larger than what can fit in 8 or 16 bit
 * field descriptors.
 */
PB_STATIC_ASSERT((pb_membersize(google_firestore_v1_BloomFilter, bits) < 65536), YOU_MUST_DEFINE_PB_FIELD_32BIT_FOR_MESSAGES_google_firestore_v1_BitSequence_google_firestore_v1_BloomFilter)
#endif

#if !defined(PB_FIELD_16BIT) && !defined(PB_FIELD_32BIT)
/* If you get an error here, it means that you need to define PB_FIELD_16BIT
 * compile-time option. You can do that in pb.h or on compiler command line.
 *
 * The reason you need to do this is that some of your messages contain tag
 * numbers or field sizes that are larger than what can fit in the default
 * 8 bit descriptors.
 */
PB_STATIC_ASSERT((pb_membersize(google_firestore_v1_BloomFilter, bits) < 256), YOU_MUST_DEFINE_PB_FIELD_16BIT_FOR_MESSAGES_google_firestore_v1_BitSequence_google_firestore_v1_BloomFilter)
#endif


std::string google_firestore_v1_BitSequence::ToString(int indent) const {
    std::string tostring_header = PrintHeader(indent, "BitSequence", this);
    std::string tostring_result;

    tostring_result += PrintPrimitiveField("bitmap: ",
        bitmap, indent + 1, false);
    tostring_result += PrintPrimitiveField("padding: ",
        padding, indent + 1, false);

    bool is_root = indent == 0;
    if (!tostring_result.empty() || is_root) {
      std::string tostring_tail = PrintTail(indent);
      return tostring_header + tostring_result + tostring_tail;
    } else {
      return "";
    }
}

std::string google_firestore_v1_BloomFilter::ToString(int indent) const {
    std::string tostring_header = PrintHeader(indent, "BloomFilter", this);
    std::string tostring_result;

    if (has_bits) {
        tostring_result += PrintMessageField("bits ", bits, indent + 1, true);
    }
    tostring_result += PrintPrimitiveField("hash_count: ",
        hash_count, indent + 1, false);

    std::string tostring_tail = PrintTail(indent);
    return tostring_header + tostring_result + tostring_tail;
}

}  // namespace firestore
}  // namespace firebase

/* @@protoc_insertion_point(eof) */
