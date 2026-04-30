# ziohttp

Minimal HTTP client and server for Zig

HTTP client and server library for Zig. Request/response routing, middleware, chunked encoding, and TLS support. Built on std.net.

## Features

- HTTP/1.1 client and server
- request routing
- middleware chain
- chunked encoding

## Quick Start

```zig
const ziohttp = @import("ziohttp");

pub fn main() !void {
    // See examples/ for runnable code
}
```

## Installation

Add to your `build.zig.zon`:

```zig
.{
    .dependencies = .{
        .ziohttp = .{ .url = "https://github.com/deblasis/ziohttp/archive/refs/heads/main.tar.gz", .hash = "..." },
    },
}
```

Then in your `build.zig`:

```zig
const ziohttp = b.dependency("ziohttp", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("ziohttp", ziohttp.module("ziohttp"));
```

## Examples

Run the included example:

```bash
zig build run-example
```

## API Reference

See [src/ziohttp.zig](src/ziohttp.zig) for full documentation. All public symbols have doc comments.

## Compatibility

- **Zig:** 0.16.0
- **Platforms:** Linux, macOS, Windows
- **Breaking changes:** Follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Minor versions may add features, patch versions fix bugs.

## License

MIT
