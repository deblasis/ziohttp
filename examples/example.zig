const std = @import("std");
const ziohttp = @import("ziohttp");

pub fn main() !void {
    std.debug.print("=== ziohttp example ===\n\n", .{});

    // Parse request line
    const rl = ziohttp.RequestLine.parse("GET /api/users?limit=10 HTTP/1.1").?;
    std.debug.print("Request: GET /api/users?limit=10 HTTP/1.1\n", .{});
    std.debug.print("  Method:  {s}\n", .{@tagName(rl.method)});
    std.debug.print("  Path:    {s}\n", .{rl.path});
    std.debug.print("  Version: {s}\n", .{rl.version});

    // Parse headers
    const headers_raw = "Content-Type: application/json\r\nContent-Length: 42\r\nAuthorization: Bearer token123\r\n\r\n";
    var keys: [10][]const u8 = undefined;
    var values: [10][]const u8 = undefined;
    const count = try ziohttp.parseHeaders(headers_raw, &keys, &values);
    std.debug.print("\nHeaders ({d}):\n", .{count});
    for (0..count) |i| {
        const k: []const u8 = keys[i];
        const v: []const u8 = values[i];
        std.debug.print("  {s}: {s}\n", .{ k, v });
    }

    // URL encoding
    var buf: [100]u8 = undefined;
    const encoded_len = ziohttp.urlEncode("hello world & <test>", &buf);
    std.debug.print("\nURL encoded: {s}\n", .{buf[0..encoded_len]});

    // Status codes
    std.debug.print("\n200 success: {}\n", .{ziohttp.StatusCode.ok.isSuccess()});
    std.debug.print("404 client error: {}\n", .{ziohttp.StatusCode.not_found.isClientError()});
    std.debug.print("500 server error: {}\n", .{ziohttp.StatusCode.internal_server_error.isServerError()});
}
