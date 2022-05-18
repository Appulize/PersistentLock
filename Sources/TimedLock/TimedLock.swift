/**
 Copyright 2022 Maciej Swic
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this softwareand associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 IN THE SOFTWARE.
 */

import Foundation
import AppulizeStandardTools

@available(macOS 10.14, iOS 13.0, watchOS 8.0, tvOS 12.0, *)
public actor TimedLock {
    public typealias Completion = () -> Void
    
    public let identifier: String
    public var completion: Completion?
    
    private var key: String {
        "tl-\(identifier)"
    }
    
    public var lockedUntil: Date {
        get {
            let timeInterval = TimeInterval(UserDefaults.standard.double(forKey: key))
            let date = Date(timeIntervalSince1970: timeInterval)
            
            dLog("TimedLock: \(identifier) is locked until \(date.description)")
            
            return date
        }
        set {
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: key)
            
            dLog("TimedLock: \(identifier) has been locked until \(newValue.description)")
        }
    }
    
    public init(identifier: String) {
        self.identifier = identifier
    }
    
    public var isLocked: Bool {
        get {
            Date().timeIntervalSince(lockedUntil) < 0
        }
    }
    
    @discardableResult
    public func lock(onExpire: Completion? = nil) -> Bool {
        lock(until: Date.distantFuture, onExpire: onExpire)
    }
    
    @discardableResult
    public func lock(for timeInterval: TimeInterval, onExpire: Completion? = nil) -> Bool {
        lock(until: Date().addingTimeInterval(timeInterval), onExpire: onExpire)
    }
    
    @discardableResult
    public func lock(until date: Date, onExpire: Completion? = nil) -> Bool {
        guard !isLocked else {
            dLog("TimedLock: Failed to get lock on \(identifier), already locked until \(lockedUntil.description)")
            
            return false
        }
        
        lockedUntil = date
        completion = onExpire
        
        delay(date.timeIntervalSinceNow) {
            self.completion?()
            self.completion = nil
        }
        
        return true
    }
    
    @discardableResult
    public func reLock(onExpire: Completion? = nil) -> Bool {
        lock(until: Date.distantFuture, onExpire: onExpire)
    }
    
    @discardableResult
    public func reLock(for timeInterval: TimeInterval, onExpire: Completion? = nil) -> Bool {
        lock(until: Date().addingTimeInterval(timeInterval), onExpire: onExpire)
    }
    
    @discardableResult
    public func reLock(until date: Date, onExpire: Completion? = nil) -> Bool {
        lockedUntil = date
        completion = onExpire
        
        delay(date.timeIntervalSinceNow) {
            self.completion?()
            self.completion = nil
        }
        
        return true
    }
    
    public func unlock() {
        unlock(at: Date.distantPast)
    }
    
    public func unlock(after timeInterval: TimeInterval) {
        unlock(at: Date().addingTimeInterval(timeInterval))
    }
    
    public func unlock(at date: Date) {
        lockedUntil = date
        completion = nil
    }
}
