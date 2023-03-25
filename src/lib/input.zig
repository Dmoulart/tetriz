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

    pub fn onKeyPressed(keyName: [*c]const u8, comptime function: anytype) void {
        const key = c.SDL_GetKeyName(event.key.keysym.sym);
        if (Input.isKeyPressed(keyName.*, key.*)) {
            function();
        }
    }

    fn isKeyPressed(pressedKeyName: []const u8, keyName: []const u8) bool {
        return std.mem.eql(u8, pressedKeyName, keyName);
    }
};
