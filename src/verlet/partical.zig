const rl = @import("raylib");
const DefaultPrng = @import("std").Random.DefaultPrng;
const Random = @import("std").Random;
const print = @import("std").debug.print;
const EntityStore = @import("entity.zig").EntityStore;
const Vec2 = @Vector(2, f32);

var prng = DefaultPrng.init(16);
const rand = prng.random();

pub const Partical = struct {
    current_position: Vec2,
    last_position: Vec2,
    acceleration: Vec2,
    radius: f32,
    color: u32,

    pub fn init(
        start_position: [2]f32,
        start_velocity: [2]f32,
        radius: f32,
        color: u32,
    ) @This() {
        return .{
            .current_position = Vec2{ start_position[0], start_position[1] },
            .last_position = start_position - Vec2{ start_velocity[0], start_velocity[1] },
            .acceleration = @as(Vec2, @splat(0.0)),
            .radius = radius,
            .color = color,
        };
    }
};


const ColorGenerator = struct {
    r: u8 = 255,
    g: u8 = 0,
    b: u8 = 0,
    phase: u8 = 0,
    rate: u8 = 4,

    pub fn nextRGBA(self: *@This()) u32 {
        switch (self.phase) {
            0 => {
                self.g +|= self.rate;
                if (self.g == 255) self.phase = 1;
            },
            1 => {
                self.r -|= self.rate;
                if (self.r == 0) self.phase = 2;
            },
            2 => {
                self.b +|= self.rate;
                if (self.b == 255) self.phase = 3;
            },
            3 => {
                self.g -|= self.rate;
                if (self.g == 0) self.phase = 4;
            },
            4 => {
                self.r +|= self.rate;
                if (self.r == 255) self.phase = 5;
            },
            5 => {
                self.b -|= self.rate;
                if (self.b == 0) self.phase = 0;
            },
            else => {},
        }
        return (@as(u32, self.r) << 24) | (@as(u32, self.g) << 16) | (@as(u32, self.b) << 8) | 0xFF;
    }
};


pub const ParticalEmitter = struct {
    spawn_rate: u32,
    last_update: u64 = 0,
    active: bool = true,
    position: rl.Vector2,
    velocity: rl.Vector2,
    color: ColorGenerator = .{},

    pub fn init(spawn_rate: u32) @This() {
        return .{
            .spawn_rate = spawn_rate,
            .last_update = spawn_rate,
            .active = false,
            .position = rl.Vector2.init(0.0, 0.0),
            .velocity = rl.Vector2.init(0.0, 0.0),
        };
    }

    pub fn setPosition(self: *@This(), position: [2]f32) void {
        self.position = rl.Vector2.init(position[0], position[1]);
    }

    fn updateEmitVelocity(self: *@This()) void {
        const m_pos = rl.Vector2.init(
            @as(f32, @floatFromInt(rl.getMouseX())),
            @as(f32, @floatFromInt(rl.getMouseY())),
        );
        const displacement = rl.Vector2.subtract(m_pos, self.position);
        const direction = rl.Vector2.normalize(displacement);
        self.velocity = rl.Vector2.scale(direction, 9.0);
    }

    pub fn start(self: *@This()) void {
        self.active = true;
    }

    pub fn stop(self: *@This()) void {
        self.active = false;
    }

    pub fn update(self: *@This(), entities: *EntityStore, elapsed_ms: u64) !void {
        if (!self.active) return;
        self.last_update += elapsed_ms;
        if (self.last_update > self.spawn_rate) {
            self.updateEmitVelocity();
            // Create new partical
            const radius = @as(f32, @floatFromInt(rand.intRangeAtMost(u32, 7, 11)));
            try entities.addObject(Partical.init(
                .{ self.position.x, self.position.y },
                .{ self.velocity.x, self.velocity.y },
                radius,
                self.color.nextRGBA(),
            ));
            self.last_update = 0;
        }
    }
};

pub fn updatePositions(particals: *EntityStore, sim_dt: u32) void {
    const fdt = 1.0 / @as(f32, @floatFromInt(1000 / sim_dt));
    for (particals.getObjects()) |*p| {
        const velocity = p.current_position - p.last_position;
        p.last_position = p.current_position;
        p.current_position = p.last_position + velocity + p.acceleration * @as(Vec2, @splat(fdt * fdt));
        p.acceleration = @as(Vec2, @splat(0.0));
    }
}

pub fn drawParticals(particals: *EntityStore) void {
    for (particals.getObjects()) |*p| {
        rl.drawCircle(
            @as(i32, @intFromFloat(p.current_position[0])),
            @as(i32, @intFromFloat(p.current_position[1])),
            @as(f32, p.radius),
            rl.getColor(p.color),
        );
    }
}
