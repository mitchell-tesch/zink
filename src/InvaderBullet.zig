const rl = @import("raylib");
const primatives = @import("primatives.zig");

pub const InvaderBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32, speed: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = speed,
            .active = false,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.active) {
            rl.drawRectangle(
                @intFromFloat(self.position_x),
                @intFromFloat(self.position_y),
                @intFromFloat(self.width),
                @intFromFloat(self.height),
                rl.Color.orange,
            );
        }
    }

    pub fn update(self: *@This(), screen_height: i32) void {
        if (self.active) {
            self.position_y += self.speed;
            if (self.position_y > @as(f32, @floatFromInt(screen_height))) {
                self.active = false;
            }
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
