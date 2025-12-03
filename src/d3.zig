const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var joltage: u128 = 0;

    const file = try std.fs.cwd().openFile("data/d3.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    var linebuf: [128]u8 = undefined;

    while (true) {
        var linebuf_w = std.Io.Writer.fixed(&linebuf);
        const n = try reader.interface.streamDelimiterEnding(&linebuf_w, '\n');
        if (n == 0) break;
        reader.interface.toss(1); // Skip over the delimiter itself
        const line = linebuf[0..n];

        var places: [12]u128 = .{1} ** 12;

        var start_i: usize = 0;
        var i: usize = 0;
        for (0..12) |places_i| {
            i = start_i;
            while (i < line.len - (11 - places_i)) : (i += 1) {
                const candidate = try std.fmt.parseInt(u128, &.{line[i]}, 10);
                if (candidate > places[places_i]) {
                    places[places_i] = candidate;
                    start_i = i + 1;
                }
            }
        }

        joltage +=
            places[0] * 100000000000 +
            places[1] * 10000000000 +
            places[2] * 1000000000 +
            places[3] * 100000000 +
            places[4] * 10000000 +
            places[5] * 1000000 +
            places[6] * 100000 +
            places[7] * 10000 +
            places[8] * 1000 +
            places[9] * 100 +
            places[10] * 10 +
            places[11] * 1;
    }

    var stdout_w_buf: [2]u8 = undefined;
    var stdout_w = std.fs.File.stdout().writer(&stdout_w_buf);
    try stdout_w.interface.print("{}\n", .{joltage});
    try stdout_w.interface.flush();
}
