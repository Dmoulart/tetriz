const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;

const Conf = @import("conf.zig");
const Cells = @import("game.zig").Cells;
const Cell = @import("cell.zig").Cell;

const Shape = @import("shape.zig").Shape;
const SquareShape = @import("shape.zig").SquareShape;

const CELL_BLOCK = @import("cell.zig").CELL_BLOCK;
const CELL_NONE = @import("cell.zig").CELL_NONE;
const CELL_WALL = @import("cell.zig").CELL_WALL;

pub const BlockType = enum(u8) { Square, Line };

// const BlockCells = union { Square: [4]Cell };

pub const Block = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    type: BlockType,

    // shape: *Shape,

    square_cells: [4]*Cell,

    line_cells: [5]*Cell,

    x: i32,
    y: i32,

    pub fn init(allocator: *std.mem.Allocator) !*Block {
        var block = try allocator.create(Block);
        block.allocator = allocator;
        block.x = 0;
        block.y = 0;
        block.type = BlockType.Square;
        try block.createCells();
        return block;
    }

    pub fn setPosition(self: *Self, x: i32, y: i32) void {
        self.x = x;
        self.y = y;

        self.syncCells();
    }

    pub fn render(self: *Self, renderer: *Renderer) void {
        if (self.type == BlockType.Square) {
            for (self.square_cells) |cell| {
                cell.render(renderer);
            }
        }
        if (self.type == BlockType.Line) {
            for (self.line_cells) |cell| {
                cell.render(renderer);
            }
        }
    }

    pub fn translate(self: *Self, x: i32, y: i32) void {
        self.x += x;
        self.y += y;

        self.syncCells();
    }

    pub fn willIntersects(self: *Self, flag: u8, x: i32, y: i32, cells: *Cells) bool {
        switch (self.type) {
            .Square => {
                for (self.square_cells) |cell| {
                    if (cell.willIntersects(flag, x, y, cells)) {
                        return true;
                    }
                }
                return false;
            },
            .Line => {
                for (self.line_cells) |cell| {
                    if (cell.willIntersects(flag, x, y, cells)) {
                        return true;
                    }
                }
                return false;
            },
        }
    }

    pub fn copyToCells(self: *Self, cells: *Cells) void {
        var shape_cells = switch (self.type) {
            .Square => &self.square_cells,
            .Line => &self.line_cells,
        };

        for (shape_cells) |cell| {
            var x_index = @intCast(usize, cell.x);
            var y_index = @intCast(usize, cell.y);
            cells[x_index][y_index].type = cell.type;
        }
    }

    pub fn changePlayerBlockType(self: *Self, block_type: BlockType) !void {
        self.type = block_type;
        self.syncCells();
    }
    fn createCells(self: *Self) !void {
        self.square_cells = [4]*Cell{
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
        };

        self.line_cells = [5]*Cell{
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
        };

        // self.square_cells = undefined;
        // self.line_cells = undefined;
        // switch (self.type) {
        //     .Square => {
        //         self.square_cells = [4]*Cell{
        //             try self.createCell(),
        //             try self.createCell(),
        //             try self.createCell(),
        //             try self.createCell(),
        //         };
        //     },
        //     .Line => {
        //         self.line_cells = [5]*Cell{
        //             try self.createCell(),
        //             try self.createCell(),
        //             try self.createCell(),
        //             try self.createCell(),
        //             try self.createCell(),
        //         };
        //     },
        // }
    }

    fn createCell(self: *Self) !*Cell {
        var cell = try self.allocator.create(Cell);
        cell.type = CELL_BLOCK;
        cell.allocator = self.allocator;
        return cell;
    }

    fn syncCells(self: *Self) void {
        switch (self.type) {
            .Square => {
                self.square_cells[0].x = self.x;
                self.square_cells[0].y = self.y;

                self.square_cells[1].x = self.x + 1;
                self.square_cells[1].y = self.y;

                self.square_cells[2].x = self.x + 1;
                self.square_cells[2].y = self.y + 1;

                self.square_cells[3].x = self.x;
                self.square_cells[3].y = self.y + 1;
            },
            .Line => {
                self.line_cells[0].x = self.x;
                self.line_cells[0].y = self.y;

                self.line_cells[1].x = self.x;
                self.line_cells[1].y = self.y + 1;

                self.line_cells[2].x = self.x;
                self.line_cells[2].y = self.y + 2;

                self.line_cells[3].x = self.x;
                self.line_cells[3].y = self.y + 3;

                self.line_cells[4].x = self.x;
                self.line_cells[4].y = self.y + 4;
            },
        }
    }
};
