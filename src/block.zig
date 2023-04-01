const std = @import("std");
var R = std.rand.DefaultPrng.init(2);
const math = std.math;

const Renderer = @import("lib/renderer.zig").Renderer;

const Conf = @import("conf.zig");
const Cells = @import("game.zig").Cells;
const Cell = @import("cell.zig").Cell;

const Shape = @import("shape.zig").Shape;
const SquareShape = @import("shape.zig").SquareShape;

const CELL_BLOCK = @import("cell.zig").CELL_BLOCK;
const CELL_NONE = @import("cell.zig").CELL_NONE;
const CELL_WALL = @import("cell.zig").CELL_WALL;

pub const BlockType = enum(u8) { Square, Line, L, T };

var SQUARE_CELLS_POS = [_][2]f16{ [_]f16{ 0, 0 }, [_]f16{ 1, 0 }, [_]f16{ 1, 1 }, [_]f16{ 0, 1 } };
var LINE_CELLS_POS = [_][2]f16{ [_]f16{ 0, 0 }, [_]f16{ 0, 1 }, [_]f16{ 0, 2 }, [_]f16{ 0, 3 }, [_]f16{ 0, 4 } };
var L_CELLS_POS = [_][2]f16{ [_]f16{ 0, 0 }, [_]f16{ 0, 1 }, [_]f16{ 0, 2 }, [_]f16{ 1, 2 } };
var T_CELLS_POS = [_][2]f16{ [_]f16{ 0, 0 }, [_]f16{ 1, 0 }, [_]f16{ 1, 1 }, [_]f16{ 2, 0 } };

pub const Block = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    type: BlockType,

    square_cells: [4]*Cell,
    line_cells: [5]*Cell,
    l_cells: [4]*Cell,
    t_cells: [4]*Cell,

    x: i32,
    y: i32,

    angle: f16 = 0,

    pub fn init(allocator: *std.mem.Allocator) !*Block {
        var block = try allocator.create(Block);
        block.allocator = allocator;
        block.x = 0;
        block.y = 0;
        block.type = block.pickType();
        block.angle = 0;
        try block.createCells();
        return block;
    }

    pub fn setPosition(self: *Self, x: i32, y: i32) void {
        self.x = x;
        self.y = y;

        self.syncCells();
    }

    pub fn render(self: *Self, renderer: *Renderer) void {
        for (self.getShapeCells()) |cell| {
            cell.render(renderer);
        }
    }

    pub fn translate(self: *Self, x: i32, y: i32) void {
        self.x += x;
        self.y += y;

        self.syncCells();
    }

    pub fn willIntersects(self: *Self, flag: u8, x: i32, y: i32, cells: *Cells) bool {
        for (self.getShapeCells()) |cell| {
            if (cell.willIntersects(flag, x, y, cells)) {
                return true;
            }
        }
        return false;
    }

    pub fn copyToCells(self: *Self, cells: *Cells) void {
        for (self.getShapeCells()) |cell| {
            var x_index = @intCast(usize, cell.x);
            var y_index = @intCast(usize, cell.y);
            cells[x_index][y_index].type = cell.type;
        }
    }

    pub fn rotate(self: *Self) void {
        self.angle = if (self.angle + 90 >= 360) 0 else self.angle + 90;
        self.syncCells();
    }

    fn getShapeCells(self: *Self) []*Cell {
        return switch (self.type) {
            .Square => &self.square_cells,
            .Line => &self.line_cells,
            .L => &self.l_cells,
            .T => &self.t_cells,
        };
    }

    pub fn changePlayerBlockType(self: *Self, _: BlockType) !void {
        self.type = self.pickType();
        self.syncCells();
    }

    pub fn pickType(self: *Self) BlockType {
        _ = self;
        var blocks_len = @intCast(u8, @typeInfo(BlockType).Enum.fields.len);
        var random_block_type = R.random().intRangeAtMost(u8, 0, blocks_len);

        var block_type = switch (random_block_type) {
            0 => BlockType.Square,
            1 => BlockType.Line,
            2 => BlockType.L,
            3 => BlockType.T,
            else => BlockType.Square,
        };

        return block_type;
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

        self.l_cells = [4]*Cell{
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
        };

        self.t_cells = [4]*Cell{
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
        };
    }

    fn createCell(self: *Self) !*Cell {
        var cell = try self.allocator.create(Cell);
        cell.type = CELL_BLOCK;
        cell.allocator = self.allocator;
        return cell;
    }

    fn getBlockTypeCellsPositions(self: *Self) [][2]f16 {
        return switch (self.type) {
            .Square => SQUARE_CELLS_POS[0..SQUARE_CELLS_POS.len],
            .Line => LINE_CELLS_POS[0..LINE_CELLS_POS.len],
            .L => L_CELLS_POS[0..L_CELLS_POS.len],
            .T => T_CELLS_POS[0..T_CELLS_POS.len],
        };
    }

    fn syncCells(self: *Self) void {
        var positions = self.getBlockTypeCellsPositions();
        var cells = self.getShapeCells();

        var radians = self.angle * math.pi / 180;
        var cos = @cos(radians);
        var sin = @sin(radians);

        for (positions) |vec, i| {
            var cell_x = vec[0];
            var cell_y = vec[1];

            var x = (cos * cell_x) - (sin * cell_y);
            var y = (sin * cell_x) + (cos * cell_y);

            x = @round(x);
            y = @round(y);

            cells[i].x = self.x + @floatToInt(i32, x);
            cells[i].y = self.y + @floatToInt(i32, y);
        }
    }
};
