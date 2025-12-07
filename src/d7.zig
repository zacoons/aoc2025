const std = @import("std");

const alloc = std.heap.smp_allocator;

fn count(cache: *std.AutoHashMap(usize, u128), file: []u8, w: usize, start_x: usize, start_y: usize) !u128 {
    const cache_key = w * start_y + start_x;
    if (cache.get(cache_key)) |c| return c;
    var i = cache_key;
    while (i < file.len) : (i += w) {
        if (file[i] == '^') {
            var c: u128 = 1;
            c += try count(cache, file, w, start_x - 1, @divTrunc(i, w));
            c += try count(cache, file, w, start_x + 1, @divTrunc(i, w));
            try cache.put(cache_key, c);
            return c;
        }
    }
    return 0;
}

pub fn main() !void {
    var timer = try std.time.Timer.start();

    const file = try std.fs.cwd().readFileAlloc(alloc, "data/d7.txt", 1024 * 1024);
    const w = std.mem.indexOfScalar(u8, file, '\n').? + 1;

    var cache = std.AutoHashMap(usize, u128).init(alloc);
    const start_x = std.mem.indexOfScalar(u8, file, 'S').?;
    std.debug.print("{} {D}\n", .{ 1 + try count(&cache, file, w, start_x, 1), timer.read() });
}
