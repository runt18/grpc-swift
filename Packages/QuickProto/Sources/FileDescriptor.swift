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
import Foundation

extension String {
  func stripPrefix(_ prefix: String) -> String {
    if self.hasPrefix(prefix) {
      return self.replacingOccurrences(of: prefix, with: "")
    } else {
      return self
    }
  }
}

/// A collection of descriptors that were read from a compiled .proto file
class FileDescriptor {
  var messageDescriptors : [MessageDescriptor] = []
  var name : String = ""
  var package : String = ""
  var syntax : String = ""

  // the base FileDescriptor is the FileDescriptor for FileDescriptor
  init() {
    for description in _FileDescriptor {
      messageDescriptors.append(MessageDescriptor(description:description))
    }
  }

  // creates a FileDescriptor from a FileDescriptor proto
  init(message:Message) {
    message.forEachField(["message_type"]) { (field) in
      let messageDescriptor = MessageDescriptor(message: field.message())
      messageDescriptors.append(messageDescriptor)
    }
    try! message.forOneField("name") { (field) in
      name = field.string()
    }
    try! message.forOneField("package") { (field) in
      package = field.string()
    }
    try! message.forOneField("syntax") { (field) in
      syntax = field.string()
    }
  }

  // finds and returns a descriptor for a specified message
  func messageDescriptor(name: String) -> MessageDescriptor? {
    // search message descriptors for the desired message
    let messageName = name.stripPrefix("." + self.package + ".")
    for messageDescriptor in messageDescriptors {
      if messageDescriptor.name == messageName {
        return messageDescriptor
      } else {
        let messageName = messageName.stripPrefix(messageDescriptor.name + ".")
        for nestedMessageDescriptor in messageDescriptor.nestedTypes {
          if nestedMessageDescriptor.name == messageName {
            return nestedMessageDescriptor
          }
        }
      }
    }
    return nil
  }
}
