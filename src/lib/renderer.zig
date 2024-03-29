const std = @import("std");
const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_ttf.h");
});

pub const RendererOptions = struct { title: [*c]const u8, x: u16 = 0, y: u16 = 0, w: u16 = 600, h: u16 = 400, flags: u32 = c.SDL_WINDOW_SHOWN, allocator: *std.mem.Allocator };

pub const Renderer = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,

    sdl_renderer: *c.SDL_Renderer = undefined,
    sdl_window: *c.SDL_Window = undefined,
    sdl_rect: c.SDL_Rect = undefined,

    font: ?*c.TTF_Font = undefined,

    pub fn init(options: RendererOptions) !*Renderer {
        var renderer = try options.allocator.create(Renderer);

        _ = c.SDL_Init(c.SDL_INIT_EVERYTHING);

        if (c.TTF_Init() == -1) {
            std.debug.print("Problem with TTF", .{});
        }

        const title = options.title;

        renderer.sdl_window = c.SDL_CreateWindow(title, options.x, options.y, options.w, options.h, options.flags) orelse unreachable;

        renderer.sdl_renderer = c.SDL_CreateRenderer(renderer.sdl_window, 0, 0) orelse unreachable;

        renderer.sdl_rect = c.SDL_Rect{ .x = @intCast(0), .y = @intCast(0), .w = 10, .h = 10 };

        renderer.font = c.TTF_OpenFont("04B_19__.ttf", 124);

        _ = c.SDL_SetRenderDrawBlendMode(renderer.sdl_renderer, c.SDL_BLENDMODE_BLEND);

        return renderer;
    }

    pub fn strokeRect(self: *Self, x: i32, y: i32, w: i32, h: i32, r: u8, g: u8, b: u8, a: u8) void {
        _ = c.SDL_SetRenderDrawColor(self.sdl_renderer, r, g, b, a);

        self.sdl_rect.w = @intCast(w);
        self.sdl_rect.h = @intCast(h);

        self.sdl_rect.x = @intCast(x);
        self.sdl_rect.y = @intCast(y);

        _ = c.SDL_RenderDrawRect(self.sdl_renderer, &self.sdl_rect);
    }

    pub fn fillRect(self: *Self, x: i32, y: i32, w: i32, h: i32, r: u8, g: u8, b: u8, a: u8) void {
        _ = c.SDL_SetRenderDrawColor(self.sdl_renderer, r, g, b, a);

        self.sdl_rect.w = @intCast(w);
        self.sdl_rect.h = @intCast(h);

        self.sdl_rect.x = @intCast(x);
        self.sdl_rect.y = @intCast(y);

        _ = c.SDL_RenderFillRect(self.sdl_renderer, &self.sdl_rect);
    }

    pub fn drawText(self: *Self, x: c_int, y: c_int, text: []u8) void {
        std.debug.print("\n score {s}", .{text});

        var surfaceMessage =
            c.TTF_RenderText_Solid(self.font, text.ptr, .{ .r = 100, .g = 100, .b = 100, .a = 255 });

        // now you can convert it into a texture
        var message = c.SDL_CreateTextureFromSurface(self.sdl_renderer, surfaceMessage);

        self.sdl_rect.x = x; //controls the rect's x coordinate
        self.sdl_rect.y = y; // controls the rect's y coordinte
        self.sdl_rect.w = 100; // controls the width of the rect
        self.sdl_rect.h = 100; // controls the height of the rect

        // (0,0) is on the top left of the window/screen,
        // think a rect as the text's box,
        // that way it would be very simple to understand

        // Now since it's a texture, you have to put RenderCopy
        // in your game loop area, the area where the whole code executes

        // you put the renderer's name first, the Message,
        // the crop size (you can ignore this if you don't want
        // to dabble with cropping), and the rect which is the size
        // and coordinate of your texture
        _ = c.SDL_RenderCopy(self.sdl_renderer, message, null, &self.sdl_rect);

        // Don't forget to free your surface and texture
        c.SDL_FreeSurface(surfaceMessage);
        c.SDL_DestroyTexture(message);
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
