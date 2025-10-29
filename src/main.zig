const std = @import("std");

pub fn main() !void {
    var args = std.process.args();
    _ = args.next();
    var buffer: [std.fs.max_path_bytes]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&buffer);
    const stdout = &stdout_writer.interface;

    if (args.next() == null) {
        try stdout.print("Usage: kat <file> [...]\n", .{});
        try stdout.flush();
        return;
    }

    args = std.process.args();
    _ = args.next();
    var fs_buffer: [std.fs.max_path_bytes]u8 = undefined;

    while (args.next()) |path| {
        const realpath = std.fs.realpath(path, &fs_buffer) catch |err| {
            std.log.err("cannot open file '{s}': {s}", .{ path, @errorName(err) });
            continue;
        };
        const file = try std.fs.openFileAbsolute(realpath, .{});
        defer file.close();

        var file_reader = file.reader(&buffer);
        const reader = &file_reader.interface;

        _ = try reader.streamRemaining(&stdout_writer.interface);
    }
    try stdout_writer.interface.flush();
}
