const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const Input = struct {
    var event: c.SDL_Event = undefined;

    pub fn listen() void {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_KEYDOWN => {},
                c.SDL_QUIT => {
                    c.SDL_Quit();
                },
                else => {},
            }
        }
    }

    pub fn onKeyPressed(keyName: [*c]const u8, comptime function: fn () void) void {
        const key = c.SDL_GetKeyName(event.key.keysym.sym);
        if (Input.isKeyPressed(keyName, key)) {
            function();
        }
    }

    fn isKeyPressed(pressedKeyName: [*c]const u8, keyName: [*c]const u8) bool {
        return std.mem.eql([*c]const u8, pressedKeyName, keyName);
    }
};
