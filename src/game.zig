const std = @import("std");
const Cell = @import("cell.zig").Cell;
const CellType = @import("cell.zig").CellType;
const Vec = @import("cell.zig").Vec;
const Block = @import("block.zig").Block;
const Renderer = @import("lib/renderer.zig").Renderer;

const Conf = @import("conf.zig");

pub const Cells = [Conf.MAX_WIDTH][Conf.MAX_HEIGHT]Cell;

pub const Game = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    cells: Cells,

    current_block: *Block,

    pub fn init(allocator: *std.mem.Allocator) !*Game {
        var game = try allocator.create(Game);
        game.allocator = allocator;
        return game;
    }

    pub fn createBlock(self: *Self) !*Block {
        self.current_block = try Block.init(self.allocator);

        const max_x = self.maxWidth();
        const max_y = self.maxHeight();

        const begin_y = @divTrunc(max_y, 4);
        const center_x = @divTrunc(max_x, 2);

        self.current_block.setPosition(center_x, begin_y);

        return self.current_block;
    }

    pub fn setup(self: *Self) void {
        var x: u32 = 0;
        var y: u32 = 0;

        const max_x = self.maxWidth();
        const max_y = self.maxHeight();

        const begin_x = @divTrunc(max_x, 4);
        const end_x = begin_x * 3;

        const begin_y = @divTrunc(max_y, 4);
        const end_y = begin_y * 3;

        while (x <= max_x) : (x += 1) {
            y = 0;

            while (y <= max_y) : (y += 1) {
                const isLeftWall = x == begin_x and y <= end_y and y >= begin_y;

                const isRightWall = x == end_x and y <= end_y and y >= begin_y;

                const isBottomWall = y == end_y and x >= begin_x and x <= end_x;

                if (isLeftWall or isRightWall or isBottomWall) {
                    self.cells[x][y] = Cell{ .allocator = self.allocator, .x = x, .y = y, .type = CellType.Wall };
                } else {
                    self.cells[x][y] = Cell{ .allocator = self.allocator, .x = x, .y = y, .type = CellType.None };
                }
            }
        }
    }

    pub fn render(self: *Self, renderer: *Renderer) void {
        for (self.cells) |col| {
            for (col) |colCell| {
                var cell = colCell;
                cell.render(renderer);
            }
        }
    }

    fn maxWidth(self: *Self) u32 {
        return self.cells.len - 1;
    }

    fn maxHeight(self: *Self) u32 {
        return self.cells[0].len - 1;
    }
};
