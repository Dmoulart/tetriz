const std = @import("std");
const fs = std.fs;
const File = std.fs.File;
const cwd = fs.cwd();

pub fn write(score: u32, alloc: *std.mem.Allocator) !void {
    // Open/create file
    var file: File = undefined;
    defer file.close();

    if (std.fs.cwd().openFile("score.txt", .{ .mode = .read_write })) |opened_file| {
        file = opened_file;
    } else |err| {
        std.debug.print("Creating file {}", .{err});
        file = try std.fs.cwd().createFile("score.txt", .{});
    }

    // Convert the score to a string
    var buffer: [100]u8 = undefined;
    const buf = buffer[0..];
    var score_str = std.fmt.bufPrintIntToSlice(buf, score, 10, .lower, std.fmt.FormatOptions{});
    var stat = try file.stat();
    try file.seekTo(stat.size);

    // Concatenate linefeed
    var lf = "\n";
    var line = try alloc.alloc(u8, score_str.len + lf.len);
    std.mem.copy(u8, line[0..], score_str);
    std.mem.copy(u8, line[score_str.len..], lf);

    try file.writer().writeAll(line); // this will happen at the end of the file
}
