const std = @import("std");
const tenthash = @import("root.zig");

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    var buf: [4096]u8 = .{0} ** 4096;
    const stdin_file = std.io.getStdIn().reader();
    var br = std.io.bufferedReader(stdin_file);
    var hasher = tenthash.TentHasher.init();
    while (true) {
        const nread = try br.read(&buf);
        if (nread == 0) break;

        hasher.update(buf[0..nread]);
    }
    hasher.finalize();

    try stdout.print("{s}\n", .{hasher.digest()});

    try bw.flush(); // don't forget to flush!
}
