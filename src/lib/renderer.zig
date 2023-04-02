const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
    @cInclude("/opt/homebrew/Cellar/sdl2_ttf/2.20.2/include/SDL2/SDL_ttf.h");
    // @cInclude("/opt/homebrew/Cellar/sdl_ttf/2.0.11_2/include/sdl/SDL_ttf.h");
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

        if (c.TTF_Init() == -1) {
            std.debug.print("Problem with TTF", .{});
        }

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

    pub fn drawText(self: *Self) void {
        // Init fonts
        // _ = c.TTF_Init();

        //this opens a font style and sets a size
        const Sans: ?*c.TTF_Font = c.TTF_OpenFont("SIXTY.ttf", 24);

        // this is the color in rgb format,
        // maxing out all would give you the color white,
        // and it will be your text's color
        // var white: c.SDL_Color = undefined;
        // white.r = 255;
        // white.g = 255;
        // white.b = 255;

        var white = .{ .r = 255, .g = 255, .b = 255, .a = 255 };

        // as TTF_RenderText_Solid could only be used on
        // SDL_Surface then you have to create the surface first
        var surfaceMessage =
            c.TTF_RenderText_Solid(Sans, "put your text here", white);

        // now you can convert it into a texture
        var message = c.SDL_CreateTextureFromSurface(self.sdl_renderer, surfaceMessage);

        var message_rect: c.SDL_Rect = undefined; //create a rect
        message_rect.x = 100; //controls the rect's x coordinate
        message_rect.y = 100; // controls the rect's y coordinte
        message_rect.w = 1000; // controls the width of the rect
        message_rect.h = 1000; // controls the height of the rect

        // (0,0) is on the top left of the window/screen,
        // think a rect as the text's box,
        // that way it would be very simple to understand

        // Now since it's a texture, you have to put RenderCopy
        // in your game loop area, the area where the whole code executes

        // you put the renderer's name first, the Message,
        // the crop size (you can ignore this if you don't want
        // to dabble with cropping), and the rect which is the size
        // and coordinate of your texture
        _ = c.SDL_RenderCopy(self.sdl_renderer, message, null, &message_rect);

        // Don't forget to free your surface and texture
        // c.SDL_FreeSurface(surfaceMessage);
        // c.SDL_DestroyTexture(message);
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
