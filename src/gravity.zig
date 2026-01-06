const Vec2 = @Vector(2, f32);
const EntityStore = @import("entity.zig").EntityStore;

pub const Gravity = struct {
    g: Vec2,
    active: bool,

    pub fn init() @This() {
        return .{
            .g = Vec2{ 0.0, 1000.0 },
            .active = true,
        };
    }

    pub fn update(self: @This(), entities: *EntityStore, _: u64) void {
        if (!self.active) return;
        for (entities.getObjects()) |*partical| {
            partical.accelerate(self.g);
        }
    }
};
