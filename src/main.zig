const rl = @import("raylib");

const primatives = @import("primatives.zig");

const GameConfig = @import("GameConfig.zig").GameConfig;
const Player = @import("Player.zig").Player;
const Bullet = @import("Bullet.zig").Bullet;
const Invader = @import("Invader.zig").Invader;
const InvaderBullet = @import("InvaderBullet.zig").InvaderBullet;
const Shield = @import("Shield.zig").Shield;

fn IncrementLevelReset(
    player: *Player,
    bullets: []Bullet,
    invader_bullets: []InvaderBullet,
    shields: []Shield,
    invaders: anytype,
    invader_directions: *f32,
    level: *i32,
    invader_shoot_chance: *i32,
    config: GameConfig,
) void {
    const next_level: i32 = level.* + 1;

    player.* = Player.init(
        @as(f32, @floatFromInt(config.screenWidth)) / 2 - config.playerWidth / 2,
        @as(f32, @floatFromInt(config.screenHeight)) - 60.0,
        config.playerWidth,
        config.playerHeight,
        config.playerSpeed,
    );

    for (bullets) |*bullet| {
        bullet.active = false;
    }

    for (invader_bullets) |*bullet| {
        bullet.active = false;
    }

    for (shields, 0..) |*shield, i| {
        const x = config.shieldStartX + @as(f32, @floatFromInt(i)) * config.shieldSpacing;
        shield.* = Shield.init(
            x,
            config.shieldY,
            config.shieldWidth,
            config.shieldHeight,
            config.shieldHealth,
        );
    }

    for (invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = config.invaderStartX + @as(f32, @floatFromInt(j)) * config.invaderSpacingX;
            const y = config.invaderStartY + @as(f32, @floatFromInt(i)) * config.invaderSpacingY;
            invader.* = Invader.init(
                x,
                y,
                config.invaderWidth,
                config.invaderHeight,
                @min(config.invaderSpeed + @as(f32, @floatFromInt(next_level)), 100.0), // increase invader speed
            );
        }
    }

    invader_directions.* = 1.0;
    invader_shoot_chance.* += @min(next_level, 50); //increase invader shoot chance
    level.* = next_level;
}

fn ResetGame(
    player: *Player,
    bullets: []Bullet,
    invader_bullets: []InvaderBullet,
    shields: []Shield,
    invaders: anytype,
    invader_directions: *f32,
    level: *i32,
    invader_shoot_chance: *i32,
    score: *i32,
    config: GameConfig,
) void {
    player.* = Player.init(
        @as(f32, @floatFromInt(config.screenWidth)) / 2 - config.playerWidth / 2,
        @as(f32, @floatFromInt(config.screenHeight)) - 60.0,
        config.playerWidth,
        config.playerHeight,
        config.playerSpeed,
    );

    for (bullets) |*bullet| {
        bullet.active = false;
    }

    for (invader_bullets) |*bullet| {
        bullet.active = false;
    }

    for (shields, 0..) |*shield, i| {
        const x = config.shieldStartX + @as(f32, @floatFromInt(i)) * config.shieldSpacing;
        shield.* = Shield.init(
            x,
            config.shieldY,
            config.shieldWidth,
            config.shieldHeight,
            config.shieldHealth,
        );
    }

    for (invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = config.invaderStartX + @as(f32, @floatFromInt(j)) * config.invaderSpacingX;
            const y = config.invaderStartY + @as(f32, @floatFromInt(i)) * config.invaderSpacingY;
            invader.* = Invader.init(
                x,
                y,
                config.invaderWidth,
                config.invaderHeight,
                config.invaderSpeed,
            );
        }
    }

    level.* = 1;
    score.* = 0;
    invader_directions.* = 1.0;
    invader_shoot_chance.* = 5;
}

pub fn main() void {
    const screenWidth = 800;
    const screenHeight = 600;

    const playerWidth = 50.0;
    const playerHeight = 30.0;
    const playerSpeed = 5.0;
    const maxBullets = 10;

    const bulletWidth = 5.0;
    const bulletHeight = 10.0;
    const bulletSpeed = 10.0;

    const invaderRows = 5;
    const invaderCols = 11;
    const invaderWidth = 40.0;
    const invaderHeight = 30.0;
    const invaderSpeed = 5.0;
    const invaderMoveDelay = 30;
    const invaderStartX = 100.0;
    const invaderDropDistance = 20.0;
    const invaderStartY = 50.0;
    const invaderSpacingX = 60.0;
    const invaderSpacingY = 40.0;
    const invaderMaxBullets = 20;
    const invaderBulletSpeed = 5.0;
    const invaderShootDelay = 60;

    const shieldHealth = 10;
    const shieldCount = 4;
    const shieldWidth = 80.0;
    const shieldHeight = 10.0;
    const shieldStartX = 150.0;
    const shieldY = 450.0;
    const shieldSpacing = 150.0;

    const config = GameConfig{
        .screenWidth = screenWidth,
        .screenHeight = screenHeight,
        .playerWidth = playerWidth,
        .playerHeight = playerHeight,
        .playerSpeed = playerSpeed,
        .bulletWidth = bulletWidth,
        .bulletHeight = bulletHeight,
        .shieldStartX = shieldStartX,
        .shieldY = shieldY,
        .shieldWidth = shieldWidth,
        .shieldHeight = shieldHeight,
        .shieldSpacing = shieldSpacing,
        .shieldHealth = shieldHealth,
        .invaderStartX = invaderStartX,
        .invaderStartY = invaderStartY,
        .invaderWidth = invaderWidth,
        .invaderHeight = invaderHeight,
        .invaderSpacingX = invaderSpacingX,
        .invaderSpacingY = invaderSpacingY,
        .invaderSpeed = invaderSpeed,
    };

    var game_over: bool = false;
    var game_won: bool = false;
    var invader_direction: f32 = 1.0;
    var invader_move_timer: i32 = 0;
    var invader_shoot_timer: i32 = 0;
    var invader_shoot_chance: i32 = 5;

    var level: i32 = 1;
    var score: i32 = 0;

    // Init game objects
    var player = Player.init(
        @as(f32, @floatFromInt(screenWidth)) / 2 - playerWidth / 2,
        @as(f32, @floatFromInt(screenHeight)) - 60.0,
        playerWidth,
        playerHeight,
        playerSpeed,
    );

    var bullets: [maxBullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(
            0,
            0,
            bulletWidth,
            bulletHeight,
            bulletSpeed,
        );
    }

    var invaders: [invaderRows][invaderCols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invaderStartX + @as(f32, @floatFromInt(j)) * invaderSpacingX;
            const y = invaderStartY + @as(f32, @floatFromInt(i)) * invaderSpacingY;
            invader.* = Invader.init(
                x,
                y,
                invaderWidth,
                invaderHeight,
                invaderSpeed,
            );
        }
    }

    var invader_bullets: [invaderMaxBullets]InvaderBullet = undefined;
    for (&invader_bullets) |*bullet| {
        bullet.* = InvaderBullet.init(
            0,
            0,
            bulletWidth,
            bulletHeight,
            invaderBulletSpeed,
        );
    }

    var shields: [shieldCount]Shield = undefined;
    for (&shields, 0..) |*shield, i| {
        const x = shieldStartX + @as(f32, @floatFromInt(i)) * shieldSpacing;
        shield.* = Shield.init(
            x,
            shieldY,
            shieldWidth,
            shieldHeight,
            shieldHealth,
        );
    }

    rl.initWindow(screenWidth, screenHeight, "zink");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const background_image: rl.Image = try rl.loadImage("assets/images/bg1.png");
    defer rl.unloadImage(background_image);

    const background_texture: rl.Texture2D = rl.loadTextureFromImage(background_image);
    defer rl.unloadTexture(background_texture);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);

        // Update Logic
        if (game_over) {
            rl.drawText("GAME OVER", 270, 250, 40, rl.Color.red);
            const score_text = rl.textFormat("Final Score %d", .{score});
            rl.drawText(score_text, 285, 310, 30, rl.Color.white);
            rl.drawText("Press SPACE to play again or ESC to quit", 180, 360, 20, rl.Color.green);
            if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                game_over = false;
                ResetGame(
                    &player,
                    &bullets,
                    &invader_bullets,
                    &shields,
                    &invaders,
                    &invader_direction,
                    &level,
                    &invader_shoot_chance,
                    &score,
                    config,
                );
            }
            continue;
        }

        if (game_won) {
            const level_complete_text = rl.textFormat("Level %d complete", .{level});
            rl.drawText(level_complete_text, 230, 250, 40, rl.Color.gold);
            const score_text = rl.textFormat("Score %d", .{score});
            rl.drawText(score_text, 300, 310, 30, rl.Color.white);
            rl.drawText("Press SPACE to continue to next level", 180, 360, 20, rl.Color.green);
            if (rl.isKeyPressed(rl.KeyboardKey.space)) {
                game_won = false;
                IncrementLevelReset(
                    &player,
                    &bullets,
                    &invader_bullets,
                    &shields,
                    &invaders,
                    &invader_direction,
                    &level,
                    &invader_shoot_chance,
                    config,
                );
            }
            continue;
        }

        player.update();

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }

        for (&bullets) |*bullet| {
            bullet.update();
        }

        for (&bullets) |*bullet| {
            if (bullet.active) {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive) {
                            if (bullet.getRect().intersects(invader.getRect())) {
                                bullet.active = false;
                                invader.alive = false;
                                score += 10;
                                break;
                            }
                        }
                    }
                    for (&shields) |*shield| {
                        if (shield.health > 0) {
                            if (bullet.getRect().intersects(shield.getRect())) {
                                bullet.active = false;
                                shield.health -= 1;
                                score -= 1; // player loose point on shield hit
                                break;
                            }
                        }
                    }
                }
            }
        }

        for (&invader_bullets) |*bullet| {
            bullet.update(screenHeight);
            if (bullet.active) {
                if (bullet.getRect().intersects(player.getRect())) {
                    bullet.active = false;
                    game_over = true;
                    break;
                }
                for (&shields) |*shield| {
                    if (shield.health > 0) {
                        if (bullet.getRect().intersects(shield.getRect())) {
                            bullet.active = false;
                            shield.health -= 1;
                            break;
                        }
                    }
                }
            }
        }
        invader_shoot_timer += 1;
        if (invader_shoot_timer >= invaderShootDelay) {
            invader_shoot_timer = 0;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive and rl.getRandomValue(0, 100) < invader_shoot_chance) {
                        for (&invader_bullets) |*bullet| {
                            if (!bullet.active) {
                                bullet.position_x = invader.position_x + invader.width / 2 - bullet.width / 2;
                                bullet.position_y = invader.position_y + invader.height;
                                bullet.active = true;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }

        invader_move_timer += 1;
        if (invader_move_timer >= invaderMoveDelay) {
            invader_move_timer = 0;

            var hit_edge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + invader.speed * invader_direction;
                        if (next_x < 0 or next_x + invader.width > @as(f32, @floatFromInt(screenWidth))) {
                            hit_edge = true;
                            break;
                        }
                    }
                }
                if (hit_edge) break;
            }

            if (hit_edge) {
                invader_direction *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0.0, invaderDropDistance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invaderSpeed * invader_direction, 0);
                    }
                }
            }

            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        if (invader.getRect().intersects(player.getRect())) {
                            game_over = true;
                        }
                    }
                }
            }
        }

        var all_invaders_dead = true;
        outer_loop: for (&invaders) |*row| {
            for (row) |*invader| {
                if (invader.alive) {
                    all_invaders_dead = false;
                    break :outer_loop;
                }
            }
        }

        if (all_invaders_dead) {
            game_won = true;
        }

        // Draw logic
        rl.drawTexture(
            background_texture,
            screenWidth / 2 - background_texture.width / 2,
            screenHeight / 2 - background_texture.height / 2,
            rl.WHITE,
        );

        const levelText = rl.textFormat("Level %d", .{level});
        rl.drawText(levelText, 15, screenHeight - 30, 25, rl.Color.light_gray);
        const scoreText = rl.textFormat("Score: %d", .{score});
        rl.drawText(scoreText, 600, screenHeight - 30, 25, rl.Color.light_gray);
        rl.drawText("z!nk", 15, 20, 25, rl.Color.green);
        if (level == 1) {
            rl.drawText("Shoot: SPACE, Move: <- ->, Exit: ESC", 415, 20, 20, rl.Color.light_gray);
        }

        for (&shields) |*shield| {
            shield.draw();
        }

        player.draw();

        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }

        for (&invader_bullets) |*bullet| {
            bullet.draw();
        }

        for (&shields) |*shield| {
            shield.draw();
        }
    }
}
