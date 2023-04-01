const std = @import("std");

pub const CELL_SIZE = 30; // 5 lol

pub const SCREEN_WIDTH = 800;
pub const SCREEN_HEIGHT = 1000;

pub const MAX_HEIGHT = @divTrunc(SCREEN_HEIGHT, CELL_SIZE);
pub const MAX_WIDTH = @divTrunc(SCREEN_WIDTH, CELL_SIZE);
