const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;
const Conf = @import("conf.zig");
const Cells = @import("game.zig").Cells;
const Cell = @import("cell.zig").Cell;
const CellType = @import("cell.zig").CellType;

pub const BlockType = enum(u8) { Square };

pub const Block = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    type: BlockType,

    x: u32,
    y: u32,

    pub fn init(allocator: *std.mem.Allocator) !*Block {
        var block = try allocator.create(Block);
        block.allocator = allocator;
        block.x = 0;
        block.y = 0;
        block.type = BlockType.Square;
        return block;
    }

    pub fn setPosition(self: *Self, x: u32, y: u32) void {
        self.x = x;
        self.y = y;
    }

    pub fn update(self: *Self, cells: *Cells) void {
        var x = self.x;
        var y = self.y;

        cells[x][y].type = CellType.Block;

        switch (self.type) {
            .Square => {
                cells[x + 1][y].type = CellType.Block;
                cells[x + 1][y + 1].type = CellType.Block;
                cells[x][y + 1].type = CellType.Block;
            },
        }
    }
};
