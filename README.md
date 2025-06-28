#  SwiftFP

## Foundation:



## Reader:

`Reader` is a lightweight functional abstraction for dependency injection and environment-based computations in Swift. 
It lets you compose and chain logic that depends on a shared, read-only context, making your code more modular, testable, and expressive. 
Use ‎`Reader` to build pipelines where configuration, dependencies, or context are injected seamlessly—ideal for scalable and maintainable applications.

```swift
// Define an environment type
struct AppConfig {
    let apiEndpoint: String
    let isDebug: Bool
}

// Create a Reader that extracts the API endpoint from the environment
let apiEndpointReader = Reader<AppConfig, String> { config in
    config.apiEndpoint
}

// Create a Reader that formats a debug message based on the environment
let debugMessageReader = Reader<AppConfig, String> { config in
    config.isDebug ? "Debug mode is ON" : "Debug mode is OFF"
}

// Combine Readers to produce a summary
let summaryReader = apiEndpointReader.zip(debugMessageReader) { endpoint, debugMsg in
    "Endpoint: \(endpoint)\n\(debugMsg)"
}

// Use the Reader with a specific environment
let config = AppConfig(apiEndpoint: "https://api.example.com", isDebug: true)
let summary = summaryReader.apply(config)

print(summary)
// Output:
// Endpoint: https://api.example.com
// Debug mode is ON
```

## Either:

‎`Either` is a flexible enum type for representing a value that can be one of two possible types—commonly used for error handling, 
branching logic, or modeling data with multiple valid forms. 

## Zipper:

‎`Zipper` is a Swift data structure for navigating and editing collections with a movable cursor. 
It lets you efficiently focus on, update, and traverse elements while retaining access to the context before and after the current position.
Perfect for editors, undo/redo stacks, and more.

```swift
// Create a zipper focused on "b"
let zipper = Zipper(previous: ["a"], current: "b", next: ["c", "d"])
print(zipper.current)         // "b"
print(Array(zipper.previous)) // ["a"]
print(Array(zipper.next))     // ["c", "d"]

// Move the cursor forward
var mutable = zipper
mutable.forward()
print(mutable.current)        // "c"
```
