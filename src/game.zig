const std = @import("std");
pub const c = @cImport({
    @cInclude("SDL.h");
    @cInclude("SDL_ttf.h");
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

const STARTING_TICK_RATE = 60;

pub const Game = struct {
    const Self = @This();

    var TICK_RATE: u32 = STARTING_TICK_RATE;

    loop_counter: u128 = 0,

    allocator: *std.mem.Allocator,
    cells: Cells,

    current_block: *Block,

    renderer: *Renderer,

    filled_lines: [Conf.MAX_HEIGHT]bool = undefined,

    score: u32 = 0,

    game_over: bool = false,

    pub fn init(allocator: *std.mem.Allocator) !*Game {
        var game = try allocator.create(Game);

        game.allocator = allocator;
        game.loop_counter = 0;
        game.score = 0;

        return game;
    }

    pub fn createPlayerBlock(self: *Self) !*Block {
        self.current_block = try Block.init(self.allocator);

        _ = self.placePlayerBlock();

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

        if (self.loop_counter % TICK_RATE == 0) {
            try self.tick();
        }

        _ = Input.listen();

        try self.processInput(Input.getPressedKey());

        try self.render();

        c.SDL_Delay(16);

        self.loop_counter += 1;

        if (self.loop_counter % 1000 == 1) {
            TICK_RATE -= 1;
        }
    }

    fn processInput(self: *Self, sym: c_int) !void {
        switch (sym) {
            c.SDLK_LEFT => {
                _ = try self.move(-1, 0);
            },
            c.SDLK_RIGHT => {
                _ = try self.move(1, 0);
            },
            c.SDLK_DOWN => {
                _ = try self.move(0, 1);
            },
            c.SDLK_a => {
                self.rotate();
            },
            c.SDLK_UP => {
                self.rotate();
            },
            c.SDLK_SPACE => {
                self.drop();
            },
            else => {},
        }
    }

    fn render(self: *Self) !void {
        for (self.cells) |col| {
            for (col) |colCell| {
                var cell = colCell;
                cell.render(self.renderer);
            }
        }

        self.current_block.render(self.renderer);

        try self.current_block.renderProjection(&self.cells, self.renderer);

        var textX = @intCast(c_int, self.wallsXEnd() + 20);
        var textY = @intCast(c_int, self.wallsYBegin() + 20);

        self.renderer.drawText(textX, textY, self.score);

        self.renderer.render();
    }

    fn tick(self: *Self) !void {
        _ = try self.move(0, 1);
    }

    fn canTranslateBy(self: *Self, x: i32, y: i32) bool {
        return !self.current_block.willIntersects(CELL_WALL | CELL_BLOCK, x, y, &self.cells);
    }

    fn willTouchFloor(self: *Self, x: i32, y: i32) bool {
        return self.current_block.willIntersects(CELL_FLOOR | CELL_BLOCK, x, y, &self.cells);
    }

    fn move(self: *Self, x: i32, y: i32) !bool {
        if (y == 1) {
            if (self.willTouchFloor(0, 1)) {
                try self.dropCurrentBlock();
                self.detectFilledLines();
                self.clearFilledLines();
                // If can't place player block let's set game over
                if (!self.placePlayerBlock()) {
                    self.game_over = true;
                }

                try self.current_block.changePlayerBlockType(BlockType.Line);

                return false;
            }
        }

        var translate = self.canTranslateBy(x, y);
        if (translate) {
            self.current_block.translate(x, y);
            return true;
        }
        return false;
    }

    fn dropCurrentBlock(self: *Self) !void {
        self.current_block.copyToCells(&self.cells);
    }

    fn placePlayerBlock(self: *Self) bool {
        const max_x = self.maxWidth();
        const max_y = self.maxHeight();

        const begin_y = @divTrunc(max_y, 4);
        const center_x = @divTrunc(max_x, 2);

        self.current_block.setPosition(center_x, begin_y);

        // Game over
        return !self.current_block.willIntersects(CELL_BLOCK, 0, 0, &self.cells);
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
                    self.cells[x_index][y_index] = Cell{ .allocator = self.allocator, .x = @as(i32, x), .y = @as(i32, y), .type = cell_type, .color = 0xffffffff };
                } else {
                    self.cells[x_index][y_index] = Cell{ .allocator = self.allocator, .x = @as(i32, x), .y = @as(i32, y), .type = CELL_NONE, .color = 0xffffffff };
                }
            }
        }
    }

    fn detectFilledLines(self: *Self) void {
        self.filled_lines = undefined;

        var y: i32 = self.wallsYEnd() - 1;

        yloop: while (y > self.wallsYBegin()) : (y -= 1) {
            var x: i32 = self.wallsXBegin() + 1;
            var x_index = @intCast(usize, x);
            var y_index = @intCast(usize, y);

            while (x <= self.wallsXEnd()) : (x += 1) {
                x_index = @intCast(usize, x);

                if (self.cells[x_index][y_index].type & CELL_BLOCK != CELL_BLOCK) {
                    self.filled_lines[y_index] = false;
                    continue :yloop;
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

            self.lowerAllBocksCells(y_index);

            self.score += 1;
        }
    }

    fn lowerAllBocksCells(self: *Self, from: usize) void {
        var y = from;

        while (y > self.wallsYBegin()) : (y -= 1) {
            var x: i32 = self.wallsXBegin() + 1;
            var x_index = @intCast(usize, x);
            var y_index = @intCast(usize, y);

            while (x <= self.wallsXEnd()) : (x += 1) {
                x_index = @intCast(usize, x);

                if (self.cells[x_index][y_index].type & CELL_BLOCK == CELL_BLOCK) {
                    var color = self.cells[x_index][y_index].color;
                    self.cells[x_index][y_index].type = CELL_NONE;
                    if (y_index + 1 <= self.cells[x_index].len) {
                        self.cells[x_index][y_index + 1].type = CELL_BLOCK;
                        self.cells[x_index][y_index + 1].color = color;
                    }
                }
            }
        }
    }

    fn rotate(self: *Self) void {
        self.current_block.rotate();

        var intersects = self.current_block.willIntersects(CELL_WALL | CELL_BLOCK, 0, 0, &self.cells);
        if (intersects) {
            while (self.current_block.willIntersects(CELL_WALL | CELL_BLOCK, 0, 0, &self.cells)) {
                self.current_block.rotate();
            }
        }
    }

    fn drop(self: *Self) void {
        while (try self.move(0, 1)) {}
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
