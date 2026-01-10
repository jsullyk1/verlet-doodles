const rl = @import("raylib");

const Partical = @import("partical.zig").Partical;
const container = @import("container.zig");
const ParticalEmitter = @import("partical.zig").ParticalEmitter;
const updatePositions = @import("partical.zig").updatePositions;
const drawParticals = @import("partical.zig").drawParticals;
const EntitiesStore = @import("entity.zig").EntityStore;
const Gravity = @import("gravity.zig").Gravity;
const collision = @import("collisions.zig");

const Vec2 = @Vector(2, f32);

pub const Config = struct {
    screenWidth: u32 = 900,
    screenHeight: u32 = 900,
    updateRateHz: u32 = 60,
    numSubsteps: u32 = 8,
    spawnRate: u32 = 50,
};

pub const App = struct {
    config: Config,
    particals: EntitiesStore,
    emitter: ParticalEmitter,
    gravity: Gravity,
    boundary: container.Container,

    pub fn init(config: Config) !@This() {
        const particals = EntitiesStore.init();
        const emitter = ParticalEmitter.init(
            config.spawnRate,
        );
        const gravity = Gravity.init();
        const boundary = container.Container.init(
            .{
                @as(f32, @floatFromInt(config.screenWidth / 2)),
                @as(f32, @floatFromInt(config.screenHeight / 2)),
            },
            @min(@as(f32, @floatFromInt(config.screenWidth / 2 - 5)), @as(f32, @floatFromInt(config.screenHeight / 2 - 5))),
            0x000000FF,
        );
        return .{
            .config = config,
            .particals = particals,
            .emitter = emitter,
            .gravity = gravity,
            .boundary = boundary,
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
        const sim_ms = 1000 / self.config.updateRateHz;
        rl.initWindow(@intCast(self.config.screenWidth), @intCast(self.config.screenHeight), "Physics!!");
        defer rl.closeWindow();
        rl.setTargetFPS(@intCast(self.config.updateRateHz));

        while (!rl.windowShouldClose()) {
            if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
                const mpos_x = @as(f32, @floatFromInt(rl.getMouseX()));
                const mpos_y = @as(f32, @floatFromInt(rl.getMouseY()));
                if (self.boundary.isPointInside(.{ mpos_x, mpos_y })) {
                    self.emitter.setPosition(.{ mpos_x, mpos_y });
                    if(!self.emitter.active) self.emitter.start();
                }
            }
            if (rl.isKeyPressed(rl.KeyboardKey.r)) {
                self.reset();
            }
            if (rl.isKeyPressed(rl.KeyboardKey.g)) {
                self.gravity.active = !self.gravity.active;
            }

            try self.update(sim_ms);
            self.render();
        }
    }

    fn update(self: *@This(), sim_ms: u32) !void {
        if (self.particals.len() > 10 and rl.getFPS() < 3 * self.config.updateRateHz / 4) self.emitter.stop();
        try self.emitter.update(&self.particals, sim_ms);
        self.gravity.update(&self.particals, sim_ms);

        // Relax constraints
        for (0..self.config.numSubsteps) |_| {
            self.boundary.constrainParticals(&self.particals);
            collision.resolve(&self.particals);
        }
        updatePositions(&self.particals, sim_ms);
    }

    fn render(self: *@This()) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.white);
        container.render(&self.boundary);
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
