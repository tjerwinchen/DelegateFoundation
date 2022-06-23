# DelegateProxy

Inspired by `RxCocoa`, this is a lightweight implementation of `DelegateProxy`. It is aimed to implement delegation in a simple way. We can wrap the delegate implementation in a declarative way (ie, combine).

## Usage Example

Suppose we have `SomeType` and `SomeTypeDelegate`.

```swift
class SomeType {
  weak var delegate: SomeTypeDelegate?

  func callDelegationOne() {
    delegate?.someType(self, withDelegationOne: 1)
  }

  func callDelegationTwo() {
    delegate?.someType(self, withDelegationTwo: #function)
  }
}

protocol SomeTypeDelegate: AnyObject {
  func someType(_ someType: SomeType, withDelegationOne: Int)
  func someType(_ someType: SomeType, withDelegationTwo: String)
}
```

The implementation of the delegate is in `SomeTypeImplementation`.


```swift
class SomeTypeImplementation: SomeTypeDelegate {
  func someType(_ someType: SomeType, withDelegationOne: Int) {
    print(withDelegationOne)
  }
  
  func someType(_ someType: SomeType, withDelegationTwo: String) {
    print(withDelegationTwo)
  }
}
```

Now, we can use another way to make it.

Firstly, Adopting DelegateProxy for `SomeTypeDelegate`

```swift
import DelegateProxy

final class SomeTypeDelegateProxy: DelegateProxy<SomeType, SomeTypeDelegate>, DelegateProxyProtocol, SomeTypeDelegate {
  let delegationOneRelay = PassthroughRelay<Int>()

  let delegationTwoRelay = PassthroughRelay<String>()

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
```

Then, extend `Delegable` for `SomeType`

```swift
import DelegateProxy

extension Delegable where Base: SomeType {
  var delegationOne: RelayPublisher<Int> {
    SomeTypeDelegateProxy.proxy(for: wrappedValue).delegationOneRelay.eraseToAnyPublisher()
  }

  var delegationTwo: RelayPublisher<String> {
    SomeTypeDelegateProxy.proxy(for: wrappedValue).delegationTwoRelay.eraseToAnyPublisher()
  }
}
```

Finally, the call site deal with the `SomeTypeDelegate` like this:

```swift
import DelegateProxy

@Delegable
var someType = SomeType()

$someType.delegationOne
.receive(on: Schedulers.main)
.sink { value in
  // implemente delegate here
}
.store(in: &cancellables)  
```


