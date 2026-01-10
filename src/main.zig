const verlet = @import("verlet");

pub fn main() !void {
    const config = verlet.Config{
        // .updateRateHz = 90,
    };
    var app = try verlet.App.init(config);
    defer app.deinit();
    try app.run();
}
