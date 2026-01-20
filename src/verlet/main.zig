const log = @import("core").log;
const App = @import("app.zig").App;

pub fn main() !void {
    const logger = log.scoped(.main);
    logger.info("Starting Verlet A\n", .{});
    var app = try App.init(.{});
    try app.run();
}
