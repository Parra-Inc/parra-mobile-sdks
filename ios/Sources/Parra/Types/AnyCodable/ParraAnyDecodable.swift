//
//
// AnyCodable https://github.com/Flight-School/AnyCodable
//
//

#if canImport(Foundation)
import Foundation
#endif

/**
 A type-erased `Decodable` value.

 The `AnyDecodable` type forwards decoding responsibilities
 to an underlying value, hiding its specific underlying type.

 You can decode mixed-type values in dictionaries
 and other collections that require `Decodable` conformance
 by declaring their contained type to be `AnyDecodable`:

 let json = """
 {
 "boolean": true,
 "integer": 42,
 "double": 3.141592653589793,
 "string": "string",
 "array": [1, 2, 3],
 "nested": {
 "a": "alpha",
 "b": "bravo",
 "c": "charlie"
 },
 "null": null
 }
 """.data(using: .utf8)!

 let decoder = JSONDecoder()
 let dictionary = try! decoder.decode([String : AnyDecodable].self, from: json)
 */
@frozen
public struct ParraAnyDecodable: Decodable {
    // MARK: - Lifecycle

    public init(_ value: (some Any)?) {
        self.value = value ?? ()
    }

    // MARK: - Public

    public let value: Any
}

@usableFromInline
protocol _AnyDecodable {
    var value: Any { get }
    init<T>(_ value: T?)
}

// MARK: - ParraAnyDecodable + _AnyDecodable

extension ParraAnyDecodable: _AnyDecodable {}

extension _AnyDecodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            #if canImport(Foundation)
            self.init(NSNull())
            #else
            self.init(Self?.none)
            #endif
        } else if let bool = try? container.decode(Bool.self) {
            self.init(bool)
        } else if let int = try? container.decode(Int.self) {
            self.init(int)
        } else if let uint = try? container.decode(UInt.self) {
            self.init(uint)
        } else if let double = try? container.decode(Double.self) {
            self.init(double)
        } else if let string = try? container.decode(String.self) {
            self.init(string)
        } else if let array = try? container.decode([ParraAnyDecodable].self) {
            self.init(array.map(\.value))
        } else if let dictionary = try? container
            .decode([String: ParraAnyDecodable].self)
        {
            self.init(dictionary.mapValues { $0.value })
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyDecodable value cannot be decoded"
            )
        }
    }
}

// MARK: - ParraAnyDecodable + Equatable

extension ParraAnyDecodable: Equatable {
    public static func == (lhs: ParraAnyDecodable, rhs: ParraAnyDecodable) -> Bool {
        switch (lhs.value, rhs.value) {
        #if canImport(Foundation)
        case is (NSNull, NSNull), is (Void, Void):
            return true
        #endif
        case (let lhs as Bool, let rhs as Bool):
            return lhs == rhs
        case (let lhs as Int, let rhs as Int):
            return lhs == rhs
        case (let lhs as Int8, let rhs as Int8):
            return lhs == rhs
        case (let lhs as Int16, let rhs as Int16):
            return lhs == rhs
        case (let lhs as Int32, let rhs as Int32):
            return lhs == rhs
        case (let lhs as Int64, let rhs as Int64):
            return lhs == rhs
        case (let lhs as UInt, let rhs as UInt):
            return lhs == rhs
        case (let lhs as UInt8, let rhs as UInt8):
            return lhs == rhs
        case (let lhs as UInt16, let rhs as UInt16):
            return lhs == rhs
        case (let lhs as UInt32, let rhs as UInt32):
            return lhs == rhs
        case (let lhs as UInt64, let rhs as UInt64):
            return lhs == rhs
        case (let lhs as Float, let rhs as Float):
            return lhs == rhs
        case (let lhs as Double, let rhs as Double):
            return lhs == rhs
        case (let lhs as String, let rhs as String):
            return lhs == rhs
        case (
            let lhs as [String: ParraAnyDecodable],
            let rhs as [String: ParraAnyDecodable]
        ):
            return lhs == rhs
        case (let lhs as [ParraAnyDecodable], let rhs as [ParraAnyDecodable]):
            return lhs == rhs
        default:
            return false
        }
    }
}

// MARK: - ParraAnyDecodable + CustomStringConvertible

extension ParraAnyDecodable: CustomStringConvertible {
    public var description: String {
        switch value {
        case is Void:
            return String(describing: nil as Any?)
        case let value as CustomStringConvertible:
            return value.description
        default:
            return String(describing: value)
        }
    }
}

// MARK: - ParraAnyDecodable + CustomDebugStringConvertible

extension ParraAnyDecodable: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch value {
        case let value as CustomDebugStringConvertible:
            return "AnyDecodable(\(value.debugDescription))"
        default:
            return "AnyDecodable(\(description))"
        }
    }
}

// MARK: - ParraAnyDecodable + Hashable

extension ParraAnyDecodable: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch value {
        case let value as Bool:
            hasher.combine(value)
        case let value as Int:
            hasher.combine(value)
        case let value as Int8:
            hasher.combine(value)
        case let value as Int16:
            hasher.combine(value)
        case let value as Int32:
            hasher.combine(value)
        case let value as Int64:
            hasher.combine(value)
        case let value as UInt:
            hasher.combine(value)
        case let value as UInt8:
            hasher.combine(value)
        case let value as UInt16:
            hasher.combine(value)
        case let value as UInt32:
            hasher.combine(value)
        case let value as UInt64:
            hasher.combine(value)
        case let value as Float:
            hasher.combine(value)
        case let value as Double:
            hasher.combine(value)
        case let value as String:
            hasher.combine(value)
        case let value as [String: ParraAnyDecodable]:
            hasher.combine(value)
        case let value as [ParraAnyDecodable]:
            hasher.combine(value)
        default:
            break
        }
    }
}
