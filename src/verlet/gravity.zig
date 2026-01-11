const EntityStore = @import("entity.zig").EntityStore;

pub const Gravity = struct {
    g_x: f32 = 0,
    g_y: f32 = 1000,
    active: bool = true,

    pub fn init() @This() {
        return .{};
    }

    pub fn update(self: @This(), entities: *EntityStore, _: u64) void {
        if (!self.active) return;
        for (entities.getObjects()) |*partical| {
            partical.accel_x += self.g_x;
            partical.accel_y += self.g_y;
        }
    }
};
