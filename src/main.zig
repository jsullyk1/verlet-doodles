const rl = @import("raylib");
const std = @import("std");
const print = @import("std").debug.print;
const Partical = @import("partical.zig").Partical;
const ParticalEmitter = @import("partical.zig").ParticalEmitter;
const updatePositions = @import("partical.zig").updatePositions;
const drawParticals = @import("partical.zig").drawParticals;
const EntitiesStore = @import("entity.zig").EntityStore;
const Gravity = @import("gravity.zig").Gravity;
const collision = @import("collisions.zig");
const World = @import("world.zig").World;
const Vec2 = @Vector(2, f32);

const Config = struct {
    screenWidth: i32 = 900,
    screenHeight: i32 = 900,
    updateRateHz: i32 = 60,
    numSubsteps: i32 = 16,
    spawnRate: i32 = 50,
};

pub fn main() !void {
    const config = Config{};

    // Init window
    rl.initWindow(config.screenWidth, config.screenHeight, "Physics!!");
    defer rl.closeWindow();
    rl.setTargetFPS(config.updateRateHz);

    // Init the entity generation system.
    var entities = EntitiesStore.init();
    defer entities.deinit();
    var emitter = ParticalEmitter.init(.{
        @as(f32, config.screenWidth * 3 / 4),
        @as(f32, config.screenHeight / 4) },
        config.spawnRate,
    );
    var gravity = Gravity.init();
    var world = World.init(
        .{
            @as(f32, config.screenWidth / 2),
            @as(f32, config.screenHeight / 2),
        },
        @min(@as(f32, config.screenWidth / 2 - 5), @as(f32, config.screenHeight / 2 - 5)),
    );

    const sim_ms = 1000 / config.updateRateHz;
    while (!rl.windowShouldClose()) {
        if (entities.len() > 10 and rl.getFPS() < 3 * config.updateRateHz / 4) emitter.stop();
        try emitter.update(&entities, sim_ms);
        gravity.update(&entities, sim_ms);
        // Relax constraints
        for (0..config.numSubsteps) |_| {
            world.relax(&entities);
            collision.relax(&entities);
        }
        updatePositions(&entities, sim_ms);

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);
        world.draw();
        drawParticals(&entities);
        rl.drawFPS(config.screenWidth - 80, 20);
        rl.drawText(rl.textFormat("Pct: %d", .{entities.len()}), 20, 40, 20, rl.Color.black);
        rl.drawText("Verlet Simulation", 20, 20, 20, rl.Color.black);
    }
}
