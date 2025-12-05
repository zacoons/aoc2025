const std = @import("std");

const alloc = std.heap.smp_allocator;

const Link = struct {
    prev: ?*Link = null,
    next: ?*Link = null,

    pub fn owner(link: *Link) *Range {
        return @fieldParentPtr("link", link);
    }
};

const LinkedList = struct {
    first: ?*Link = null,

    pub fn prepend(list: *LinkedList, link: *Link) void {
        if (list.first) |first| first.prev = link;
        link.next = list.first;
        list.first = link;
    }

    pub fn remove(list: *LinkedList, link: *Link) void {
        if (list.first == link) list.first = link.next;
        if (link.prev) |prev| prev.next = link.next;
        if (link.next) |next| next.prev = link.prev;
    }
};

const Range = struct {
    link: Link = .{},
    min: u64,
    max: u64,

    pub fn init(min: u64, max: u64) !*Range {
        const range = try alloc.create(Range);
        range.* = .{ .min = min, .max = max };
        return range;
    }

    pub fn deinit(range: *Range) void {
        alloc.destroy(range);
    }

    pub fn contains(r: *const Range, v: u64) bool {
        return v >= r.min and v <= r.max;
    }

    pub fn merge(r: *Range, other: *Range) bool {
        const contains_min = r.contains(other.min);
        const contains_max = r.contains(other.max);
        if (contains_min and contains_max) {
            return true;
        } else if (contains_min) {
            r.max = other.max;
            return true;
        } else if (contains_max) {
            r.min = other.min;
            return true;
        } else if (other.contains(r.min) and other.contains(r.max)) {
            r.min = other.min;
            r.max = other.max;
            return true;
        }
        return false;
    }
};

fn getFreshCount(reader: *std.Io.Reader) !u64 {
    var linebuf: [128]u8 = undefined;

    var list = LinkedList{};

    while (true) {
        var linebuf_w = std.Io.Writer.fixed(&linebuf);
        const n = try reader.streamDelimiterEnding(&linebuf_w, '\n');
        if (n == 0) break;
        reader.toss(1); // Skip over the delimiter itself
        const line = linebuf[0..n];

        const separator_i = std.mem.indexOfScalar(u8, line, '-').?;
        const min = try std.fmt.parseInt(u64, line[0..separator_i], 10);
        const max = try std.fmt.parseInt(u64, line[separator_i + 1 ..], 10);
        const range = try Range.init(min, max);

        var current_nullable = list.first;
        while (current_nullable) |current| {
            const next = current.next;
            if (range.merge(current.owner())) {
                list.remove(current);
                current.owner().deinit();
            }
            current_nullable = next;
        }
        list.prepend(&range.link);
    }

    var count: u64 = 0;
    var current_nullable = list.first;
    while (current_nullable) |current| : (current_nullable = current.next) {
        std.debug.print("{} {}\n", .{ current.owner().min, current.owner().max });
        count += current.owner().max - current.owner().min + 1;
    }

    return count;
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("data/d5.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);
    std.debug.print("{}\n", .{try getFreshCount(&reader.interface)});
}

test "test data" {
    const file = try std.fs.cwd().openFile("data/d5_test.txt", .{ .mode = .read_only });
    const readbuf = try alloc.alloc(u8, 512);
    var reader = file.reader(readbuf);
    std.debug.print("{}\n", .{try getFreshCount(&reader.interface)});
}
