const std = @import("std");
const testing = std.testing;

const rotation_constants = [_]struct{u64, u64}{
    .{16, 28}, .{14, 57}, .{11, 22}, .{35, 34},
    .{57, 16}, .{59, 40}, .{44, 13},
};

const HashState = struct {
    a: u64,
    b: u64,
    c: u64,
    d: u64,
    count: u64,

    pub fn init() HashState {
        return HashState{
            .a = 0x5d6daffc4411a967,
            .b = 0xe22d4dea68577f34,
            .c = 0xca50864d814cbc2e,
            .d = 0x894e29b9611eb173,
            .count = 0,
        };
    }

    pub fn digest(self: HashState) [40]u8 {
        const buf: [4]u64 = .{self.a, self.b, self.c, self.d};
        const bytes = std.mem.asBytes(&buf)[0..20];
        return std.fmt.bytesToHex(bytes, .lower);
    }

    pub fn hash(data: []const u8) [40]u8 {
        var hasher = HashState.init();
        var buf: []const u8 = data;

        while (buf.len > 0) {
            const size = hasher.hash_block(buf);
            buf = buf[size..];
        }
        hasher.finalize();
        return hasher.digest();
    }

    fn hash_block(self: *HashState, data: []const u8) u64 {
        var buf: [32]u8 = .{0} ** 32;
        const count = @min(data.len, 32);
        std.mem.copyBackwards(u8, &buf, data[0..count]);
        self.count = @addWithOverflow(self.count, count)[0];

        const parts = std.mem.bytesAsSlice(u64, &buf);
        self.a ^= parts[0];
        self.b ^= parts[1];
        self.c ^= parts[2];
        self.d ^= parts[3];
        self.mix();

        return count;
    }

    fn mix(self: *HashState) void {
        for (rotation_constants) |pair| {
            self.a = @addWithOverflow(self.a, self.c)[0];
            self.b = @addWithOverflow(self.b, self.d)[0];
            self.c = std.math.rotl(u64, self.c, pair[0]) ^ self.a;
            self.d = std.math.rotl(u64, self.d, pair[1]) ^ self.b;
            std.mem.swap(u64, &self.a, &self.b);
        }
    }

    fn finalize(self: *HashState) void {
        self.a ^= @mulWithOverflow(self.count, 8)[0];
        self.mix();
        self.mix();
    }
};

test "A single zero byte" {
    const input = [_]u8{ 0 };
    const result = HashState.hash(&input);
    try testing.expect(std.mem.eql(u8, &result, "3cf6833cca9c4d5e211318577bab74bf12a4f090"));
}

test "The ascii string '0123456789'" {
    const input: []const u8 = "0123456789";
    const result = HashState.hash(input);
    try testing.expect(std.mem.eql(u8, &result, "a7d324bde0bf6ce3427701628f0f8fc329c2a116"));
}

test "The ascii string 'abcdefghijklmnopqrstuvwxyz'" {
    const input: []const u8 = "abcdefghijklmnopqrstuvwxyz";
    const result = HashState.hash(input);
    try testing.expect(std.mem.eql(u8, &result, "f1be4be1a0f9eae6500fb2f6b64f3daa3990ac1a"));
}

test "The ascii string 'This string is exactly 32 bytes.'" {
    const input: []const u8 = "This string is exactly 32 bytes.";
    const result = HashState.hash(input);
    try testing.expect(std.mem.eql(u8, &result, "f7c5e4763d89bddce33e97712b712d869aabcfe9"));
}

test "The ascii string 'The quick brown fox jumps over the lazy dog.'" {
    const input: []const u8 = "The quick brown fox jumps over the lazy dog.";
    const result = HashState.hash(input);
    try testing.expect(std.mem.eql(u8, &result, "de77f1c134228be1b5b25c941d5102f87f3e6d39"));
}
