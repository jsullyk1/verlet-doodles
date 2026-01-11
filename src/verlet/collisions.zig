const EntityStore = @import("entity.zig").EntityStore;

pub fn resolve(entities: *EntityStore) void {
    const particals = entities.getObjects();
    const response_coef = 0.90;
    for (0..particals.len) |i| {
        var p1 = &particals[i];
        for (i+1..particals.len) |j| {
            var p2 = &particals[j];
            const dx = p1.pos_x - p2.pos_x;
            const dy = p1.pos_y - p2.pos_y;
            const dist = @sqrt(dx * dx + dy * dy);
            const min_dist = p1.radius + p2.radius;
            if (dist < min_dist) {
                const norm_x = dx / dist;
                const norm_y = dy / dist;
                const mass_ratio_1 = p1.radius / (p1.radius + p2.radius);
                const mass_ratio_2 = p2.radius / (p1.radius + p2.radius);
                const magnitude = response_coef * (dist - min_dist);
                p1.pos_x -= norm_x * mass_ratio_1 * magnitude;
                p1.pos_y -= norm_y * mass_ratio_1 * magnitude;
                p2.pos_x += norm_x * mass_ratio_2 * magnitude;
                p2.pos_y += norm_y * mass_ratio_2 * magnitude;
            }
        } 
    }
}

