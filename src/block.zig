const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;

const Conf = @import("conf.zig");
const Cells = @import("game.zig").Cells;
const Cell = @import("cell.zig").Cell;

const Shape = @import("shape.zig").Shape;

const CELL_BLOCK = @import("cell.zig").CELL_BLOCK;
const CELL_NONE = @import("cell.zig").CELL_NONE;
const CELL_WALL = @import("cell.zig").CELL_WALL;

pub const BlockType = enum(u8) { Square };

const BlockCells = union { Square: [4]Cell };

pub const Block = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    type: BlockType,

    shape: Shape,

    cells: [4]*Cell,

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
            for (self.cells) |cell| {
                cell.render(renderer);
            }
        }
    }

    pub fn translate(self: *Self, x: i32, y: i32) void {
        self.x += x;
        self.y += y;

        self.syncCells();
    }

    pub fn intersects(self: *Self, x: i32, y: i32, cells: *Cells) void {
        var newX = self.x + x;
        var newY = self.y + y;

        if ((cells[newX][newY].type & CELL_BLOCK) == CELL_BLOCK) {
            return false;
        }
    }

    fn createCells(self: *Self) !void {
        self.cells = undefined;
        // self.shape.createCells()
        switch (self.type) {
            .Square => {
                self.cells = [_]*Cell{
                    try self.createCell(),
                    try self.createCell(),
                    try self.createCell(),
                    try self.createCell(),
                };
            },
        }
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
                self.cells[0].x = self.x;
                self.cells[0].y = self.y;

                self.cells[1].x = self.x + 1;
                self.cells[1].y = self.y;

                self.cells[2].x = self.x + 1;
                self.cells[2].y = self.y + 1;

                self.cells[3].x = self.x;
                self.cells[3].y = self.y + 1;
            },
        }
    }

    // pub fn update(self: *Self, cells: *Cells) void {
    //     var x = self.x;
    //     var y = self.y;

    //     cells[x][y].type = CellType.Block;

    //     switch (self.type) {
    //         .Square => {
    //             cells[x + 1][y].type = CellType.Block;
    //             cells[x + 1][y + 1].type = CellType.Block;
    //             cells[x][y + 1].type = CellType.Block;
    //         },
    //     }
    // }
};
