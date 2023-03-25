const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const Renderer = @import("lib/renderer.zig").Renderer;
const Input = @import("lib/input.zig").Input;

const os = std.os;

const CELL_SIZE = 20;

var speed: u8 = 100;

const ErrorSet = error{SDLError};

pub const SCREEN_WIDTH = 600;
pub const SCREEN_HEIGHT = 600;

const MAX_HEIGHT = @divTrunc(SCREEN_HEIGHT, CELL_SIZE);
const MAX_WIDTH = @divTrunc(SCREEN_WIDTH, CELL_SIZE);

var RNG = std.rand.DefaultPrng.init(0);
var random = std.rand.DefaultPrng.random(&RNG);

pub fn main() anyerror!void {
    var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var renderer = try Renderer.init(.{ .allocator = &arena.child_allocator, .title = "Tetriz", .x = 0, .y = 0, .w = 600, .h = 400, .flags = c.SDL_WINDOW_SHOWN });
    defer renderer.deinit();

    var game_over = false;

    while (!game_over) {
        Input.listen();

        renderer.render();
        c.SDL_Delay(16);
    }
}

fn quit() void {
    c.SDL_Quit();
}
