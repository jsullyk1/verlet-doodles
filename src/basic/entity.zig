const std = @import("std");
const rl = @import("raylib");

pub fn EntityStoreAOS(comptime T: type) type {
    return struct {
        gpa: std.heap.GeneralPurposeAllocator(.{}),
        entities: std.ArrayList(T),

        pub fn init() @This() {
            const gpa = std.heap.GeneralPurposeAllocator(.{}){};
            const el: std.ArrayList(T) = .empty;

            return .{
                .gpa = gpa,
                .entities = el,
            };
        }

        pub fn clear(self: *@This()) void {
            self.entities.clearRetainingCapacity();
        }

        pub fn deinit(self: *@This()) void {
            self.entities.deinit(self.gpa.allocator());
            const leaked = self.gpa.deinit();
            if (leaked == .leak) std.debug.print("Leaked \n", .{});
        }

        pub fn addObject(self: *@This(), p: T) !void {
            const alloc = self.gpa.allocator();
            try self.entities.append(alloc, p);
        }

        pub fn getObjects(self: @This()) []T {
            return self.entities.items;
        }

        pub fn len(self: @This()) usize {
            return self.entities.items.len;
        }
    };
}
