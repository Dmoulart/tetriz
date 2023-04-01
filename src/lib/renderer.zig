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
    sdl_rect: c.SDL_Rect = undefined,

    pub fn init(options: RendererOptions) !*Renderer {
        var renderer = try options.allocator.create(Renderer);

        _ = c.SDL_Init(c.SDL_INIT_EVERYTHING);

        const title = options.title;

        renderer.sdl_window = c.SDL_CreateWindow(title, options.x, options.y, options.w, options.h, options.flags) orelse unreachable;

        renderer.sdl_renderer = c.SDL_CreateRenderer(renderer.sdl_window, 0, 0) orelse unreachable;

        renderer.sdl_rect = c.SDL_Rect{ .x = @intCast(c_int, 0), .y = @intCast(c_int, 0), .w = 10, .h = 10 };

        _ = c.SDL_SetRenderDrawBlendMode(renderer.sdl_renderer, c.SDL_BLENDMODE_BLEND);

        return renderer;
    }

    pub fn strokeRect(self: *Self, x: i32, y: i32, w: i32, h: i32, r: u8, g: u8, b: u8, a: u8) void {
        _ = c.SDL_SetRenderDrawColor(self.sdl_renderer, r, g, b, a);

        self.sdl_rect.w = @intCast(c_int, w);
        self.sdl_rect.h = @intCast(c_int, h);

        self.sdl_rect.x = @intCast(c_int, x);
        self.sdl_rect.y = @intCast(c_int, y);

        _ = c.SDL_RenderDrawRect(self.sdl_renderer, &self.sdl_rect);
    }

    pub fn fillRect(self: *Self, x: i32, y: i32, w: i32, h: i32, r: u8, g: u8, b: u8, a: u8) void {
        _ = c.SDL_SetRenderDrawColor(self.sdl_renderer, r, g, b, a);

        self.sdl_rect.w = @intCast(c_int, w);
        self.sdl_rect.h = @intCast(c_int, h);

        self.sdl_rect.x = @intCast(c_int, x);
        self.sdl_rect.y = @intCast(c_int, y);

        _ = c.SDL_RenderFillRect(self.sdl_renderer, &self.sdl_rect);
    }

    pub fn clear(self: *Self) void {
        _ = c.SDL_SetRenderDrawColor(self.sdl_renderer, 0, 0, 0, 255);
        _ = c.SDL_RenderClear(self.sdl_renderer);
    }

    pub fn render(self: *Self) void {
        _ = c.SDL_RenderPresent(self.sdl_renderer);
    }

    pub fn deinit(self: *Self) void {
        c.SDL_Quit();
        c.SDL_DestroyRenderer(self.sdl_renderer);
    }
};
