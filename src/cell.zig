const std = @import("std");
const Renderer = @import("lib/renderer.zig").Renderer;
const Conf = @import("conf.zig");

pub const Vec = struct { x: u32 = 0, y: u32 = 0 };

pub const CellType = enum(u8) { None, Wall, Block };

pub const CELL_FLAG_NONE = 0;
pub const CELL_WALL = 1 << 0;
pub const CELL_FLAG_BLOCK = 1 << 1;

pub const Cell = struct {
    const Self = @This();

    allocator: *std.mem.Allocator,
    // position: Vec,
    x: u32,
    y: u32,

    type: CellType = CellType.Wall,

    flags: u32 = 0 & CELL_WALL,

    pub fn init(allocator: *std.mem.Allocator) !*Cell {
        const cell = try allocator.create(Cell);
        cell.allocator = allocator;
        return cell;
    }

    pub fn render(self: *Self, renderer: *Renderer) void {
        if (self.type == CellType.Wall or self.type == CellType.Block) {
            renderer.drawRect(self.x * Conf.CELL_SIZE, self.y * Conf.CELL_SIZE, Conf.CELL_SIZE, Conf.CELL_SIZE, 100, 100, 100, 255);
        }
    }
};
