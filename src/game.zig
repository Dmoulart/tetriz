const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

const Renderer = @import("lib/renderer.zig").Renderer;
const Input = @import("lib/input.zig").Input;

const Cell = @import("cell.zig").Cell;
const BlockType = @import("block.zig").BlockType;

const CELL_BLOCK = @import("cell.zig").CELL_BLOCK;
const CELL_NONE = @import("cell.zig").CELL_NONE;
const CELL_WALL = @import("cell.zig").CELL_WALL;
const CELL_FLOOR = @import("cell.zig").CELL_FLOOR;

const Block = @import("block.zig").Block;

const Conf = @import("conf.zig");

pub const Cells = [Conf.MAX_WIDTH][Conf.MAX_HEIGHT]Cell;

pub const Game = struct {
    const Self = @This();

    const TICK_RATE = 30;

    loop_counter: u8 = 0,

    allocator: *std.mem.Allocator,
    cells: Cells,

    current_block: *Block,

    renderer: *Renderer,

    filled_lines: [Conf.MAX_HEIGHT]bool = undefined,

    pub fn init(allocator: *std.mem.Allocator) !*Game {
        var game = try allocator.create(Game);
        game.allocator = allocator;
        game.loop_counter = 0;
        return game;
    }

    pub fn createPlayerBlock(self: *Self) !*Block {
        self.current_block = try Block.init(self.allocator);

        self.placePlayerBlock();

        return self.current_block;
    }

    pub fn setRenderer(self: *Self, renderer: *Renderer) void {
        self.renderer = renderer;
    }

    pub fn setup(self: *Self) void {
        self.addWalls();
    }

    pub fn update(self: *Self) !void {
        self.renderer.clear();

        if (self.loop_counter == TICK_RATE) {
            try self.tick();
            self.loop_counter = 0;
        }

        _ = Input.listen();

        try self.processInput(Input.getPressedKey());

        self.render();

        self.renderer.render();

        c.SDL_Delay(16);

        self.loop_counter += 1;
    }

    fn processInput(self: *Self, sym: c_int) !void {
        switch (sym) {
            c.SDLK_LEFT => {
                try self.move(-1, 0);
            },
            c.SDLK_RIGHT => {
                try self.move(1, 0);
            },
            c.SDLK_DOWN => {
                try self.move(0, 1);
            },
            else => {},
        }
    }

    fn render(self: *Self) void {
        for (self.cells) |col| {
            for (col) |colCell| {
                var cell = colCell;
                cell.render(self.renderer);
            }
        }

        self.current_block.render(self.renderer);
    }

    fn tick(self: *Self) !void {
        try self.move(0, 1);
    }

    fn canTranslateBy(self: *Self, x: i32, y: i32) bool {
        return !self.current_block.willIntersects(CELL_WALL | CELL_BLOCK, x, y, &self.cells);
    }

    fn willTouchFloor(self: *Self, x: i32, y: i32) bool {
        return self.current_block.willIntersects(CELL_FLOOR | CELL_BLOCK, x, y, &self.cells);
    }

    fn move(self: *Self, x: i32, y: i32) !void {
        if (self.willTouchFloor(0, 1)) {
            try self.dropCurrentBlock();
            self.detectFilledLines();
            self.clearFilledLines();
            self.placePlayerBlock();
            try self.current_block.changePlayerBlockType(BlockType.Line);

            return;
        }

        var translate = self.canTranslateBy(x, y);
        if (translate) {
            self.current_block.translate(x, y);
        }
    }

    fn dropCurrentBlock(self: *Self) !void {
        self.current_block.copyToCells(&self.cells);
    }

    fn placePlayerBlock(self: *Self) void {
        const max_x = self.maxWidth();
        const max_y = self.maxHeight();

        const begin_y = @divTrunc(max_y, 4);
        const center_x = @divTrunc(max_x, 2);

        self.current_block.setPosition(center_x, begin_y);
    }

    fn addWalls(self: *Self) void {
        var x: i32 = 0;
        var y: i32 = 0;

        const max_x = self.maxWidth();
        const max_y = self.maxHeight();

        const begin_x = self.wallsXBegin();
        const end_x = self.wallsXEnd() + 1;

        const begin_y = self.wallsYBegin();
        const end_y = self.wallsYEnd();

        while (x <= max_x) : (x += 1) {
            y = 0;

            while (y <= max_y) : (y += 1) {
                const isLeftWall = x == begin_x and y <= end_y and y >= begin_y;

                const isRightWall = x == end_x and y <= end_y and y >= begin_y;

                const isBottomWall = y == end_y and x >= begin_x and x <= end_x;

                var x_index = @intCast(usize, x);
                var y_index = @intCast(usize, y);

                if (isLeftWall or isRightWall or isBottomWall) {
                    var cell_type: u8 = if (isBottomWall) CELL_FLOOR else CELL_WALL;
                    self.cells[x_index][y_index] = Cell{ .allocator = self.allocator, .x = @as(i32, x), .y = @as(i32, y), .type = cell_type };
                } else {
                    self.cells[x_index][y_index] = Cell{ .allocator = self.allocator, .x = @as(i32, x), .y = @as(i32, y), .type = CELL_NONE };
                }
            }
        }
    }

    fn detectFilledLines(self: *Self) void {
        self.filled_lines = undefined;

        var y: i32 = self.wallsYEnd() - 1;

        while (y > self.wallsYBegin()) : (y -= 1) {
            var x: i32 = self.wallsXBegin() + 1;
            var x_index = @intCast(usize, x);
            var y_index = @intCast(usize, y);

            while (x <= self.wallsXEnd()) : (x += 1) {
                x_index = @intCast(usize, x);

                if (self.cells[x_index][y_index].type & CELL_BLOCK != CELL_BLOCK) {
                    self.filled_lines[y_index] = false;
                    return;
                }
            }

            self.filled_lines[y_index] = true;
        }
    }

    fn clearFilledLines(self: *Self) void {
        for (self.filled_lines) |filled, y| {
            if (!filled) continue;

            var x = self.wallsXBegin() + 1;
            var y_index = @intCast(usize, y);

            while (x <= self.wallsXEnd()) : (x += 1) {
                var x_index = @intCast(usize, x);
                self.cells[x_index][y_index].type = CELL_NONE;
            }
        }
    }

    fn wallsXBegin(self: *Self) i32 {
        const max_x = self.maxWidth();
        return @divTrunc(max_x, 4);
    }

    fn wallsXEnd(self: *Self) i32 {
        const begin_x = self.wallsXBegin();
        return begin_x * 3;
    }

    fn wallsYBegin(self: *Self) i32 {
        const max_y = self.maxHeight();
        return @divTrunc(max_y, 4);
    }

    fn wallsYEnd(self: *Self) i32 {
        const begin_y = self.wallsYBegin();
        return begin_y * 3;
    }

    fn maxWidth(self: *Self) i32 {
        return self.cells.len - 1;
    }

    fn maxHeight(self: *Self) i32 {
        return self.cells[0].len - 1;
    }
};
