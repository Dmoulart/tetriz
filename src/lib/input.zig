const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const Input = struct {
    var event: c.SDL_Event = undefined;

    pub fn listen() *c.SDL_Event {
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_KEYDOWN => {
                    return &event;
                },
                c.SDL_QUIT => {
                    c.SDL_Quit();
                },
                else => {},
            }
        }
        return &event;
    }

    pub fn keyPressed(keycode: c_int) bool {
        var sym = &event.key.keysym.sym;
        return sym.* == keycode;
    }

    pub fn getPressedKey() i32 {
        return event.key.keysym.sym;
    }
};
