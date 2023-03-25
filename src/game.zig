const std = @import("std");
const Cell = @import("cell.zig").Cell;
const Vec = @import("cell.zig").Vec;
const Renderer = @import("lib/renderer.zig").Renderer;

const Conf = @import("conf.zig");

pub const Game = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    cells: [Conf.MAX_WIDTH][Conf.MAX_HEIGHT]Cell,

    pub fn init(allocator: *std.mem.Allocator) !*Game {
        var cells = try allocator.create(Game);
        return cells;
    }

    pub fn addWalls(self: *Self) void {
        var x: u32 = 0;
        var y: u32 = 0;

        const max_x = self.cells.len;
        const max_y = self.cells[0].len;

        const begin_x = @divTrunc(max_x, 4);
        const end_x = @divTrunc(max_x, 4) * 3;

        const begin_y = @divTrunc(max_y, 4);
        const end_y = @divTrunc(max_y, 4) * 3;

        while (x < max_x) : (x += 1) {
            y = 0;

            while (y < max_y) : (y += 1) {
                const isLeftWall = x == begin_x and y <= end_y and y >= begin_y;

                const isRightWall = x == end_x and y <= end_y and y >= begin_y;

                const isBottomWall = y == end_y and x >= begin_x and x <= end_x;

                if (isLeftWall or isRightWall or isBottomWall) {
                    self.cells[x][y] = Cell{ .allocator = self.allocator, .x = x, .y = y };
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
};
