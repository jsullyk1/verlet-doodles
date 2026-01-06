const EntityStore = @import("entity.zig").EntityStore;
const Vec2 = @Vector(2, f32);
const std = @import("std");

pub fn relax(entities: *EntityStore) void {
    const particals = entities.getObjects();
    const response_coef = 0.95;
    for (0..particals.len) |i| {
        var p1 = &particals[i];
        for (i+1..particals.len) |j| {
            var p2 = &particals[j];
            const v = p1.current_position - p2.current_position;
            const dist2 = @reduce(.Add, v * v);
            const min_dist = p1.radius + p2.radius;
            if (dist2 < min_dist * min_dist) {
                const dist =  @sqrt(dist2);
                const n = v / @as(Vec2, @splat(dist));
                const mass_ratio_1 = p1.radius / (p1.radius + p2.radius);
                const mass_ratio_2 = p2.radius / (p1.radius + p2.radius);

                const delta = @as(Vec2, @splat(0.5 * response_coef * (dist - min_dist)));
                p1.current_position -= n * (@as(Vec2, @splat(mass_ratio_1)) * delta);
                p2.current_position += n * (@as(Vec2, @splat(mass_ratio_2)) * delta);
            }
        } 
    }
}

