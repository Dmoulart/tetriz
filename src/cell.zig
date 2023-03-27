const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;
const Conf = @import("conf.zig");

const Cells = @import("game.zig").Cells;

pub const CellFlag = enum(u32) { None = 0, Wall = 1 << 0, Block = 1 << 1 };

pub const CELL_NONE = 0;
pub const CELL_WALL = 1 << 0;
pub const CELL_BLOCK = 1 << 1;
pub const CELL_FLOOR = 1 << 2;

pub const Cell = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    x: i32,
    y: i32,

    type: u32 = CELL_WALL,

    pub fn init(allocator: *std.mem.Allocator) !*Cell {
        const cell = try allocator.create(Cell);
        cell.allocator = allocator;
        return cell;
    }

    pub fn render(self: *Self, renderer: *Renderer) void {
        if (self.is(CELL_WALL) or self.is(CELL_BLOCK) or self.is(CELL_FLOOR)) {
            renderer.drawRect(self.x * Conf.CELL_SIZE, self.y * Conf.CELL_SIZE, Conf.CELL_SIZE, Conf.CELL_SIZE, 100, 100, 100, 255);
        }
    }

    pub fn willIntersects(self: *Self, flag: u8, x: i32, y: i32, cells: *Cells) bool {
        var newX = @intCast(usize, self.x + x);
        var newY = @intCast(usize, self.y + y);

        if ((cells[newX][newY].type & flag) != 0) {
            return true;
        }

        return false;
    }

    pub fn is(self: *Self, flag: u8) bool {
        return (self.type & flag) == flag;
    }
};
