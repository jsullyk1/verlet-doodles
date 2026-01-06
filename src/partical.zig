const rl = @import("raylib");
const print = @import("std").debug.print;
const Vec2 = @Vector(2, f32);

pub const Partical = struct {
    id: i32,
    current_position: Vec2,
    last_position: Vec2,
    acceleration: Vec2,
    radius: f32,
    color: rl.Color,

    pub fn init(
        id: i32,
        start_position: [2]f32,
        start_velocity: [2]f32,
        radius: f32,
        color: rl.Color,
    ) @This() {
        return .{
            .id = id,
            .current_position = Vec2{ start_position[0], start_position[1] },
            .last_position = start_position - Vec2{ start_velocity[0], start_velocity[1] },
            .acceleration = @as(Vec2, @splat(0.0)),
            .radius = radius,
            .color = color,
        };
    }

    pub fn updatePosition(self: *@This(), dt: f32) void {
        const velocity = self.current_position - self.last_position;

        self.last_position = self.current_position;
        self.current_position = self.last_position + velocity + self.acceleration * @as(Vec2, @splat(dt * dt));
        self.acceleration = @as(Vec2, @splat(0));
    }

    pub fn accelerate(self: *@This(), acceleration: Vec2) void {
        self.acceleration = acceleration;
    }

    pub fn draw(self: @This()) void {
        rl.drawCircle(
            @as(i32, @intFromFloat(self.current_position[0])),
            @as(i32, @intFromFloat(self.current_position[1])),
            @as(f32, self.radius),
            self.color,
        );
    }
};

