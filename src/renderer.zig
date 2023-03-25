const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const os = std.os;

const ErrorSet = error{SDLError};

pub const SCREEN_WIDTH = 600;
pub const SCREEN_HEIGHT = 600;

pub const RendererOptions = struct { title: []u8, x: u16 = 0, y: u16 = 0, w: u16 = 600, h: u16 = 400, flags: u32 = c.SDL_WINDOW_SHOWN, allocator: *std.mem.Allocator };

pub const Renderer = struct {
    window: anyopaque,
    sdl_renderer: anyopaque,
    allocator: *std.mem.Allocator,
    const Self = @This();

    pub fn init(options: RendererOptions) !*Renderer {
        var renderer = options.allocator.create(Renderer);

        _ = c.SDL_Init(c.SDL_INIT_EVERYTHING);
        defer c.SDL_Quit();

        renderer.window = c.SDL_CreateWindow(options.title, options.x, options.y, options.w, options.h, options.flags);
        if (renderer.window == null) {
            return ErrorSet.SDLError;
        }
        
        renderer.sdl_renderer = c.SDL_CreateRenderer(renderer.window, 0, 0);
        defer c.SDL_DestroyRenderer(renderer);
    }
};
