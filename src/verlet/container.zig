const rl = @import("raylib");
const EntityStore = @import("entity.zig").EntityStore;

pub const Container = struct {
    center_x: f32,
    center_y: f32,
    radius: f32,
    color: u32,

    pub fn init(position: [2]f32, radius: f32, color: u32) @This() {
        return .{
            .center_x = position[0],
            .center_y = position[1],
            .radius = radius,
            .color = color,
        };
    }

    pub fn isPointInside(self: @This(), point: [2]f32) bool {
        const dx = self.center_x - point[0];
        const dy = self.center_y - point[1];
        const dist2 = dx * dx + dy * dy;
        return dist2 < self.radius * self.radius;
    }

    pub fn constrainParticals(self: @This(), particals: *EntityStore) void {
        for (particals.getObjects()) |*p| {
            const dcp_x = self.center_x - p.pos_x;
            const dcp_y = self.center_y - p.pos_y;
            const dist = @sqrt(dcp_x * dcp_x + dcp_y * dcp_y);
            if (dist > (self.radius - p.radius)) {
                const n_x = dcp_x / dist;
                const n_y = dcp_y / dist;
                p.pos_x = self.center_x - n_x * (self.radius - p.radius);
                p.pos_y = self.center_y - n_y * (self.radius - p.radius);
            }
        }
    }
};

pub fn render(container: *const Container) void {
    rl.drawCircle(
        @as(i32, @intFromFloat(container.center_x)),
        @as(i32, @intFromFloat(container.center_y)),
        container.radius,
        rl.getColor(container.color),
    );
}
