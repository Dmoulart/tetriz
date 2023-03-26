const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;
const Conf = @import("conf.zig");

pub const CellFlag = enum(u32) { None = 0, Wall = 1 << 0, Block = 1 << 1 };

pub const CELL_NONE = 0;
pub const CELL_WALL = 1 << 0;
pub const CELL_BLOCK = 1 << 1;

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
        if (self.type == CELL_WALL or self.type == CELL_BLOCK) {
            renderer.drawRect(self.x * Conf.CELL_SIZE, self.y * Conf.CELL_SIZE, Conf.CELL_SIZE, Conf.CELL_SIZE, 100, 100, 100, 255);
        }
    }
};
