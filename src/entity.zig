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

pub const EntityGenerator = struct {
    spawn_rate: u32,
    last_update: u64,
    active: bool,

    pub fn init(spawn_rate: u32) @This() {
        return .{
            .spawn_rate = spawn_rate,
            .last_update = spawn_rate,
            .active = true,
        };
    }


    pub fn stop(self: *@This()) void {
        self.active = false;
    }
    pub fn update(self: *@This(), entities: *EntityStore, elapsed_ms: u64) !void {
        if (! self.active) return;
        self.last_update += elapsed_ms;
        if (self.last_update > self.spawn_rate) {
            self.last_update = 0;
            try entities.addObject(Partical.init(
                @intCast(entities.len() + 1),
                .{
                    @as(f32, @floatFromInt(rl.getScreenWidth())) * 0.75,
                    @as(f32, @floatFromInt(rl.getScreenHeight())) * 0.25,
                },
                .{ 0.0, 0.0 },
                10,
                rl.Color.white,
            ));
        }
    }
};
