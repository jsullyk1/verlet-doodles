const DefaultPrng = @import("std").Random.DefaultPrng;
const Random = @import("std").Random;

const rl = @import("raylib");

const norm2 = @import("core").math.norm2;
const EntityStore = @import("entity.zig").EntityStore;

var prng = DefaultPrng.init(16);
const rand = prng.random();

pub const Partical = struct {
    pos_x: f32,
    pos_y: f32,
    lpos_x: f32,
    lpos_y: f32,
    accel_x: f32 = 0,
    accel_y: f32 = 0,
    radius: f32,
    color: u32,

    pub fn init(
        start_position: [2]f32,
        start_velocity: [2]f32,
        radius: f32,
        color: u32,
    ) @This() {
        return .{
            .pos_x = start_position[0],
            .pos_y = start_position[1],
            .lpos_x = start_position[0] - start_velocity[0],
            .lpos_y = start_position[1] - start_velocity[1],
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
    active: bool = false,
    pos_x: f32 = 0,
    pos_y: f32 = 0,
    emit_vel_x: f32 = 0,
    emit_vel_y: f32 = 0,
    color: ColorGenerator = .{},

    pub fn init(spawn_rate: u32) @This() {
        return .{
            .spawn_rate = spawn_rate,
        };
    }

    pub fn setPosition(self: *@This(), position: [2]f32) void {
        self.pos_x = position[0];
        self.pos_y = position[1];
    }

    fn setEmitVelocity(self: *@This(), target: [2]f32) void {
        const displacement_x = target[0] - self.pos_x + 1; // avoid a displacement near 0 by adding 1
        const displacement_y = target[1] - self.pos_y + 1;
        const direction_x, const direction_y = norm2(displacement_x, displacement_y);
        self.emit_vel_x = direction_x * 9.0;
        self.emit_vel_y = direction_y * 9.0;
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
            self.setEmitVelocity(
                .{ @as(f32, @floatFromInt(rl.getMouseX())), @as(f32, @floatFromInt(rl.getMouseY())) },
            );
            // Create new partical
            const radius = @as(f32, @floatFromInt(rand.intRangeAtMost(u32, 7, 11)));
            try entities.addObject(Partical.init(
                .{ self.pos_x, self.pos_y },
                .{ self.emit_vel_x, self.emit_vel_y },
                radius,
                self.color.nextRGBA(),
            ));
            self.last_update = 0;
        }
    }
};

pub fn updatePositionsVerlet(particals: *EntityStore, sim_dt: u32) void {
    const dt = @as(f32, @floatFromInt(sim_dt)) / 1000.0;
    for (particals.getObjects()) |*p| {
        const dpl_x = p.pos_x - p.lpos_x;
        const dpl_y = p.pos_y - p.lpos_y;
        p.lpos_x = p.pos_x;
        p.lpos_y = p.pos_y;
        p.pos_x = p.lpos_x + dpl_x + p.accel_x * dt * dt;
        p.pos_y = p.lpos_y + dpl_y + p.accel_y * dt * dt;
        p.accel_x = 0;
        p.accel_y = 0;
    }
}

pub fn drawParticals(particals: *EntityStore) void {
    for (particals.getObjects()) |*p| {
        rl.drawCircle(
            @as(i32, @intFromFloat(p.pos_x)),
            @as(i32, @intFromFloat(p.pos_y)),
            @as(f32, p.radius),
            rl.getColor(p.color),
        );
    }
}
