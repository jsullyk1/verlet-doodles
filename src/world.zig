const Vec2 = @Vector(2, f32);
const rl = @import("raylib");
const EntityStore = @import("entity.zig").EntityStore;

pub const World = struct {
    center: Vec2,
    radius: f32,
    color: rl.Color,

    pub fn init(position: [2]f32, radius: f32) @This() {
        return .{
            .center = Vec2{ position[0], position[1] },
            .radius = radius,
            .color = rl.Color.black,
        };
    }

    pub fn draw(self: @This(), entities: *EntityStore) void {
        rl.drawCircle(
            @as(i32, @intFromFloat(self.center[0])),
            @as(i32, @intFromFloat(self.center[1])),
            self.radius,
            self.color,
        );
        for (entities.getObjects()) |*partical| {
            partical.draw();
        }
    }

    pub fn update(_: @This(), entities: *EntityStore, elapsed_ms: u64) void {
        for (entities.getObjects()) |*partical| {
            partical.updatePosition(1.0 / @as(f32, @floatFromInt(1000 / elapsed_ms)));
        }
    }

    pub fn relax(self: @This(), entities: *EntityStore) void {
        for (entities.getObjects()) |*p| {
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
