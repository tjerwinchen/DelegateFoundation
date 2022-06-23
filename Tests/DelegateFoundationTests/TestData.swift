// TestData.swift
//
// Copyright (c) 2022 Codebase.Codes
// Created by Theo Chen on 2022.
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
import DelegateFoundation
import XCTest

// MARK: - SomeType

class SomeType {
  weak var delegate: SomeTypeDelegate?

  func callDelegationOne() {
    delegate?.someType(self, withDelegationOne: 1)
  }

  func callDelegationTwo() {
    delegate?.someType(self, withDelegationTwo: #function)
  }
}

// MARK: - SomeTypeDelegate

protocol SomeTypeDelegate: AnyObject {
  func someType(_ someType: SomeType, withDelegationOne: Int)
  func someType(_ someType: SomeType, withDelegationTwo: String)
}

// MARK: - SomeTypeImplementation

class SomeTypeImplementation: SomeTypeDelegate {
  var withDelegationOneCount = 0

  var withDelegationTwoCount = 0

  func someType(_ someType: SomeType, withDelegationOne: Int) {
    withDelegationOneCount += 1
  }

  func someType(_ someType: SomeType, withDelegationTwo: String) {
    withDelegationTwoCount += 1
  }
}

// MARK: - SomeTypeDelegateProxy

final class SomeTypeDelegateProxy: DelegateProxy<SomeType, SomeTypeDelegate>, DelegateProxyProtocol, SomeTypeDelegate {
  let delegationOneRelay = PassthroughSubject<Int, Never>()

  let delegationTwoRelay = PassthroughSubject<String, Never>()

  static func setProxyDelegate(_ object: SomeType, to proxy: SomeTypeDelegateProxy) {
    object.delegate = proxy
  }

  static func createProxy(for object: SomeType) -> SomeTypeDelegateProxy {
    SomeTypeDelegateProxy(object: object, delegateProxyType: SomeTypeDelegateProxy.self)
  }

  static func forwardToDelegate(for object: SomeType) -> SomeTypeDelegate? {
    object.delegate
  }

  func someType(_ someType: SomeType, withDelegationOne: Int) {
    delegationOneRelay.send(withDelegationOne)

    forwardToDelegate?.someType(someType, withDelegationOne: withDelegationOne)
  }

  func someType(_ someType: SomeType, withDelegationTwo: String) {
    delegationTwoRelay.send(withDelegationTwo)

    forwardToDelegate?.someType(someType, withDelegationTwo: withDelegationTwo)
  }
}

// MARK: Delegable extension for `SomeType`

extension Delegable where Base: SomeType {
  var delegationOne: AnyPublisher<Int, Never> {
    SomeTypeDelegateProxy.proxy(for: wrappedValue).delegationOneRelay.eraseToAnyPublisher()
  }

  var delegationTwo: AnyPublisher<String, Never> {
    SomeTypeDelegateProxy.proxy(for: wrappedValue).delegationTwoRelay.eraseToAnyPublisher()
  }
}
