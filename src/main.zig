const rl = @import("raylib");
const std = @import("std");
const print = @import("std").debug.print;
const Partical = @import("partical.zig").Partical;
const EntitiesStore = @import("entity.zig").EntityStore;
const EntityGenerator = @import("entity.zig").EntityGenerator;
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
    var spawner = EntityGenerator.init(config.spawnRate);
    var gravity = Gravity.init();
    var world = World.init(
        .{
            @as(f32, config.screenWidth / 2),
            @as(f32, config.screenHeight / 2),
        },
        @min(@as(f32, config.screenWidth / 2 - 5), @as(f32, config.screenHeight / 2 - 5)),

    );
    // Init collision system

    // Add initial entities (Walls)
    // Add gravity system
    // Add collision system
    // Add render system

    var timer = try std.time.Timer.start();
    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.white);
        const elapsed_ms = timer.lap() / std.time.ns_per_ms;
        try spawner.update(&entities, elapsed_ms);
        gravity.update(&entities, elapsed_ms);
        // Relax constraints
        for (0..config.numSubsteps) |_| {
            world.relax(&entities);
            collision.relax(&entities);
        }
        world.update(&entities, elapsed_ms);
        world.draw(&entities);
        rl.drawFPS(config.screenWidth - 80, 20);
        rl.drawText("Verlet Simulation", 20, 20, 20, rl.Color.black);
    }
}
