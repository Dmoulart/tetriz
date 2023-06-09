const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
});

const Renderer = @import("lib/renderer.zig").Renderer;
const Input = @import("lib/input.zig").Input;
const Cell = @import("cell.zig").Cell;
const Game = @import("game.zig").Game;
const Score = @import("score.zig");

const Conf = @import("conf.zig");

const os = std.os;

var speed: u8 = 100;

var RNG = std.rand.DefaultPrng.init(0);
var random = std.rand.DefaultPrng.random(&RNG);

pub fn main() anyerror!void {
    var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = &arena.child_allocator;

    var renderer = try Renderer.init(.{ .allocator = allocator, .title = "Tetriz", .x = 0, .y = 0, .w = Conf.SCREEN_WIDTH, .h = Conf.SCREEN_HEIGHT, .flags = c.SDL_WINDOW_SHOWN });
    defer renderer.deinit();

    const game = try Game.init(allocator);

    game.setRenderer(renderer);
    game.setup();

    _ = try game.createPlayerBlock();

    while (!game.game_over) {
        try game.update();
    }

    try Score.write(game.score, allocator);
}

fn quit() void {
    c.SDL_Quit();
    std.os.exit(0);
}
