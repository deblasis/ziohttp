//! HTTP utilities for Zig.
//!
//! Request/response parsing, method enum, status codes, and header handling.

const std = @import("std");

/// HTTP request methods.
pub const Method = enum {
    /// Retrieve a resource.
    GET,
    /// Submit data to a resource.
    POST,
    /// Replace a resource with the request payload.
    PUT,
    /// Remove a resource.
    DELETE,
    /// Apply a partial update to a resource.
    PATCH,
    /// Retrieve the headers of a resource, without a body.
    HEAD,
    /// Describe the communication options for a resource.
    OPTIONS,
    /// Establish a tunnel to the server identified by the target.
    CONNECT,
    /// Perform a message loop-back test along the path to the target.
    TRACE,
};

/// Parse an HTTP method from string.
pub fn parseMethod(str: []const u8) ?Method {
    if (std.mem.eql(u8, str, "GET")) return .GET;
    if (std.mem.eql(u8, str, "POST")) return .POST;
    if (std.mem.eql(u8, str, "PUT")) return .PUT;
    if (std.mem.eql(u8, str, "DELETE")) return .DELETE;
    if (std.mem.eql(u8, str, "PATCH")) return .PATCH;
    if (std.mem.eql(u8, str, "HEAD")) return .HEAD;
    if (std.mem.eql(u8, str, "OPTIONS")) return .OPTIONS;
    if (std.mem.eql(u8, str, "CONNECT")) return .CONNECT;
    if (std.mem.eql(u8, str, "TRACE")) return .TRACE;
    return null;
}

/// Common HTTP status codes.
pub const StatusCode = enum(u16) {
    /// 200: the request succeeded.
    ok = 200,
    /// 201: the request succeeded and a new resource was created.
    created = 201,
    /// 204: the request succeeded with no response body.
    no_content = 204,
    /// 301: the resource has moved permanently to a new URL.
    moved_permanently = 301,
    /// 302: the resource resides temporarily at a different URL.
    found = 302,
    /// 304: the resource is unchanged since the last request.
    not_modified = 304,
    /// 400: the server could not understand the request.
    bad_request = 400,
    /// 401: authentication is required and has failed or was not provided.
    unauthorized = 401,
    /// 403: the server understood the request but refuses to authorize it.
    forbidden = 403,
    /// 404: the requested resource could not be found.
    not_found = 404,
    /// 405: the request method is not supported for the target resource.
    method_not_allowed = 405,
    /// 409: the request conflicts with the current state of the resource.
    conflict = 409,
    /// 500: the server encountered an unexpected condition.
    internal_server_error = 500,
    /// 501: the server does not support the requested functionality.
    not_implemented = 501,
    /// 502: an upstream server returned an invalid response.
    bad_gateway = 502,
    /// 503: the server is not ready to handle the request.
    service_unavailable = 503,

    /// Whether the code is in the 2xx (success) range.
    pub fn isSuccess(self: StatusCode) bool {
        const code = @intFromEnum(self);
        return code >= 200 and code < 300;
    }

    /// Whether the code is in the 3xx (redirection) range.
    pub fn isRedirect(self: StatusCode) bool {
        const code = @intFromEnum(self);
        return code >= 300 and code < 400;
    }

    /// Whether the code is in the 4xx (client error) range.
    pub fn isClientError(self: StatusCode) bool {
        const code = @intFromEnum(self);
        return code >= 400 and code < 500;
    }

    /// Whether the code is in the 5xx (server error) range.
    pub fn isServerError(self: StatusCode) bool {
        const code = @intFromEnum(self);
        return code >= 500 and code < 600;
    }
};

/// A parsed HTTP request line (e.g., "GET /path HTTP/1.1").
pub const RequestLine = struct {
    /// The request method.
    method: Method,
    /// The request target, which may include a query string.
    path: []const u8,
    /// The HTTP version token (e.g., "HTTP/1.1").
    version: []const u8,

    /// Parse a request line into its method, path, and version.
    /// Returns null if any of the three parts is missing or the method is unknown.
    pub fn parse(line: []const u8) ?RequestLine {
        var parts = std.mem.splitSequence(u8, line, " ");
        const method_str = parts.next() orelse return null;
        const path = parts.next() orelse return null;
        const version = parts.next() orelse return null;
        const m = parseMethod(method_str) orelse return null;
        return .{ .method = m, .path = path, .version = version };
    }
};

/// Errors returned by the parsing functions in this module.
pub const HttpError = error{
    /// More headers were present than the caller-provided buffers can hold.
    TooManyHeaders,
};

/// Parse HTTP headers from a block of text.
/// Fills `keys` and `values` in parallel and returns the number of headers parsed.
/// Returns `error.TooManyHeaders` if the input holds more headers than the buffers.
pub fn parseHeaders(input: []const u8, keys: [][]const u8, values: [][]const u8) HttpError!usize {
    var count: usize = 0;
    var lines = std.mem.splitSequence(u8, input, "\r\n");
    while (lines.next()) |line| {
        if (line.len == 0) break;
        const colon_pos = std.mem.indexOfScalar(u8, line, ':') orelse continue;
        if (count >= keys.len) return error.TooManyHeaders;
        keys[count] = line[0..colon_pos];
        values[count] = std.mem.trim(u8, line[colon_pos + 1 ..], " \t");
        count += 1;
    }
    return count;
}

/// Get a header value by name (case-insensitive).
pub fn getHeader(keys: []const []const u8, values: []const []const u8, name: []const u8) ?[]const u8 {
    for (keys, values) |key, value| {
        if (std.ascii.eqlIgnoreCase(key, name)) return value;
    }
    return null;
}

/// URL-encode a string.
pub fn urlEncode(input: []const u8, output: []u8) usize {
    var pos: usize = 0;
    const hex = "0123456789ABCDEF";
    for (input) |ch| {
        if (std.ascii.isAlphanumeric(ch) or ch == '-' or ch == '_' or ch == '.' or ch == '~') {
            if (pos >= output.len) break;
            output[pos] = ch;
            pos += 1;
        } else {
            if (pos + 3 > output.len) break;
            output[pos] = '%';
            output[pos + 1] = hex[ch >> 4];
            output[pos + 2] = hex[ch & 0x0f];
            pos += 3;
        }
    }
    return pos;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test "parseMethod" {
    try std.testing.expectEqual(Method.GET, parseMethod("GET").?);
    try std.testing.expectEqual(Method.POST, parseMethod("POST").?);
    try std.testing.expectEqual(Method.DELETE, parseMethod("DELETE").?);
    try std.testing.expect(parseMethod("INVALID") == null);
}

test "StatusCode isSuccess" {
    try std.testing.expect(StatusCode.ok.isSuccess());
    try std.testing.expect(StatusCode.created.isSuccess());
    try std.testing.expect(!StatusCode.not_found.isSuccess());
}

test "StatusCode categories" {
    try std.testing.expect(StatusCode.found.isRedirect());
    try std.testing.expect(StatusCode.not_found.isClientError());
    try std.testing.expect(StatusCode.internal_server_error.isServerError());
}

test "RequestLine parse" {
    const rl = RequestLine.parse("GET /api/users HTTP/1.1").?;
    try std.testing.expectEqual(Method.GET, rl.method);
    try std.testing.expectEqualStrings("/api/users", rl.path);
    try std.testing.expectEqualStrings("HTTP/1.1", rl.version);
}

test "RequestLine parse POST" {
    const rl = RequestLine.parse("POST /submit HTTP/2.0").?;
    try std.testing.expectEqual(Method.POST, rl.method);
    try std.testing.expectEqualStrings("/submit", rl.path);
}

test "RequestLine invalid" {
    try std.testing.expect(RequestLine.parse("") == null);
    try std.testing.expect(RequestLine.parse("INVALID") == null);
}

test "parseHeaders" {
    const input = "Content-Type: application/json\r\nContent-Length: 42\r\n\r\n";
    var keys: [10][]const u8 = undefined;
    var values: [10][]const u8 = undefined;
    const count = try parseHeaders(input, &keys, &values);
    try std.testing.expectEqual(@as(usize, 2), count);
    try std.testing.expectEqualStrings("Content-Type", keys[0]);
    try std.testing.expectEqualStrings("application/json", values[0]);
}

test "getHeader case insensitive" {
    const keys = [_][]const u8{ "Content-Type", "content-length" };
    const values = [_][]const u8{ "text/html", "100" };
    try std.testing.expectEqualStrings("text/html", getHeader(&keys, &values, "content-type").?);
    try std.testing.expectEqualStrings("100", getHeader(&keys, &values, "Content-Length").?);
}

test "urlEncode" {
    var buf: [100]u8 = undefined;
    const len = urlEncode("hello world", &buf);
    try std.testing.expectEqualStrings("hello%20world", buf[0..len]);
}

test "urlEncode safe chars" {
    var buf: [100]u8 = undefined;
    const len = urlEncode("hello-world_123", &buf);
    try std.testing.expectEqualStrings("hello-world_123", buf[0..len]);
}

test "parseMethod all methods" {
    try std.testing.expectEqual(Method.PUT, parseMethod("PUT").?);
    try std.testing.expectEqual(Method.PATCH, parseMethod("PATCH").?);
    try std.testing.expectEqual(Method.HEAD, parseMethod("HEAD").?);
    try std.testing.expectEqual(Method.OPTIONS, parseMethod("OPTIONS").?);
    try std.testing.expectEqual(Method.CONNECT, parseMethod("CONNECT").?);
    try std.testing.expectEqual(Method.TRACE, parseMethod("TRACE").?);
}

test "StatusCode all 2xx are success" {
    try std.testing.expect(StatusCode.ok.isSuccess());
    try std.testing.expect(StatusCode.created.isSuccess());
    try std.testing.expect(StatusCode.no_content.isSuccess());
}

test "RequestLine with query string" {
    const rl = RequestLine.parse("GET /search?q=hello&limit=10 HTTP/1.1").?;
    try std.testing.expectEqualStrings("/search?q=hello&limit=10", rl.path);
}

test "parseHeaders empty input" {
    var keys: [10][]const u8 = undefined;
    var values: [10][]const u8 = undefined;
    const count = try parseHeaders("", &keys, &values);
    try std.testing.expectEqual(@as(usize, 0), count);
}

test "getHeader not found" {
    const keys = [_][]const u8{"Content-Type"};
    const values = [_][]const u8{"text/html"};
    try std.testing.expect(getHeader(&keys, &values, "Authorization") == null);
}

test "urlEncode special chars" {
    var buf: [100]u8 = undefined;
    const len = urlEncode("a&b<c>d", &buf);
    try std.testing.expectEqualStrings("a%26b%3Cc%3Ed", buf[0..len]);
}

test "urlEncode empty string" {
    var buf: [10]u8 = undefined;
    const len = urlEncode("", &buf);
    try std.testing.expectEqual(@as(usize, 0), len);
}

test "RequestLine parse DELETE" {
    const rl = RequestLine.parse("DELETE /resource/42 HTTP/1.1").?;
    try std.testing.expectEqual(Method.DELETE, rl.method);
}

test "parseHeaders stops at empty line" {
    const input = "X-Custom: value\r\n\r\nX-Ignored: after";
    var keys: [10][]const u8 = undefined;
    var values: [10][]const u8 = undefined;
    const count = try parseHeaders(input, &keys, &values);
    try std.testing.expectEqual(@as(usize, 1), count);
}

test "parseHeaders too many headers" {
    const input = "A: 1\r\nB: 2\r\nC: 3\r\n\r\n";
    var keys: [2][]const u8 = undefined;
    var values: [2][]const u8 = undefined;
    try std.testing.expectError(HttpError.TooManyHeaders, parseHeaders(input, &keys, &values));
}

test "urlEncode truncates on small output buffer" {
    // A space needs three bytes ("%20") but only two remain, so encoding
    // stops before writing a partial escape.
    var buf: [2]u8 = undefined;
    const len = urlEncode("a ", &buf);
    try std.testing.expectEqualStrings("a", buf[0..len]);
}
