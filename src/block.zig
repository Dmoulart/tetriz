const std = @import("std");
var Random = std.rand.DefaultPrng.init(2);
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
const CELL_FLOOR = @import("cell.zig").CELL_FLOOR;

const COLORS = [_]u32{ 0x227C9DFF, 0x17C3B2FF, 0xFFCB77FF, 0xFE6D73FF };

pub const BlockType = enum(u8) { Square, Line, L, T, S };

var SQUARE_CELLS_POS = [_][2]f16{ [_]f16{ 0, 0 }, [_]f16{ 1, 0 }, [_]f16{ 1, 1 }, [_]f16{ 0, 1 } };

var LINE_CELLS_POS = [_][2]f16{ [_]f16{ 0, -2 }, [_]f16{ 0, -1 }, [_]f16{ 0, 0 }, [_]f16{ 0, 1 }, [_]f16{ 0, 2 } };

var L_CELLS_POS = [_][2]f16{ [_]f16{ 0, -1 }, [_]f16{ 0, 0 }, [_]f16{ 0, 1 }, [_]f16{ 1, 1 } };

var T_CELLS_POS = [_][2]f16{ [_]f16{ -1, 0 }, [_]f16{ 0, 0 }, [_]f16{ 0, 1 }, [_]f16{ 1, 0 } };

var S_CELLS_POS = [_][2]f16{ [_]f16{ -1, -1 }, [_]f16{ -1, 0 }, [_]f16{ 0, 0 }, [_]f16{ 0, 1 } };

pub const Block = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    type: BlockType,

    square_cells: [4]*Cell,
    line_cells: [5]*Cell,
    l_cells: [4]*Cell,
    t_cells: [4]*Cell,
    s_cells: [4]*Cell,

    R: std.rand.Xoshiro256 = undefined,

    x: i32,
    y: i32,

    angle: f16 = 0,

    pub fn init(allocator: *std.mem.Allocator) !*Block {
        var block = try allocator.create(Block);
        block.allocator = allocator;
        block.x = 0;
        block.y = 0;
        block.angle = 0;
        block.initRandom();
        block.type = block.pickType();
        try block.createCells();
        block.pickColor();
        return block;
    }

    pub fn deinit(allocator: *std.mem.Allocator, block: *Block) void {
        allocator.destroy(block);
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

    pub fn renderProjection(self: *Self, cells: *Cells, renderer: *Renderer) !void {
        var start_y = self.y;

        while (!self.willIntersects(CELL_BLOCK | CELL_WALL | CELL_FLOOR, 0, 1, cells)) {
            self.y += 1;
            self.syncCells();
        }

        for (self.getShapeCells()) |cell| {
            var projected = try Cell.init(self.allocator);
            projected.color = 0xFAFAFA44;
            projected.type = cell.type;
            projected.x = cell.x;
            projected.y = cell.y;

            projected.render(renderer);
            Cell.deinit(self.allocator, projected);
        }

        self.y = start_y;
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
            cells[x_index][y_index].color = cell.color;
        }
    }

    pub fn rotate(self: *Self) void {
        self.angle = if (self.angle + 90 >= 360) 0 else self.angle + 90;
        self.syncCells();
    }

    pub fn changePlayerBlockType(self: *Self, _: BlockType) !void {
        self.type = self.pickType();
        self.syncCells();
        self.pickColor();
    }

    pub fn pickColor(self: *Self) void {
        var cells = self.getShapeCells();
        var i = self.getRandom().random().intRangeAtMost(usize, 0, COLORS.len - 1);
        var color = COLORS[i];

        for (cells) |cell| {
            cell.color = color;
        }
    }

    pub fn pickType(self: *Self) BlockType {
        var blocks_len = @intCast(u8, @typeInfo(BlockType).Enum.fields.len);
        var random_block_type = self.getRandom().random().intRangeAtMost(u8, 0, blocks_len - 1);

        var block_type = switch (random_block_type) {
            0 => BlockType.Square,
            1 => BlockType.Line,
            2 => BlockType.L,
            3 => BlockType.T,
            4 => BlockType.S,
            else => unreachable,
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

        self.s_cells = [4]*Cell{
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
            try self.createCell(),
        };
    }

    fn getShapeCells(self: *Self) []*Cell {
        return switch (self.type) {
            .Square => &self.square_cells,
            .Line => &self.line_cells,
            .L => &self.l_cells,
            .T => &self.t_cells,
            .S => &self.s_cells,
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
            .S => S_CELLS_POS[0..S_CELLS_POS.len],
        };
    }

    fn syncCells(self: *Self) void {
        var positions = self.getBlockTypeCellsPositions();
        var cells = self.getShapeCells();

        if (self.type == BlockType.Square) {
            for (positions) |vec, i| {
                var x = vec[0];
                var y = vec[1];

                cells[i].x = self.x + @floatToInt(i32, x);
                cells[i].y = self.y + @floatToInt(i32, y);
            }
            return;
        }

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

    fn initRandom(self: *Self) void {
        self.R = std.rand.DefaultPrng.init(@intCast(u64, std.time.timestamp()));
    }

    fn getRandom(self: *Self) *std.rand.Xoshiro256 {
        return &self.R;
    }
};
