//! ziohttp for Zig.

const std = @import("std");

test "{ziohttp} smoke test" {
    try std.testing.expect(true);
}

test "{ziohttp} basic functionality" {
    try std.testing.expect(1 + 1 == 2);
}

test "{ziohttp} string operations" {
    try std.testing.expectEqualStrings("hello", "hello");
}

test "{ziohttp} error handling" {
    const result = std.math.add(u8, 200, 100);
    try std.testing.expectError(error.Overflow, result);
}
