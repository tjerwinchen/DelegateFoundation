// DelegateProxyProtocol.swift
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

// MARK: - DelegateProxyProtocol

/// Inspired by the `RxCocoa`, `DelegateProxyProtocol` protocol enables using combine with object that have a delegate registered.
public protocol DelegateProxyProtocol: AnyObject {
  associatedtype Object: AnyObject
  associatedtype Delegate

  /// Create `DelegateProxy` for an object
  ///
  /// - Parameters:
  ///   - object: an object that holds a `Delegate`
  ///
  static func createProxy(for object: Object) -> Self

  /// Set the delegate of `object` to proxy
  ///
  /// - Parameters:
  ///   - object: an object that holds a `Delegate`
  ///   - proxy: a `DelegateProxy` that will be the delegate of object
  ///
  static func setProxyDelegate(_ object: Object, to proxy: Self)

  /// Get the delegate that needs to be forwarded (forward-to-delegate), that is, the already set delegate of the "object" (if any)
  ///
  /// - Parameters:
  ///   - object: an object that holds a `Delegate`
  ///
  static func forwardToDelegate(for object: Object) -> Delegate?
}

extension DelegateProxyProtocol {
  // swiftlint:disable force_unwrapping
  private static var identifier: UnsafeRawPointer {
    let delegateIdentifier = ObjectIdentifier(Delegate.self)
    let integerIdentifier = Int(bitPattern: delegateIdentifier)
    return UnsafeRawPointer(bitPattern: integerIdentifier)!
  }

  private static func assignedProxy(for object: Object) -> Self? {
    objc_getAssociatedObject(object, identifier) as? Self
  }

  private static func assignProxy(_ proxy: Self, to object: Object) {
    objc_setAssociatedObject(object, identifier, proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }

  /// Get proxy for a specific object
  ///
  /// - Parameters:
  ///   - object: an object that holds a `Delegate`
  public static func proxy(for object: Object) -> Self {
    guard let proxy = Self.assignedProxy(for: object) else {
      let proxy = createProxy(for: object)
      assignProxy(proxy, to: object)
      return proxy
    }
    return proxy
  }
}
