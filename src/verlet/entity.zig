const std = @import("std");
const rl = @import("raylib");
const Partical = @import("partical.zig").Partical;

pub const EntityStore = struct {
    gpa: std.heap.GeneralPurposeAllocator(.{}),
    entities: std.ArrayList(Partical),
    active: bool,

    pub fn init() @This() {
        const gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const el: std.ArrayList(Partical) = .empty;

        return .{
            .gpa = gpa,
            .entities = el,
            .active = true,
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

    pub fn addObject(self: *@This(), p: Partical) !void {
        const alloc = self.gpa.allocator();
        try self.entities.append(alloc, p);
    }

    pub fn getObjects(self: @This()) []Partical {
        return self.entities.items;
    }

    pub fn len(self: @This()) usize {
        return self.entities.items.len;
    }
};


