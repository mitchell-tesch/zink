const rl = @import("raylib");

const primatives = @import("primatives.zig");

pub const Shield = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    health: i32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32, health: i32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .health = health,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.health > 0) {
            const alpha: u8 = @as(u8, @intCast(@min(255, 25 * self.health)));
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color{
                    .r = 0,
                    .g = 255,
                    .b = 255,
                    .a = alpha,
                },
            );
        }
    }

    pub fn getRect(self: @This()) primatives.Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};
