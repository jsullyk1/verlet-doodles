const std = @import("std");
const builtin = @import("builtin");

const enable_debug_logs = builtin.mode == .Debug;

pub fn scoped(comptime scope: anytype) type {
    return struct {
        pub inline fn debug(
            comptime format: []const u8,
            args: anytype,
        ) void {
            if (enable_debug_logs) {
                std.log.scoped(scope).debug(format, args);
            }
        }

        pub inline fn info(
            comptime format: []const u8,
            args: anytype,
        ) void {
            if (enable_debug_logs) {
                std.log.scoped(scope).info(format, args);
            }
        }

        pub fn warn(
            comptime format: []const u8,
            args: anytype,
        ) void {
            if (enable_debug_logs) {
                std.log.scoped(scope).warn(format, args);
            }
        }

        pub fn err(
            comptime format: []const u8,
            args: anytype,
        ) void {
            std.log.scoped(scope).err(format, args);
        }
    };
}

