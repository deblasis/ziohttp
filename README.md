# ziohttp

HTTP utilities for Zig. Request parsing, status codes, header handling, URL encoding — zero alloc.

Parse HTTP request lines, status codes with category checks, header extraction, and URL encoding. Zero-allocation where possible.

## Quick start

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

## Example output

`zig build run-example` produces:

```
=== ziohttp example ===

Request: GET /api/users?limit=10 HTTP/1.1
  Method:  GET
  Path:    /api/users?limit=10
  Version: HTTP/1.1

Headers (3):
  Content-Type: application/json
  Content-Length: 42
  Authorization: Bearer token123

URL encoded: hello%20world%20%26%20%3Ctest%3E

200 success: true
404 client error: true
500 server error: true
```

See [examples/example.zig](examples/example.zig) for the source.

## API

- `parseMethod(str)` — parse GET/POST/PUT/DELETE/PATCH/HEAD/OPTIONS
- `RequestLine.parse(line)` — parse `METHOD /path HTTP/1.1`
- `StatusCode` — enum with `.isSuccess()` / `.isRedirect()` / `.isClientError()` / `.isServerError()`
- `parseHeaders(input, keys, values)` — extract headers
- `getHeader(keys, values, name)` — case-insensitive lookup
- `urlEncode(input, output)` — percent-encode

## Compatibility

- **Zig**: 0.16.0
- **Platforms**: Linux, macOS, Windows
- **Breaking changes**: follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Minor versions add features, patch versions fix bugs.

## License

MIT. Copyright (c) 2026 Alessandro De Blasis.
