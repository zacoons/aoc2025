const std = @import("std");

const alloc = std.heap.smp_allocator;

const Grid = struct {
    data: []u8,
    w: i32,
    h: i32,

    pub fn i(grid: Grid, x: i32, y: i32) usize {
        return @intCast(y * (grid.w + 1) + x);
    }

    pub fn isRollAt(grid: Grid, x: i32, y: i32) bool {
        if (x < 0 or y < 0 or x >= grid.w or y >= grid.h) return false;
        return grid.data[grid.i(x, y)] == '@';
    }
};

fn remove(grid: Grid) !usize {
    var to_remove_indices = try std.ArrayList(usize).initCapacity(alloc, grid.data.len);

    var y: i32 = 0;
    while (y < grid.h) : (y += 1) {
        var x: i32 = 0;
        while (x < grid.w) : (x += 1) {
            const i = grid.i(x, y);
            if (grid.data[i] == '@') {
                var adjacent_rolls: u8 = 0;
                adjacent_rolls += @intFromBool(grid.isRollAt(x - 1, y - 1));
                adjacent_rolls += @intFromBool(grid.isRollAt(x, y - 1));
                adjacent_rolls += @intFromBool(grid.isRollAt(x + 1, y - 1));
                adjacent_rolls += @intFromBool(grid.isRollAt(x - 1, y));
                // adjacent_rolls += @intFromBool(grid.isRollAt(x, y));
                adjacent_rolls += @intFromBool(grid.isRollAt(x + 1, y));
                adjacent_rolls += @intFromBool(grid.isRollAt(x - 1, y + 1));
                adjacent_rolls += @intFromBool(grid.isRollAt(x, y + 1));
                adjacent_rolls += @intFromBool(grid.isRollAt(x + 1, y + 1));
                if (adjacent_rolls < 4) try to_remove_indices.append(alloc, i);
            }
        }
    }

    const count = to_remove_indices.items.len;
    for (to_remove_indices.items) |i| grid.data[i] = '.';
    to_remove_indices.deinit(alloc);
    return count;
}

pub fn main() !void {
    const file = try std.fs.cwd().readFileAlloc(alloc, "data/d4.txt", 1024 * 1024);
    var grid_w: i32 = undefined;
    var grid_h: i32 = undefined;
    var i: usize = 0;
    while (i < file.len) : (i += 1) {
        if (file[i] == '\n') {
            grid_w = @intCast(i);
            break;
        }
    }
    grid_h = @divExact(@as(i32, @intCast(file.len)), grid_w + 1);
    const grid = Grid{ .data = file, .w = grid_w, .h = grid_h };

    var count: usize = 0;

    var prev_count: usize = 1;
    while (prev_count > 0) {
        prev_count = try remove(grid);
        count += prev_count;
    }

    std.debug.print("{}\n", .{count});
}
