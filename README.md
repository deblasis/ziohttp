# ziohttp

HTTP utilities for Zig. Request parsing, status codes, header handling, URL encoding.

## The pitch

Parse HTTP request lines, status codes with category checks, header extraction, and URL encoding.

```zig
const ziohttp = @import("ziohttp");

// Parse a request line
const req = ziohttp.RequestLine.parse("GET /api/users?limit=10 HTTP/1.1").?;
// req.method == .GET, req.path == "/api/users?limit=10"

// Status code categories
if (ziohttp.StatusCode.ok.isSuccess()) { /* 2xx */ }
if (ziohttp.StatusCode.found.isRedirect()) { /* 3xx */ }
if (ziohttp.StatusCode.not_found.isClientError()) { /* 4xx */ }

// Parse headers
var keys: [20][]const u8 = undefined;
var values: [20][]const u8 = undefined;
const count = try ziohttp.parseHeaders(raw_headers, &keys, &values);
const ct = ziohttp.getHeader(&keys, &values, "content-type"); // case-insensitive

// URL-encode
var buf: [256]u8 = undefined;
const len = ziohttp.urlEncode("hello world & <test>", &buf);
```

## Install

```bash
zig fetch --save git+https://github.com/deblasis/ziohttp
```

Then in your `build.zig`:

```zig
const dep = b.dependency("ziohttp", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("ziohttp", dep.module("ziohttp"));
```

Requires Zig 0.16.

## API

- `parseMethod(str)` — GET/POST/PUT/DELETE/PATCH/HEAD/OPTIONS
- `RequestLine.parse(line)` — parse `METHOD /path HTTP/1.1`
- `StatusCode` — `.isSuccess()` / `.isRedirect()` / `.isClientError()` / `.isServerError()`
- `parseHeaders(input, keys, values)` / `getHeader(keys, values, name)`
- `urlEncode(input, output)`

## Compatibility

- **Zig**: 0.16.0
- **Platforms**: Linux, macOS, Windows
- **Breaking changes**: follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Minor versions add features, patch versions fix bugs.

## License

MIT. Copyright (c) 2026 Alessandro De Blasis.
