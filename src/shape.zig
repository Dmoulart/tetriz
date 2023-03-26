const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;
const Conf = @import("conf.zig");
const Cells = @import("game.zig").Cells;
const Cell = @import("cell.zig").Cell;

const CELL_BLOCK = @import("cell.zig").CELL_BLOCK;
const CELL_NONE = @import("cell.zig").CELL_NONE;
const CELL_WALL = @import("cell.zig").CELL_WALL;

pub const Shape = union(enum) {
    square: SquareShape,

    pub fn createCells(self: Shape) void {
        switch (self) {
            inline else => |shape| shape.createCells(),
        }
    }

    pub fn syncCells(self: Shape) void {
        switch (self) {
            inline else => |shape| shape.syncCells(),
        }
    }
};

pub const SquareShape = struct {
    const Self = @This();
    cells: [4]*Cell,

    pub fn createCells(self: *Self) void {
        self.cells = [_]*Cell{
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
        };
    }

    pub fn syncCells(self: *Self, x: i32, y: i32) void {
        self.cells[0].x = x;
        self.cells[0].y = y;

        self.cells[1].x = x + 1;
        self.cells[1].y = y;

        self.cells[2].x = x + 1;
        self.cells[2].y = y + 1;

        self.cells[3].x = x;
        self.cells[3].y = y + 1;
    }
};
