/*
 *
 * Copyright 2016, Google Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */
import gRPC
import Foundation

let address = "localhost:8001"
let host = "foo.test.google.fr"
let message = "hello, server!".data(using: .utf8)

gRPC.initialize()
print("gRPC version", gRPC.version())

do {
  let c = gRPC.Channel(address:address)
  let steps = 3
  for i in 0..<steps {
    let done = NSCondition()

    let method = (i < steps-1) ? "/hello" : "/quit"
    print("calling " + method)
    let call = c.makeCall(method)

    let metadata = Metadata([["x": "xylophone"],
                             ["y": "yu"],
                             ["z": "zither"]])


    try! call.perform(message: message!, metadata:metadata) {
      (response) in
      print("status:", response.statusCode)
      print("statusMessage:", response.statusMessage!)
      if let resultData = response.resultData {
        print("message: \(resultData)")
      }

      let initialMetadata = response.initialMetadata!
      for i in 0..<initialMetadata.count() {
        print("INITIAL METADATA ->", initialMetadata.key(index:i), ":", initialMetadata.value(index:i))
      }

      let trailingMetadata = response.trailingMetadata!
      for i in 0..<trailingMetadata.count() {
        print("TRAILING METADATA ->", trailingMetadata.key(index:i), ":", trailingMetadata.value(index:i))
      }
      done.lock()
      done.signal()
      done.unlock()
    }
    done.lock()
    done.wait()
    done.unlock()
  }
}

print("Done")
