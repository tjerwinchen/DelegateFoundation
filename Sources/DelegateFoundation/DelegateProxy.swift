// DelegateProxy.swift
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

import Foundation

/// Inspired by RxCocoa, base class for `DelegateProxyProtocol` protocol.
///
/// Any custom delegate proxy needs to inherite from `DelegateProxy` and conform to `DelegateProxyProtocol`, for example,
///
///     final class SomeTypeDelegateProxy: DelegateProxy<SomeType, SomeTypeDelegate>, DelegateProxyProtocol, SomeTypeDelegate {
///       let delegationOneRelay = PassthroughRelay<Int>()
///       let delegationTwoRelay = PassthroughRelay<String>()
///
///       static func setProxyDelegate(_ object: SomeType, to proxy: SomeTypeDelegateProxy) {
///         object.delegate = proxy
///       }
///
///       static func createProxy(for object: SomeType) -> SomeTypeDelegateProxy {
///         SomeTypeDelegateProxy(object: object, delegateProxyType: SomeTypeDelegateProxy.self)
///       }
///
///       static func forwardToDelegate(for object: SomeType) -> SomeTypeDelegate? {
///         object.delegate
///       }
///
///       func someType(_ someType: SomeType, withDelegationOne: Int) {
///         delegationOneRelay.send(withDelegationOne)
///
///         forwardToDelegate?.someType(someType, withDelegationOne: withDelegationOne)
///       }
///
///       func someType(_ someType: SomeType, withDelegationTwo: String) {
///         delegationTwoRelay.send(withDelegationTwo)
///
///         forwardToDelegate?.someType(someType, withDelegationTwo: withDelegationTwo)
///       }
///     }
///
open class DelegateProxy<Object: AnyObject, Delegate>: NSObject {
  // MARK: Lifecycle

  /// Initializes new instance.
  ///
  /// - Parameters:
  ///   - object: the object that holds `DelegateProxy` as associated object.
  ///   - delegateProxy: the `DelegateProxy` who deals with all delegate methods
  ///
  public init<Proxy: DelegateProxyProtocol>(object: Object, delegateProxyType: Proxy.Type) where Proxy: DelegateProxy<Object, Delegate>, Proxy.Object == Object, Proxy.Delegate == Delegate {
    self.currentObject = object
    super.init()

    if let proxy = self as? Proxy {
      self.forwardToDelegate = delegateProxyType.forwardToDelegate(for: object)
      delegateProxyType.setProxyDelegate(currentObject, to: proxy)
    }
  }

  // MARK: Public

  /// The delegate that needs to be forwarded (forward-to-delegate), that is, the already set delegate of the "object" (if any)\
  ///
  public private(set) var forwardToDelegate: Delegate? {
    get { _forwardToDelegate as? Delegate }
    set { _forwardToDelegate = newValue as AnyObject? }
  }

  // MARK: Private

  private var currentObject: Object

  private weak var _forwardToDelegate: AnyObject?
}
