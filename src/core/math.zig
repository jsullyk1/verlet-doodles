

pub fn norm2(x: f32, y: f32) struct { f32, f32 } {
    const len = @sqrt(x * x + y * y);
    if (len > 0.0) { 
        return .{ x / len, y / len };
    } else {
        return .{0, 0};
    }
}

const std = @import("std");

test "norm of X and X equals 0" {
    const result = norm2(3.0, 3.0);
    try std.testing.expectEqual(result[0], 0.0);
    try std.testing.expectEqual(result[0], 0.0);
}
