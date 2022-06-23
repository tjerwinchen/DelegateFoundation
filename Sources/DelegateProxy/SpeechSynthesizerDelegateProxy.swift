// SpeechSynthesizerDelegateProxy.swift
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

import AVFoundation
import Foundation
import Combine

// MARK: Delegable extension for `AVSpeechSynthesizer`

extension Delegable where Base: AVSpeechSynthesizer {
  public var didStart: AnyPublisher<AVSpeechUtterance, Never> {
    SpeechSynthesizerDelegateProxy.proxy(for: wrappedValue).didStartRelay.eraseToAnyPublisher()
  }

  public var didFinish: AnyPublisher<AVSpeechUtterance, Never> {
    SpeechSynthesizerDelegateProxy.proxy(for: wrappedValue).didFinishRelay.eraseToAnyPublisher()
  }

  public var didPause: AnyPublisher<AVSpeechUtterance, Never> {
    SpeechSynthesizerDelegateProxy.proxy(for: wrappedValue).didPauseRelay.eraseToAnyPublisher()
  }

  public var didContinue: AnyPublisher<AVSpeechUtterance, Never> {
    SpeechSynthesizerDelegateProxy.proxy(for: wrappedValue).didContinueRelay.eraseToAnyPublisher()
  }

  public var didCancel: AnyPublisher<AVSpeechUtterance, Never> {
    SpeechSynthesizerDelegateProxy.proxy(for: wrappedValue).didCancelRelay.eraseToAnyPublisher()
  }

  public var willSpeakRangeOfSpeechString: AnyPublisher<(NSRange, AVSpeechUtterance), Never> {
    SpeechSynthesizerDelegateProxy.proxy(for: wrappedValue).willSpeakRangeOfSpeechStringRelay.eraseToAnyPublisher()
  }
}

// MARK: - SpeechSynthesizerDelegateProxy

final class SpeechSynthesizerDelegateProxy: DelegateProxy<AVSpeechSynthesizer, AVSpeechSynthesizerDelegate>, DelegateProxyProtocol {
  let didStartRelay = PassthroughSubject<AVSpeechUtterance, Never>()
  let didFinishRelay = PassthroughSubject<AVSpeechUtterance, Never>()
  let didPauseRelay = PassthroughSubject<AVSpeechUtterance, Never>()
  let didContinueRelay = PassthroughSubject<AVSpeechUtterance, Never>()
  let didCancelRelay = PassthroughSubject<AVSpeechUtterance, Never>()
  let willSpeakRangeOfSpeechStringRelay = PassthroughSubject<(NSRange, AVSpeechUtterance), Never>()

  static func forwardToDelegate(for object: AVSpeechSynthesizer) -> AVSpeechSynthesizerDelegate? {
    object.delegate
  }

  static func setProxyDelegate(_ object: AVSpeechSynthesizer, to proxy: SpeechSynthesizerDelegateProxy) {
    object.delegate = proxy
  }

  static func createProxy(for object: AVSpeechSynthesizer) -> SpeechSynthesizerDelegateProxy {
    SpeechSynthesizerDelegateProxy(object: object, delegateProxyType: SpeechSynthesizerDelegateProxy.self)
  }
}

// MARK: AVSpeechSynthesizerDelegate

extension SpeechSynthesizerDelegateProxy: AVSpeechSynthesizerDelegate {
  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
    didStartRelay.send(utterance)

    forwardToDelegate?.speechSynthesizer?(synthesizer, didStart: utterance)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
    didFinishRelay.send(utterance)

    forwardToDelegate?.speechSynthesizer?(synthesizer, didFinish: utterance)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
    didPauseRelay.send(utterance)

    forwardToDelegate?.speechSynthesizer?(synthesizer, didPause: utterance)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
    didContinueRelay.send(utterance)

    forwardToDelegate?.speechSynthesizer?(synthesizer, didContinue: utterance)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
    didCancelRelay.send(utterance)

    forwardToDelegate?.speechSynthesizer?(synthesizer, didCancel: utterance)
  }

  func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
    willSpeakRangeOfSpeechStringRelay.send((characterRange, utterance))

    forwardToDelegate?.speechSynthesizer?(synthesizer, willSpeakRangeOfSpeechString: characterRange, utterance: utterance)
  }
}
