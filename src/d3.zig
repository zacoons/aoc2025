const std = @import("std");

const alloc = std.heap.smp_allocator;

pub fn main() !void {
    var joltage: u32 = 0;

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

        var tens: u8 = 1;
        var tens_i: usize = 0;
        var ones: u8 = 1;
        var i: usize = 0;
        while (i < line.len - 1) : (i += 1) {
            const tens_candidate = try std.fmt.parseInt(u8, &.{line[i]}, 10);
            if (tens_candidate > tens) {
                tens = tens_candidate;
                tens_i = i;
            }
        }
        var j: usize = line.len - 1;
        while (j > tens_i) : (j -= 1) {
            ones = @max(ones, try std.fmt.parseInt(u8, &.{line[j]}, 10));
        }
        joltage += tens * 10 + ones;
    }

    var stdout_w_buf: [2]u8 = undefined;
    var stdout_w = std.fs.File.stdout().writer(&stdout_w_buf);
    try stdout_w.interface.print("{}\n", .{joltage});
    try stdout_w.interface.flush();
}
