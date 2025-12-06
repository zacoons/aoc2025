const std = @import("std");

const alloc = std.heap.smp_allocator;

const Col = struct {
    start_x: usize,
    end_x: usize,
    op: u8,
};

pub fn main() !void {
    var timer = try std.time.Timer.start();

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

    var num_str = try std.ArrayList(u8).initCapacity(alloc, h - 1);
    defer num_str.deinit(alloc);
    for (cols.items) |col| {
        var local_sum: u64 = if (col.op == '*') 1 else 0;
        for (col.start_x..col.end_x) |x| { // Iter x values within col
            num_str.clearRetainingCapacity();
            var i = x;
            while (i < file.len - w) : (i += w) { // Iter y values within col
                try num_str.append(alloc, file[i]);
            }
            const num_str_trimmed = std.mem.trim(u8, num_str.items, &.{' '});
            const num = try std.fmt.parseInt(u64, num_str_trimmed, 10);
            switch (col.op) {
                '+' => local_sum += num,
                '*' => local_sum *= num,
                else => return error.InvalidOperator,
            }
        }
        sum += local_sum;
    }

    std.debug.print("{} {D}\n", .{ sum, timer.read() });
}
