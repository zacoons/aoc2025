const std = @import("std");

const alloc = std.heap.smp_allocator;

const Col = struct {
    start_x: usize,
    end_x: usize,
    op: u8,
};

pub fn main() !void {
    const file = try std.fs.cwd().readFileAlloc(alloc, "data/d6.txt", 1024 * 1024);
    const w = std.mem.indexOfScalar(u8, file, '\n').? + 1;
    const h = @divExact(file.len, w);

    var cols = try std.ArrayList(Col).initCapacity(alloc, 4);
    {
        const offset = (h - 1) * w; // This is the index at which the last row starts
        var start_i = offset;
        while (true) {
            const i = std.mem.indexOfAnyPos(u8, file, start_i + 1, &.{ '+', '*' }) orelse file.len - 1;
            try cols.append(alloc, .{
                .start_x = start_i - offset,
                .end_x = if (i == file.len - 1) i - offset else i - offset - 1,
                .op = file[start_i],
            });
            if (i == file.len - 1) break;
            start_i = i;
        }
    }

    var sum: u64 = 0;

    for (cols.items) |col| {
        const col_w = col.end_x - col.start_x;
        var local_sum: u64 = if (col.op == '*') 1 else 0;
        var i = col.start_x;
        while (i < file.len - w) : (i += w) {
            const num_str = std.mem.trim(u8, file[i .. i + col_w], &.{' '});
            const num = try std.fmt.parseInt(u64, num_str, 10);
            switch (col.op) {
                '+' => local_sum += num,
                '*' => local_sum *= num,
                else => return error.InvalidOperator,
            }
        }
        sum += local_sum;
    }

    std.debug.print("{}\n", .{sum});
}
