
pub const Wall = struct {
    point_x: f32,
    point_y: f32,
    norm_x: f32,
    norm_y: f32,
    color: u32,

    pub fn init(
        point: [2]f32,
        norm: [2]f32,
        color: u32,
    ) @This() {
        return .{
            .point_x = point[0],
            .point_y = point[1],
            .norm_x = norm[0],
            .norm_y = norm[1],
            .color = color,
        };
    }
};
