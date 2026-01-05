import Foundation

/// Declares a named option (short/long) that can parse arbitrary value types.
@propertyWrapper
public struct Option<Value: ExpressibleFromArgument>: CommanderMetadata {
    private var storage: Value?
    private let nameSpecifications: [NameSpecification]
    private let help: String?
    private let envVar: String?
    private var environmentValue: Value?
    private var isParsed: Bool = false

    /// Returns the stored value, environment value, or nil if optional.
    /// Crashes with a helpful message if accessed before being bound and not optional.
    public var wrappedValue: Value {
        get {
            if let storage { return storage }
            if let envValue = environmentValue { return envValue }
            // For optional types, return nil
            if Value.self is OptionalProtocol.Type {
                return (nil as Value?)!
            }
            // This should not happen in normal usage - options are bound during parsing
            fatalError("Helix option '\(Value.self)' accessed before being parsed. This is a development error.")
        }
        set {
            self.storage = newValue
            self.isParsed = true
        }
    }

    public init(wrappedValue: Value, name: NameSpecification = .automatic, help: String? = nil, envVar: String? = nil) {
        self.storage = wrappedValue
        self.nameSpecifications = [name]
        self.help = help
        self.envVar = envVar
        self.isParsed = true
    }

    public init(name: NameSpecification = .automatic, help: String? = nil, envVar: String? = nil) {
        self.storage = nil
        self.nameSpecifications = [name]
        self.help = help
        self.envVar = envVar
        self.isParsed = false
    }

    public init(names: [NameSpecification], help: String? = nil, envVar: String? = nil) {
        self.storage = nil
        self.nameSpecifications = names
        self.help = help
        self.envVar = envVar
        self.isParsed = false
    }

    /// Sets the environment variable value to use as fallback.
    /// This is called by the parser after binding.
    mutating func setEnvironmentValue(_ value: Value?) {
        self.environmentValue = value
    }

    /// Returns true if this option was parsed from arguments.
    public var wasParsed: Bool {
        isParsed || environmentValue != nil
    }

    public func register(label: String, signature: inout CommandSignature) {
        let resolvedLabel = Self.sanitize(label)
        let resolvedNames = self.nameSpecifications.flatMap { $0.resolve(defaultLabel: resolvedLabel) }
        let definition = OptionDefinition(label: resolvedLabel, names: resolvedNames, help: help, envVar: envVar)
        signature.append(.option(definition))
    }

    private static func sanitize(_ label: String) -> String {
        label.hasPrefix("_") ? String(label.dropFirst()) : label
    }
}

extension Option: Sendable where Value: Sendable {}

/// Declares a positional argument, optionally optional.
@propertyWrapper
public struct Argument<Value: ExpressibleFromArgument>: CommanderMetadata {
    private var storage: Value?
    private let help: String?
    private var isParsed: Bool = false

    /// Returns the stored value or nil if optional.
    /// Crashes with a helpful message if accessed before being bound.
    public var wrappedValue: Value {
        get {
            if let storage { return storage }
            // For optional types, return nil
            if Value.self is OptionalProtocol.Type {
                return (nil as Value?)!
            }
            // This should not happen in normal usage
            fatalError("Helix argument '\(Value.self)' accessed before being parsed. This is a development error.")
        }
        set {
            self.storage = newValue
            self.isParsed = true
        }
    }

    public init(wrappedValue: Value, help: String? = nil) {
        self.storage = wrappedValue
        self.help = help
        self.isParsed = true
    }

    public init(help: String? = nil) {
        self.storage = nil
        self.help = help
        self.isParsed = false
    }

    /// Returns true if this argument was parsed from arguments.
    public var wasParsed: Bool {
        isParsed
    }

    public func register(label: String, signature: inout CommandSignature) {
        let resolvedLabel = Self.sanitize(label)
        let definition = ArgumentDefinition(
            label: resolvedLabel,
            help: help,
            isOptional: Value.self is OptionalProtocol.Type)
        signature.append(.argument(definition))
    }

    private static func sanitize(_ label: String) -> String {
        label.hasPrefix("_") ? String(label.dropFirst()) : label
    }
}

extension Argument: Sendable where Value: Sendable {}

/// Declares a boolean flag that defaults to `false` and toggles to `true` when present.
@propertyWrapper
public struct Flag: CommanderMetadata, Sendable {
    public var wrappedValue: Bool
    private let nameSpecifications: [NameSpecification]
    private let help: String?

    public init(wrappedValue: Bool = false, name: NameSpecification = .automatic, help: String? = nil) {
        self.wrappedValue = wrappedValue
        self.nameSpecifications = [name]
        self.help = help
    }

    public init(wrappedValue: Bool = false, names: [NameSpecification], help: String? = nil) {
        self.wrappedValue = wrappedValue
        self.nameSpecifications = names
        self.help = help
    }

    public func register(label: String, signature: inout CommandSignature) {
        let resolvedLabel = Self.sanitize(label)
        let definition = FlagDefinition(
            label: resolvedLabel,
            names: nameSpecifications.flatMap { $0.resolve(defaultLabel: resolvedLabel) },
            help: self.help)
        signature.append(.flag(definition))
    }

    private static func sanitize(_ label: String) -> String {
        label.hasPrefix("_") ? String(label.dropFirst()) : label
    }
}

/// Provides nested Helix metadata so you can keep related parameters together.
@propertyWrapper
public struct OptionGroup<Value: HelixParsable>: CommanderOptionGroup {
    public var wrappedValue: Value

    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public init() where Value: HelixParsable {
        self.wrappedValue = Value()
    }

    public func register(label: String, signature: inout CommandSignature) {
        let groupSignature = CommandSignature.describe(self.wrappedValue)
        signature.append(.group(groupSignature))
    }
}

extension OptionGroup: Sendable where Value: Sendable {}

/// Marker protocol for option-group structs.
public protocol HelixParsable {
    init()
}

protocol CommanderMetadata {
    func register(label: String, signature: inout CommandSignature)
}

protocol CommanderOptionGroup {
    func register(label: String, signature: inout CommandSignature)
}

protocol DefaultInitializable {
    init()
}

/// Note: HelixParsable already requires init(), so no additional implementation is needed.
/// This protocol exists for potential future use cases.

protocol OptionalProtocol {}
extension Optional: OptionalProtocol {}
