# Project Ideas

A collection of potential Swift projects using Helix and beyond.

---

## CLI Tools (using Helix)

### Harbor - Docker Registry CLI
Manage Docker images, tags, pull/push operations, and multi-registry support.

```swift
struct HarborCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "Registry URL")
    var registry: String = "docker.io"

    @Flag(name: .short("v"), help: "Verbose output")
    var verbose: Bool = false

    mutating func run() async throws {
        // Image management logic
    }
}
```

**Tech:** Helix, AsyncHTTPClient, Foundation

---

### SwiftEnv - Swift Version Manager
Switch between Swift toolchain versions (like pyenv for Python).

```swift
struct SwiftEnvCommand: ParsableCommand {
    static var commandDescription: CommandDescription {
        CommandDescription(
            commandName: "swiftenv",
            abstract: "Manage Swift versions",
            subcommands: [
                InstallCommand.self,
                UseCommand.self,
                ListCommand.self
            ]
        )
    }
    // ...
}
```

**Tech:** Helix, PathKit, ZIPFoundation

---

### GitForge - Git Enhancement Tool
PR reviews, commit templates, changelog generation, and git workflow automation.

```swift
struct GitForgeCommand: ParsableCommand {
    @Argument(help: "Repository path")
    var repository: String

    @Flag(name: .short("v"), help: "Verbose")
    var verbose: Bool = false
}
```

**Tech:** Helix, GitKit, Swift Argument Parser

---

### DeployCLI - Cloud Deployment Helper
Deploy to Vercel, Railway, Fly.io, and other platforms from CLI.

```swift
struct DeployCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "Platform (vercel|railway|fly)")
    var platform: String

    @Argument(help: "Project directory")
    var directory: String

    mutating func run() async throws { /* ... */ }
}
```

**Tech:** Helix, AsyncHTTPClient, Foundation

---

### ConfigGen - Configuration Generator
Generate configs from templates with environment variable overrides.

```swift
struct ConfigGenCommand: ParsableCommand {
    @Option(name: .shortAndLong, help: "Template file")
    var template: String

    @Option(name: .short("o"), help: "Output file")
    var output: String?

    @Flag(name: .short("e"), help: "Expand environment variables")
    var expandEnv: Bool = true
}
```

**Tech:** Helix, Stencil templating, Environment variable interpolation

---

## Server-Side Swift

### TinyHTTP - Minimal HTTP Server
Express.js-like HTTP server framework for Swift.

```swift
let app = HTTPApp()

app.get("/users") { req in
    return User.list()
}

app.post("/users") { req in
    return try User.create(from: req.body)
}

try app.listen(on: 8080)
```

**Tech:** AsyncHTTPClient, URLSession, WebSocket

---

### SQLiteKit - Type-Safe SQLite ORM
Codable-like interface for SQLite operations.

```swift
struct User: SQLiteModel {
    var id: Int?
    var name: String
    var email: String
    var createdAt: Date
}

let users = try await User.query
    .where(\User.name == "Alice")
    .orderBy(\User.createdAt, ascending: false)
    .fetch()
```

**Tech:** SQLite C API, Property wrappers, Result builders

---

### AuthKit - Authentication Middleware
JWT, OAuth2, session-based authentication.

```swift
let auth = AuthMiddleware(jwtSecret: "secret")

app.use(auth)
app.post("/secure") { req in
    let user = try req.auth.requireUser()
    return "Hello \(user.name)"
}
```

**Tech:** JWT, CryptoKit, Cookie handling

---

### GraphQL-Swift - GraphQL Server
Schema-first GraphQL implementation.

```swift
let schema = Schema {
    Query {
        Field("user", type: User.self) { _ in
            User.current
        }
    }
    Mutation {
        Field("createUser", type: User.self) { req in
            try User.create(from: req.input)
        }
    }
}
```

**Tech:** GraphQL specification, Async execution

---

### RateLimiter - Distributed Rate Limiting
Redis-backed rate limiting with token bucket algorithm.

```swift
let limiter = RateLimiter(redis: redis, limit: 100, per: .seconds(60))

try await limiter.check(key: "user:123")
// Throws RateLimitExceeded if over limit
```

**Tech:** Redis, SwiftRedis, Atomic operations

---

## Mobile / iOS

### ViewInspector - Runtime View Debugging
Debug SwiftUI views at runtime (like Preview).

```swift
struct ContentView: View {
    var body: some View {
        Text("Hello")
    }
}

let view = ContentView()
let dump = view.inspect().dump()
// Print view hierarchy with properties
```

**Tech:** SwiftUI Reflection, ViewModifier introspection

---

### ImagePipeline - Async Image Loading
Kingfisher-like image caching with async/await.

```swift
let image = await ImagePipeline.shared.load(from: url)
    .cacheKey("avatar")
    .processor(CircleCrop())
    .outputImage()

imageView.image = image
```

**Tech:** AsyncImage, NSCache, Data pre-processing

---

### FormKit - Reactive Form Validation
Compose-able form fields with real-time validation.

```swift
struct LoginForm: FormModel {
    @Field(email: true, message: "Invalid email")
    var email: String

    @Field(minLength: 8, message: "Too short")
    var password: String

    var isValid: Bool { email.isValid && password.isValid }
}
```

**Tech:** Combine, Reactive programming, Validator patterns

---

### PermissionKit - Unified Permission Handler
Single API for location, camera, photos, notifications, etc.

```swift
let permission = Permission.location.whenInUse

switch permission.status {
case .authorized:
    await permission.request()
case .denied:
    openSettings()
default:
    break
}
```

**Tech:** AVFoundation, CoreLocation, UserNotifications

---

### ShortcutCreator - Create iOS Shortcuts
Generate .shortcut files from Swift code.

```swift
let shortcut = Shortcut {
    ShowAlert(title: "Hello", message: "World")
    GetURL(content: "https://example.com")
    SetVariable(name: "result", value: "done")
}

try shortcut.save(to: "MyShortcut.shortcut")
```

**Tech:** ShortcutsKit (private), JSON encoding, Intent definition

---

## Developer Utilities

### SwiftLint-Rules - Custom Lint Rules
Reusable SwiftLint rules collection.

```swift
// .swiftlint.yml
custom_rules:
  no_force_try:
    name: "No force try"
    regex: "try!"
    message: "Force try is dangerous"
    severity: error
```

**Tech:** SwiftLint, Regex, AST parsing

---

### DocGen - API Documentation Generator
Generate docs from source code comments (like Javadoc).

```swift
/// Calculates the total price including tax
/// - Parameters:
///   - price: Base price before tax
///   - taxRate: Tax rate as decimal (0.08 = 8%)
/// - Returns: Total price with tax
func calculateTotal(price: Double, taxRate: Double) -> Double {
    price * (1 + taxRate)
}
```

Generates Markdown/HTML documentation.

**Tech:** SourceKit, Markdown generation, Syntax parsing

---

### MockGen - Mock Object Generator
Generate mocks from protocols.

```swift
// UserService.swift
protocol UserService {
    func fetchUser(id: Int) async throws -> User
    func createUser(_ user: User) async throws
}

// UserServiceMock.swift (generated)
class MockUserService: UserService {
    var fetchUserCalled = false
    var fetchUserId: Int?
    var mockUser: User?

    func fetchUser(id: Int) async throws -> User {
        fetchUserCalled = true
        fetchUserId = id
        return mockUser!
    }
}
```

**Tech:** SourceKit, Template engine, Code generation

---

### APIClient-Gen - OpenAPI to Swift Client
Generate Swift API clients from OpenAPI specs.

```yaml
# openapi.yaml
paths:
  /users:
    get:
      responses:
        200:
          description: List of users
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

Generates:
```swift
class UsersAPI {
    func listUsers() async throws -> [User] {
        // HTTP client call
    }
}
```

**Tech:** OpenAPI/Swagger parser, Code generation, URLSession

---

### EnumGen - Code Generation from Data
Generate Swift code from JSON/database schemas.

```json
// schema.json
{
  "User": {
    "id": "Int",
    "name": "String",
    "email": "String?",
    "roles": "[\"Admin\", \"User\", \"Guest\"]"
  }
}
```

Generates:
```swift
enum Role: String, Codable {
    case admin = "Admin"
    case user = "User"
    case guest = "Guest"
}

struct User: Codable {
    var id: Int
    var name: String
    var email: String?
    var roles: [Role]
}
```

**Tech:** JSON parsing, String interpolation, Template engine

---

## Data & Processing

### CSVParser - Fast CSV Parsing
High-performance CSV with Codable support.

```swift
struct User: Codable {
    var name: String
    var email: String
    var age: Int
}

let users = try CSVDecoder.decode(filename: "users.csv")
let csv = try CSVEncoder.encode(users)
```

**Tech:** String performance optimization, Memory mapping

---

### MsgPack - MessagePack Implementation
Binary serialization format.

```swift
let encoded = try MessagePackEncoder().encode(data)
let decoded = try MessagePackDecoder().decode(Data.self, from: encoded)
```

**Tech:** Binary encoding, Protocol extensions

---

### YAMLKit - YAML Parsing/Encoding
Parse and generate YAML configuration files.

```swift
struct Config: Codable {
    var database: DatabaseConfig
    var cache: CacheConfig
}

let config = try YAMLDecoder().decode(Config.self, from: yamlString)
let yaml = try YAMLEncoder().encode(config)
```

**Tech:** YAML 1.2 spec, LibYAML binding

---

### XLSXReader - Excel File Reader
Read .xlsx files in Swift.

```swift
let workbook = try XLSXReader.read("data.xlsx")
let sheet = workbook.sheet(at: 0)
for row in sheet.rows {
    print(row.cells.map { $0.stringValue })
}
```

**Tech:** XML parsing (Office Open XML), ZIP handling

---

### QRCodeGen - QR Code Generation
Generate QR codes with customization.

```swift
let qr = QRCode(data: "https://example.com")
qr.color = .black
qr.backgroundColor = .white
qr.size = CGSize(width: 200, height: 200)
let image = qr.image
```

**Tech:** CoreImage, QR matrix generation

---

## Concurrency & Async

### TaskGroup-Extra - Extended Task Group
Utilities for complex task group patterns.

```swift
let results = try await withThrowingTaskGroup(of: Result.self) { group in
    for url in urls {
        group.addTask {
            Result(url: url, data: try await fetch(url))
        }
    }
    return try await group.collectResults()
}
```

**Tech:** Swift concurrency, TaskGroup APIs

---

### AsyncSequence-Extra - Custom Async Sequences
Custom async sequences for streaming data.

```swift
let lines = FileHandle.standardInput
    .linesAsyncSequence()
    .filter { !$0.isEmpty }
    .map { $0.uppercased() }

for await line in lines {
    print(line)
}
```

**Tech:** AsyncSequence, AsyncIteratorProtocol

---

### RateLimit - Token Bucket Implementation
Configurable rate limiting with backoff.

```swift
let limiter = TokenBucket(capacity: 10, refillRate: 1.0) // 1 token per second

for i in 0..<15 {
    if try limiter.consume() {
        print("Request \(i) allowed")
    } else {
        print("Request \(i) rate limited")
    }
}
```

**Tech:** Actor isolation, Time-based refilling

---

### RetryKit - Retry Utilities
Configurable retry with exponential backoff.

```swift
let result = try await retry(maxAttempts: 3, delay: .seconds(1)) {
    try await flakyNetworkCall()
}
```

**Tech:** Async algorithms, Backoff strategies

---

### LockFree - Lock-Free Data Structures
Thread-safe collections without locks.

```swift
let queue = LockFreeQueue<Int>()
queue.push(1)
queue.push(2)
let value = queue.pop() // Atomic
```

**Tech:** Atomic operations, Memory ordering, CAS loops

---

## WebAssembly Specific

### WASI-FileSystem - Virtual File System
In-memory FS for WASM applications.

```swift
let fs = WASIFileSystem()
try fs.writeFile("/data/config.json", data)
let content = try fs.readFile("/data/config.json")
```

**Tech:** WASI, In-memory storage, Path resolution

---

### WASI-HTTP - HTTP Client for WASM
HTTP client working in WASM environment.

```swift
let response = try await WASIHTTP.fetch("https://api.example.com")
let data = response.data
let status = response.status
```

**Tech:** WASI sockets (experimental), Fetch API polyfill

---

### WASM-Bridge - JavaScript Interop
Easy Swift-JS communication.

```swift
// Swift calling JS
let document = JSGlobal.object("document")
let element = document.call(method: "getElementById", args: "app")

// JS calling Swift
WASMBridge.register(function: "greet") { name in
    return "Hello, \(name)!"
}
```

**Tech:** JavaScriptKit integration, Type conversion

---

## Project Selection

| Priority | Project | Why |
|----------|---------|-----|
| ⭐⭐⭐ | **SQLiteKit** | Practical, fills ecosystem gap |
| ⭐⭐⭐ | **APIClient-Gen** | High demand, complex but rewarding |
| ⭐⭐ | **WASM-Bridge** | Future-proof, unique niche |
| ⭐⭐ | **MockGen** | Developer tool, builds on SourceKit knowledge |
| ⭐ | **AuthKit** | Common need, but competitive |

---

## Skills Learned

| Project | Skills |
|---------|--------|
| Harbor | Helix, HTTP networking, Docker protocol |
| TinyHTTP | Server-side, async networking |
| SQLiteKit | C interop, SQL, ORM design |
| MockGen | SourceKit, code generation, AST |
| WASM-Bridge | JavaScript interop, WASI |
| RateLimiter | Distributed systems, Redis |
