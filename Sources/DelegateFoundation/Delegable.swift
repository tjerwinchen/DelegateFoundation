// Delegable.swift
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

/// Inspired by `RxCocoa`, this is a lightweight implementation of `DelegateProxy`. It is aimed to implement delegation in a simple way. We can wrap the delegate implementation in a declarative way (ie, combine).
///
/// For exampe:
///
///     @Delegable
///     var some = SomeType()
///
///     $someType.delegationOne
///     .receive(on: Schedulers.main)
///     .sink { value in
///       // .......
///     }
///     .store(in: &cancellables)
///
/// Put any specific `Delegable` extension for SomeType here, for example:
///
///     extension Delegable where Base: SomeType {
///       var delegationOne: RelayPublisher<Int> {
///         SomeTypeDelegateProxy.proxy(for: wrappedValue).delegationOneRelay.eraseToAnyPublisher()
///       }
///
///       var delegationTwo: RelayPublisher<String> {
///         SomeTypeDelegateProxy.proxy(for: wrappedValue).delegationTwoRelay.eraseToAnyPublisher()
///       }
///     }
///
@propertyWrapper
public struct Delegable<Base> {
  // MARK: Lifecycle

  public init(wrappedValue: Base) {
    self.base = wrappedValue
  }

  // MARK: Public

  public var wrappedValue: Base {
    base
  }

  public var projectedValue: Self {
    self
  }

  // MARK: Private

  private let base: Base
}
