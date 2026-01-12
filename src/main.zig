const verlet = @import("verlet");
const log = @import("core").log;

pub fn main() !void {
    const config = verlet.Config{
        // .updateRateHz = 90,
    };
    const logger = log.scoped(.main);
    logger.info("Starting Application", .{});
    var app = try verlet.App.init(config);
    defer app.deinit();
    try app.run();
}
