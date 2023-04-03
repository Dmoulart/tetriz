const std = @import("std");
const fs = std.fs;
const File = std.fs.File;
const cwd = fs.cwd();

pub fn write(score: u32) !void {
    _ = score;
    var file = std.fs.cwd().openFile("score.txt", .{}) catch |err| switch (err) {
        // err.OpenError => {
        //     _ = try std.fs.cwd().createFile("score.txt", .{});
        //     return try std.fs.cwd().openFile("score.txt", .{});
        // },
        else => {
            _ = try std.fs.cwd().createFile("score.txt", .{});
            return std.fs.cwd().openFile("score.txt", .{});
        },
    };
    _ = file;

    // catch {
    //     _ = try std.fs.cwd().createFile("score.txt", .{});
    //     return try std.fs.cwd().openFile("score.txt", .{});
    // };
    // defer file.close();

    // var stat = try file.stat();
    // try file.seekTo(stat.size);

    // var buffer: [100]u8 = undefined;
    // const buf = buffer[0..];
    // var score_str = std.fmt.bufPrintIntToSlice(buf, score, 10, .lower, std.fmt.FormatOptions{});

    // try file.writer().writeAll(score_str);

    // var buf_reader = std.io.bufferedReader(file.reader());
    // var in_stream = buf_reader.reader();

    // var buf: [1024]u8 = undefined;
    // while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) {
    //     // do something with line...
    // }

    // var stat: fs.Dir.Stat = cwd().stat();
    // _ = stat;
    // stat.kind

    // const file = try std.fs.cwd().createFile("score.txt", .{ .read = true });
    // defer file.close();
    // std.debug.print("file created", .{});
    // var buffer: [100]u8 = undefined;
    // const buf = buffer[0..];
    // var score_str = std.fmt.bufPrintIntToSlice(buf, score, 10, .lower, std.fmt.FormatOptions{});
    // const bytes_written = try file.writeAll(score_str);
    // _ = bytes_written;
}
