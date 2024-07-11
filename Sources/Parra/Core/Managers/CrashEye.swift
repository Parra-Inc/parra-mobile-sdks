//
//  CrashEye.swift
//  Pods
//
//  Created by zixun on 16/12/23.
//
//

import Foundation
import UIKit

// --------------------------------------------------------------------------

// MARK: - CrashEyeDelegate

// --------------------------------------------------------------------------
public protocol CrashEyeDelegate: NSObjectProtocol {
    func crashEyeDidCatchCrash(with model: CrashModel)
}

// --------------------------------------------------------------------------

// MARK: - WeakCrashEyeDelegate

// --------------------------------------------------------------------------
class WeakCrashEyeDelegate: NSObject {
    // MARK: - Lifecycle

    init(delegate: CrashEyeDelegate) {
        super.init()
        self.delegate = delegate
    }

    // MARK: - Internal

    weak var delegate: CrashEyeDelegate?
}

// --------------------------------------------------------------------------

// MARK: - CrashModelType

// --------------------------------------------------------------------------
public enum CrashModelType: Int, CustomStringConvertible {
    case signal = 1
    case exception = 2

    // MARK: - Public

    public var description: String {
        switch self {
        case .signal:
            return "signal"
        case .exception:
            return "exception"
        }
    }
}

// --------------------------------------------------------------------------

// MARK: - CrashModel

// --------------------------------------------------------------------------
open class CrashModel: NSObject {
    // MARK: - Lifecycle

    init(
        type: CrashModelType,
        name: String,
        reason: String,
        appinfo: String,
        callStack: [String]
    ) {
        super.init()

        self.type = type
        self.name = name
        self.reason = reason
        self.appinfo = appinfo
        self.callStack = callStack
    }

    // MARK: - Open

    open var type: CrashModelType!
    open var name: String!
    open var reason: String!
    open var appinfo: String!
    open var callStack: [String]
}

// --------------------------------------------------------------------------

// MARK: - GLOBAL VARIABLE

// --------------------------------------------------------------------------
private var app_old_exceptionHandler: (
    @convention(c) (NSException) -> Swift
        .Void
)?

// --------------------------------------------------------------------------

// MARK: - CrashEye

// --------------------------------------------------------------------------
public class CrashEye: NSObject {
    // MARK: - Open

    // --------------------------------------------------------------------------

    // MARK: OPEN FUNCTION

    // --------------------------------------------------------------------------
    open class func add(delegate: CrashEyeDelegate) {
        // delete null week delegate
        delegates = delegates.filter {
            return $0.delegate != nil
        }

        // judge if contains the delegate from parameter
        let contains = delegates.contains {
            return $0.delegate?.hash == delegate.hash
        }
        // if not contains, append it with weak wrapped
        if contains == false {
            let week = WeakCrashEyeDelegate(delegate: delegate)
            delegates.append(week)
        }

        if !delegates.isEmpty {
            open()
        }
    }

    open class func remove(delegate: CrashEyeDelegate) {
        delegates = delegates.filter {
            // filter null weak delegate
            return $0.delegate != nil
        }.filter {
            // filter the delegate from parameter
            return $0.delegate?.hash != delegate.hash
        }

        if delegates.isEmpty {
            close()
        }
    }

    // MARK: - Public

    // --------------------------------------------------------------------------

    // MARK: OPEN PROPERTY

    // --------------------------------------------------------------------------
    public private(set) static var isOpen: Bool = false

    // MARK: - Fileprivate

    // --------------------------------------------------------------------------

    // MARK: PRIVATE PROPERTY

    // --------------------------------------------------------------------------
    fileprivate static var delegates = [WeakCrashEyeDelegate]()

    // MARK: - Private

    private static let RecieveException: @convention(c) (NSException) -> Swift
        .Void = {
            exception in
            if app_old_exceptionHandler != nil {
                app_old_exceptionHandler!(exception)
            }

            guard CrashEye.isOpen == true else {
                return
            }

            let callStack = exception.callStackSymbols
            let reason = exception.reason ?? ""
            let name = exception.name
            let appinfo = CrashEye.appInfo()

            let model = CrashModel(
                type: CrashModelType.exception,
                name: name.rawValue,
                reason: reason,
                appinfo: appinfo,
                callStack: callStack
            )
            for delegate in CrashEye.delegates {
                delegate.delegate?.crashEyeDidCatchCrash(with: model)
            }
        }

    private static let RecieveSignal: @convention(c) (Int32) -> Void = {
        signal in

        guard CrashEye.isOpen == true else {
            return
        }

        var callstack = Thread.callStackSymbols
        callstack.removeFirst(2)

        let reason =
            "Signal \(CrashEye.name(of: signal))(\(signal)) was raised.\n"
        let appinfo = CrashEye.appInfo()

        let model = CrashModel(
            type: CrashModelType.signal,
            name: CrashEye.name(of: signal),
            reason: reason,
            appinfo: appinfo,
            callStack: callstack
        )

        for delegate in CrashEye.delegates {
            delegate.delegate?.crashEyeDidCatchCrash(with: model)
        }

        CrashEye.killApp()
    }

    // --------------------------------------------------------------------------

    // MARK: PRIVATE FUNCTION

    // --------------------------------------------------------------------------
    private class func open() {
        guard isOpen == false else {
            return
        }
        CrashEye.isOpen = true

        app_old_exceptionHandler = NSGetUncaughtExceptionHandler()
        NSSetUncaughtExceptionHandler(CrashEye.RecieveException)
        setCrashSignalHandler()
    }

    private class func close() {
        guard isOpen == true else {
            return
        }
        CrashEye.isOpen = false
        NSSetUncaughtExceptionHandler(app_old_exceptionHandler)
    }

    private class func setCrashSignalHandler() {
        signal(SIGABRT, CrashEye.RecieveSignal)
        signal(SIGILL, CrashEye.RecieveSignal)
        signal(SIGSEGV, CrashEye.RecieveSignal)
        signal(SIGFPE, CrashEye.RecieveSignal)
        signal(SIGBUS, CrashEye.RecieveSignal)
        signal(SIGPIPE, CrashEye.RecieveSignal)
        // http://stackoverflow.com/questions/36325140/how-to-catch-a-swift-crash-and-do-some-logging
        signal(SIGTRAP, CrashEye.RecieveSignal)
    }

    private class func appInfo() -> String {
        let displayName = Bundle.main
            .object(forInfoDictionaryKey: "CFBundleName") ?? ""
        let shortVersion = Bundle.main
            .object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? ""
        let version = Bundle.main
            .object(forInfoDictionaryKey: "CFBundleVersion") ?? ""
        let deviceModel = UIDevice.current.model
        let systemName = UIDevice.current.systemName
        let systemVersion = UIDevice.current.systemVersion
        return "App: \(displayName) \(shortVersion)(\(version))\n" +
            "Device:\(deviceModel)\n" +
            "OS Version:\(systemName) \(systemVersion)"
    }

    private class func name(of signal: Int32) -> String {
        switch signal {
        case SIGABRT:
            return "SIGABRT"
        case SIGILL:
            return "SIGILL"
        case SIGSEGV:
            return "SIGSEGV"
        case SIGFPE:
            return "SIGFPE"
        case SIGBUS:
            return "SIGBUS"
        case SIGPIPE:
            return "SIGPIPE"
        default:
            return "OTHER"
        }
    }

    private class func killApp() {
        NSSetUncaughtExceptionHandler(nil)

        signal(SIGABRT, SIG_DFL)
        signal(SIGILL, SIG_DFL)
        signal(SIGSEGV, SIG_DFL)
        signal(SIGFPE, SIG_DFL)
        signal(SIGBUS, SIG_DFL)
        signal(SIGPIPE, SIG_DFL)

        kill(getpid(), SIGKILL)
    }
}
