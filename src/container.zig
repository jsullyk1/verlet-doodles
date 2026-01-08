const Vec2 = @Vector(2, f32);
const rl = @import("raylib");
const EntityStore = @import("entity.zig").EntityStore;

pub const Container = struct {
    center: Vec2,
    radius: f32,
    color: u32,

    pub fn init(position: [2]f32, radius: f32, color: u32) @This() {
        return .{
            .center = Vec2{ position[0], position[1] },
            .radius = radius,
            .color = color,
        };
    }

    pub fn constrainParticals(self: @This(), particals: *EntityStore) void {
        for (particals.getObjects()) |*p| {
            const v = self.center - p.current_position;
            const dist = @sqrt(@reduce(.Add, v * v));
            const c_dist = self.radius - p.radius;
            if (dist > c_dist) {
                const n = v / @as(Vec2, @splat(dist));
                p.current_position = self.center - (n * @as(Vec2, @splat(c_dist)));
            }
        }
    }
};

pub fn render(container: *const Container) void {
    rl.drawCircle(
        @as(i32, @intFromFloat(container.center[0])),
        @as(i32, @intFromFloat(container.center[1])),
        container.radius,
        rl.getColor(container.color),
    );
}
