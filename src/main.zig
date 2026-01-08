const App = @import("app.zig").App;
const Config = @import("app.zig").Config;

pub fn main() !void {
    const config = Config{};

    var app = try App.init(config);
    defer app.deinit();
    try app.run();
}
