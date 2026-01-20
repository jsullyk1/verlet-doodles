const std = @import("std");

const rl = @import("raylib");

const Partical = @import("partical.zig").Partical;
const Wall = @import("wall.zig").Wall;
const container = @import("container.zig");
const ParticalEmitter = @import("partical.zig").ParticalEmitter;
const updateVerlet = @import("partical.zig").updatePositionsVerlet2;
const drawParticals = @import("partical.zig").drawParticals;
const EntitiesStoreAOS = @import("entity.zig").EntityStoreAOS;
const Gravity = @import("gravity.zig").Gravity;
const collision = @import("collisions.zig");

pub const Config = struct {
    screenWidth: u32 = 900,
    screenHeight: u32 = 900,
    updateRateHz: u32 = 60,
    numSubsteps: u32 = 6,
    spawnRate: u32 = 50,
};

pub const App = struct {
    config: Config,
    particals: EntitiesStoreAOS(Partical),
    walls: EntitiesStoreAOS(Wall),
    emitter: ParticalEmitter,
    gravity: Gravity,

    pub fn init(config: Config) !@This() {
        rl.setTraceLogLevel(rl.TraceLogLevel.none);
        const particals = EntitiesStoreAOS(Partical).init();
        var walls = EntitiesStoreAOS(Wall).init();
        const top = .{ @as(f32, @floatFromInt(rl.getScreenWidth()))/2, 0.0};
        const right = .{ @as(f32, @floatFromInt(rl.getScreenWidth())), @as(f32, @floatFromInt(rl.getScreenHeight())) / 2};
        const bottom = .{ @as(f32, @floatFromInt(rl.getScreenWidth())) / 2, @as(f32, @floatFromInt(rl.getScreenHeight()))};
        const left = .{ 0.0, @as(f32, @floatFromInt(rl.getScreenHeight())) / 2};
        try walls.addObject(Wall.init(top, .{0.0, 1.0}, 0xFFFFFFFF));
        try walls.addObject(Wall.init(right, .{-1.0, 0.0}, 0xFFFFFFFF));
        try walls.addObject(Wall.init(bottom, .{0.0, -1.0}, 0xFFFFFFFF));
        try walls.addObject(Wall.init(left, .{1.0, 0.0}, 0xFFFFFFFF));
        const emitter = ParticalEmitter.init(
            config.spawnRate,
        );
        const gravity = Gravity.init();
        return .{
            .config = config,
            .particals = particals,
            .walls = walls,
            .emitter = emitter,
            .gravity = gravity,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.particals.deinit();
    }

    pub fn reset(self: *@This()) void {
        self.particals.clear();
        self.emitter.stop();
    }

    pub fn run(self: *@This()) !void {
        const dt = 1.0 / @as(f32, @floatFromInt(self.config.updateRateHz));
        rl.initWindow(@intCast(self.config.screenWidth), @intCast(self.config.screenHeight), "Physics!!");
        defer rl.closeWindow();
        rl.setTargetFPS(@intCast(self.config.updateRateHz));

        while (!rl.windowShouldClose()) {
            if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
                const mpos_x = @as(f32, @floatFromInt(rl.getMouseX()));
                const mpos_y = @as(f32, @floatFromInt(rl.getMouseY()));
                self.emitter.setPosition(.{ mpos_x, mpos_y });
                try self.emitter.emitPartical(&self.particals);
            }
            if (rl.isKeyPressed(rl.KeyboardKey.r)) {
                self.reset();
            }
            if (rl.isKeyPressed(rl.KeyboardKey.g)) {
                self.gravity.active = !self.gravity.active;
            }

            try self.update(dt);
            self.render();
        }
    }

    fn update(self: *@This(), dt: f32) !void {
        if (self.particals.len() > 10 and rl.getFPS() < 3 * self.config.updateRateHz / 4) self.emitter.stop();
        try self.emitter.update(&self.particals, @as(u32, @intFromFloat(dt * 1000.0)));

        // Relax constraints
        const step_dt = dt / @as(f32, @floatFromInt(self.config.numSubsteps));
        for (0..self.config.numSubsteps) |_| {
            collision.resolve2(&self.particals);
            self.gravity.update(&self.particals);
            updateVerlet(&self.particals, step_dt);
        }
    }

    fn render(self: *@This()) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        // container.render(&self.boundary);
        drawParticals(&self.particals);
        rl.drawFPS(@as(i32, @intCast(self.config.screenWidth)) - 80, 20);
        rl.drawText("Verlet Simulation", 20, 20, 20, rl.Color.black);
        rl.drawText("Click the circle to spawn particles", 20, 40, 14, rl.Color.dark_green);
        rl.drawText("Press 'r' to reset", 20, 54, 14, rl.Color.dark_green);
        rl.drawText("Pres 'g' to toggle gravity", 20, 68, 14, rl.Color.dark_green);
        rl.drawText("Press ESC to quit", 20, 82, 14, rl.Color.dark_green);
        rl.drawText(rl.textFormat("Pct: %d", .{self.particals.len()}), 20, 96, 14, rl.Color.dark_blue);
    }
};
