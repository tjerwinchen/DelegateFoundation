// DelegateProxyTests.swift
//
// Copyright (c) 2023 Codebase.Codes
// Created by Theo Chen on 2023.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the  Software), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Combine
@testable import DelegateFoundation
import XCTest

final class DelegateProxyTest: XCTestCase {
  var cancellables = Set<AnyCancellable>()

  let count = 1000

  func test_before_subscribe() throws {
    @Delegable
    var someType = SomeType()

    let dispatchGroup = DispatchGroup()

    var delegationOneCount = 0
    var delegationTwoCount = 0

    DispatchQueue.concurrentPerform(iterations: count) { idx in
      dispatchGroup.enter()
      if idx % 2 == 0 {
        someType.callDelegationOne()
      } else {
        someType.callDelegationTwo()
      }
    }

    $someType.delegationOne
      .receive(on: DispatchQueue.main)
      .sink { _ in
        delegationOneCount += 1
        dispatchGroup.leave()
      }
      .store(in: &cancellables)

    $someType.delegationTwo
      .receive(on: DispatchQueue.main)
      .sink { _ in
        delegationTwoCount += 1
        dispatchGroup.leave()
      }
      .store(in: &cancellables)

    let _ = dispatchGroup.wait(timeout: .now() + 2)
    XCTAssertEqual(0, delegationOneCount)
    XCTAssertEqual(0, delegationTwoCount)
  }

  func test_with_preimplemented_delegate() {
    @Delegable
    var someType = SomeType()

    let someTypeImpl = SomeTypeImplementation()
    someType.delegate = someTypeImpl

    let dispatchGroup = DispatchGroup()

    var delegationOneCount = 0
    var delegationTwoCount = 0

    $someType.delegationOne
      .receive(on: DispatchQueue.main)
      .sink { _ in
        delegationOneCount += 1
        dispatchGroup.leave()
      }
      .store(in: &cancellables)

    $someType.delegationTwo
      .receive(on: DispatchQueue.main)
      .sink { _ in
        delegationTwoCount += 1
        dispatchGroup.leave()
      }
      .store(in: &cancellables)

    DispatchQueue.concurrentPerform(iterations: count) { idx in
      dispatchGroup.enter()

      if idx % 2 == 0 {
        someType.callDelegationOne()
      } else {
        someType.callDelegationTwo()
      }
    }

    dispatchGroup.notify(queue: .main) {
      XCTAssertEqual(self.count / 2, delegationOneCount)
      XCTAssertEqual(self.count / 2, delegationTwoCount)
      XCTAssertEqual(self.count / 2, someTypeImpl.withDelegationOneCount)
      XCTAssertEqual(self.count / 2, someTypeImpl.withDelegationTwoCount)
    }
  }

  func test_without_preimplemented_delegate() {
    @Delegable
    var someType = SomeType()

    let dispatchGroup = DispatchGroup()

    var delegationOneCount = 0
    var delegationTwoCount = 0

    $someType.delegationOne
      .receive(on: DispatchQueue.main)
      .sink { _ in
        delegationOneCount += 1
        dispatchGroup.leave()
      }
      .store(in: &cancellables)

    $someType.delegationTwo
      .receive(on: DispatchQueue.main)
      .sink { _ in
        delegationTwoCount += 1
        dispatchGroup.leave()
      }
      .store(in: &cancellables)

    DispatchQueue.concurrentPerform(iterations: count) { idx in
      dispatchGroup.enter()

      if idx % 2 == 0 {
        someType.callDelegationOne()
      } else {
        someType.callDelegationTwo()
      }
    }

    dispatchGroup.notify(queue: .main) {
      XCTAssertEqual(self.count / 2, delegationOneCount)
      XCTAssertEqual(self.count / 2, delegationTwoCount)
    }
  }
}
