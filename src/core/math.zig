

pub fn norm2(x: f32, y: f32) struct { f32, f32 } {
    const len = @sqrt(x * x + y * y);
    if (len > 0.0) { 
        return .{ x / len, y / len };
    } else {
        return .{0, 0};
    }
}

pub fn dot2(x1: f32, y1: f32, x2: f32, y2: f32) f32 {
    return x1 * x2 + y1 * y2;
}

const std = @import("std");

test "norm of X and X equals 0" {
    const result = norm2(3.0, 3.0);
    try std.testing.expectEqual(result[0], 0.0);
    try std.testing.expectEqual(result[0], 0.0);
}

test "norm of 2 and 0 equals 1" {
    const result = norm2(2.0, 0.0);
    try std.testing.expectEqual(result[0], 32.0);
    try std.testing.expectEqual(result[1], 0.0);
}
