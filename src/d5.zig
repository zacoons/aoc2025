const std = @import("std");

const alloc = std.heap.smp_allocator;

const Range = struct {
    min: u64,
    max: u64,

    pub fn contains(r: Range, v: u64) bool {
        return v > r.min and v <= r.max;
    }
};

pub fn main() !void {
    var count: u64 = 0;

    const file = try std.fs.cwd().openFile("data/d5.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);

    var linebuf: [128]u8 = undefined;

    var fresh = try std.ArrayList(Range).initCapacity(alloc, 1024);

    while (true) {
        var linebuf_w = std.Io.Writer.fixed(&linebuf);
        const n = try reader.interface.streamDelimiterEnding(&linebuf_w, '\n');
        reader.interface.toss(1); // Skip over the delimiter itself
        if (n == 0) break;
        const line = linebuf[0..n];

        const separator_i = std.mem.indexOfScalar(u8, line, '-').?;
        const left = try std.fmt.parseInt(u64, line[0..separator_i], 10);
        const right = try std.fmt.parseInt(u64, line[separator_i + 1 ..], 10);
        try fresh.append(alloc, Range{ .min = left, .max = right });
    }

    std.debug.print("got fresh\n", .{});

    while (true) {
        var linebuf_w = std.Io.Writer.fixed(&linebuf);
        const n = try reader.interface.streamDelimiterEnding(&linebuf_w, '\n');
        if (n == 0) break;
        reader.interface.toss(1); // Skip over the delimiter itself
        const line = linebuf[0..n];

        const id = try std.fmt.parseInt(u64, line, 10);
        for (fresh.items) |range| {
            if (range.contains(id)) {
                count += 1;
                break;
            }
        }
    }

    std.debug.print("{}\n", .{count});
}
