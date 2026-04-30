# ziohttp

## Overview

HTTP client and server library for Zig. Request/response routing, middleware, chunked encoding, and TLS support. Built on std.net.

## Project Structure

```
src/
  ziohttp.zig    - Main library source
examples/
  example.zig    - Runnable example
build.zig        - Build configuration
```

## Commands

```bash
zig build test          # Run tests
zig build run-example   # Run the example
zig build               - Build the library
```

## Architecture

Single-file library with no external dependencies. All public symbols have doc comments.

## Testing

Tests are inline in `src/ziohttp.zig`. Run with `zig build test`.
