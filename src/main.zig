const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
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
    _ = c.SDL_Init(c.SDL_INIT_EVERYTHING);
    defer c.SDL_Quit();

    var window = c.SDL_CreateWindow("Zig-Tetris", 100, 100, SCREEN_WIDTH, SCREEN_HEIGHT, c.SDL_WINDOW_SHOWN);
    if (window == null) {
        return ErrorSet.SDLError;
    }
    defer c.SDL_DestroyWindow(window);

    var renderer = c.SDL_CreateRenderer(window, 0, 0);
    defer c.SDL_DestroyRenderer(renderer);

    var event: c.SDL_Event = undefined;
    var game_over = false;

    var arena: std.heap.ArenaAllocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    // var allocator = &arena.child_allocator;

    while (!game_over) {
        _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(renderer);

        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_KEYDOWN => {},
                c.SDL_QUIT => {
                    game_over = true;
                },
                else => {},
            }
        }

        _ = c.SDL_RenderPresent(renderer);

        c.SDL_Delay(speed);
    }
    c.SDL_Quit();
    std.os.exit(1);
}

pub const Direction = enum(u8) { Top, Left, Right, Bottom };

fn pressedKey(pressedKeyName: []const u8, keyName: []const u8) bool {
    return std.mem.eql(u8, pressedKeyName, keyName);
}
