const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const RendererOptions = struct { title: [*c]const u8, x: u16 = 0, y: u16 = 0, w: u16 = 600, h: u16 = 400, flags: u32 = c.SDL_WINDOW_SHOWN, allocator: *std.mem.Allocator };

pub const Renderer = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,

    sdl_renderer: *c.SDL_Renderer = undefined,
    sdl_window: *c.SDL_Window = undefined,

    pub fn init(options: RendererOptions) !*Renderer {
        var renderer = try options.allocator.create(Renderer);

        _ = c.SDL_Init(c.SDL_INIT_EVERYTHING);

        const title = options.title;

        renderer.sdl_window = c.SDL_CreateWindow(title, options.x, options.y, options.w, options.h, options.flags) orelse unreachable;

        renderer.sdl_renderer = c.SDL_CreateRenderer(renderer.sdl_window, 0, 0) orelse unreachable;

        return renderer;
    }

    pub fn render(self: *Self) void {
        _ = c.SDL_RenderClear(self.sdl_renderer);
        _ = c.SDL_RenderPresent(self.sdl_renderer);
    }

    pub fn deinit(self: *Self) void {
        c.SDL_Quit();
        c.SDL_DestroyRenderer(self.sdl_renderer);
    }
};
