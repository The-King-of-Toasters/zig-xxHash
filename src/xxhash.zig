const std = @import("std");
const mem = std.mem;
const math = std.math;
const assert = std.debug.assert;
const expectEqual = std.testing.expectEqual;

pub const XXHash32 = XXHash(XH32);
pub const XXHash64 = XXHash(XH64);

const XH32 = struct {
    pub const block_length = 16;
    pub const Int = u32;

    const primes = [5]u32{
        0x9e3779b1,
        0x85ebca77,
        0xc2b2ae3d,
        0x27d4eb2f,
        0x165667b1,
    };

    acc1: u32,
    acc2: u32,
    acc3: u32,
    acc4: u32,
    msg_len: u64 = 0,

    inline fn mix0(acc: u32, lane: u32) u32 {
        return math.rotl(u32, acc +% lane *% primes[1], 13) *% primes[0];
    }

    inline fn mix32(acc: u32, lane: u32) u32 {
        return math.rotl(u32, acc +% lane *% primes[2], 17) *% primes[3];
    }

    inline fn mix8(acc: u32, lane: u8) u32 {
        return math.rotl(u32, acc +% lane *% primes[4], 11) *% primes[0];
    }

    pub fn init(seed: u32) XH32 {
        return XH32{
            .acc1 = seed +% primes[0] +% primes[1],
            .acc2 = seed +% primes[1],
            .acc3 = seed,
            .acc4 = seed -% primes[0],
        };
    }

    pub fn update(self: *XH32, b: []const u8) void {
        assert(b.len % 16 == 0);

        const ints = @ptrCast([*]align(1) const u32, b.ptr)[0 .. b.len >> 2];
        var off: usize = 0;
        while (off < ints.len) : (off += 4) {
            const lane1 = mem.nativeToLittle(u32, ints[off + 0]);
            const lane2 = mem.nativeToLittle(u32, ints[off + 1]);
            const lane3 = mem.nativeToLittle(u32, ints[off + 2]);
            const lane4 = mem.nativeToLittle(u32, ints[off + 3]);

            self.acc1 = mix0(self.acc1, lane1);
            self.acc2 = mix0(self.acc2, lane2);
            self.acc3 = mix0(self.acc3, lane3);
            self.acc4 = mix0(self.acc4, lane4);
        }

        self.msg_len += b.len;
    }

    pub fn final(self: *XH32, b: []const u8) u32 {
        assert(b.len < 16);

        var acc = if (self.msg_len < 16)
            self.acc3 +% primes[4]
        else
            math.rotl(u32, self.acc1, 1) +%
                math.rotl(u32, self.acc2, 7) +%
                math.rotl(u32, self.acc3, 12) +%
                math.rotl(u32, self.acc4, 18);
        acc +%= @truncate(u32, self.msg_len +% b.len);

        switch (@intCast(u4, b.len)) {
            0 => {},
            1 => {
                acc = mix8(acc, b[0]);
            },
            2 => {
                acc = mix8(acc, b[0]);
                acc = mix8(acc, b[1]);
            },
            3 => {
                acc = mix8(acc, b[0]);
                acc = mix8(acc, b[1]);
                acc = mix8(acc, b[2]);
            },
            4 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
            },
            5 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
                acc = mix8(acc, b[4]);
            },
            6 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
                acc = mix8(acc, b[4]);
                acc = mix8(acc, b[5]);
            },
            7 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
                acc = mix8(acc, b[4]);
                acc = mix8(acc, b[5]);
                acc = mix8(acc, b[6]);
            },
            8 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
            },
            9 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix8(acc, b[8]);
            },
            10 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix8(acc, b[8]);
                acc = mix8(acc, b[9]);
            },
            11 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix8(acc, b[8]);
                acc = mix8(acc, b[9]);
                acc = mix8(acc, b[10]);
            },
            12 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                const num3 = mem.readIntLittle(u32, b[8..12]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix32(acc, num3);
            },
            13 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                const num3 = mem.readIntLittle(u32, b[8..12]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix32(acc, num3);
                acc = mix8(acc, b[12]);
            },
            14 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                const num3 = mem.readIntLittle(u32, b[8..12]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix32(acc, num3);
                acc = mix8(acc, b[12]);
                acc = mix8(acc, b[13]);
            },
            15 => {
                const num1 = mem.readIntLittle(u32, b[0..4]);
                const num2 = mem.readIntLittle(u32, b[4..8]);
                const num3 = mem.readIntLittle(u32, b[8..12]);
                acc = mix32(acc, num1);
                acc = mix32(acc, num2);
                acc = mix32(acc, num3);
                acc = mix8(acc, b[12]);
                acc = mix8(acc, b[13]);
                acc = mix8(acc, b[14]);
            },
        }

        acc ^= acc >> 15;
        acc *%= primes[1];
        acc ^= acc >> 13;
        acc *%= primes[2];
        acc ^= acc >> 16;

        return acc;
    }
};

pub const XH64 = struct {
    pub const block_length = 32;
    pub const Int = u64;

    const primes = [5]u64{
        0x9e3779b185ebca87,
        0xc2b2ae3d27d4eb4f,
        0x165667b19e3779f9,
        0x85ebca77c2b2ae63,
        0x27d4eb2f165667c5,
    };

    acc1: u64,
    acc2: u64,
    acc3: u64,
    acc4: u64,
    msg_len: u64 = 0,

    inline fn mix0(acc: u64, lane: u64) u64 {
        return math.rotl(u64, acc +% lane *% primes[1], 31) *% primes[0];
    }

    inline fn mix1(acc: u64, lane: u64) u64 {
        return (acc ^ mix0(0, lane)) *% primes[0] +% primes[3];
    }

    inline fn mix64(acc: u64, lane: u64) u64 {
        return math.rotl(u64, acc ^ mix0(0, lane), 27) *% primes[0] +% primes[3];
    }

    inline fn mix32(acc: u64, lane: u32) u64 {
        return math.rotl(u64, acc ^ (lane *% primes[0]), 23) *% primes[1] +% primes[2];
    }

    inline fn mix8(acc: u64, lane: u8) u64 {
        return math.rotl(u64, acc ^ (lane *% primes[4]), 11) *% primes[0];
    }

    pub fn init(seed: u64) XH64 {
        return XH64{
            .acc1 = seed +% primes[0] +% primes[1],
            .acc2 = seed +% primes[1],
            .acc3 = seed,
            .acc4 = seed -% primes[0],
        };
    }

    pub fn update(self: *XH64, b: []const u8) void {
        assert(b.len % 32 == 0);

        const ints = @ptrCast([*]align(1) const u64, b.ptr)[0 .. b.len >> 3];
        var off: usize = 0;
        while (off < ints.len) : (off += 4) {
            const lane1 = mem.nativeToLittle(u64, ints[off + 0]);
            const lane2 = mem.nativeToLittle(u64, ints[off + 1]);
            const lane3 = mem.nativeToLittle(u64, ints[off + 2]);
            const lane4 = mem.nativeToLittle(u64, ints[off + 3]);

            self.acc1 = mix0(self.acc1, lane1);
            self.acc2 = mix0(self.acc2, lane2);
            self.acc3 = mix0(self.acc3, lane3);
            self.acc4 = mix0(self.acc4, lane4);
        }

        self.msg_len += b.len;
    }

    pub fn final(self: *XH64, b: []const u8) u64 {
        assert(b.len < 32);

        var acc = if (self.msg_len < 32)
            self.acc3 +% primes[4]
        else blk: {
            var h =
                math.rotl(u64, self.acc1, 1) +%
                math.rotl(u64, self.acc2, 7) +%
                math.rotl(u64, self.acc3, 12) +%
                math.rotl(u64, self.acc4, 18);

            h = mix1(h, self.acc1);
            h = mix1(h, self.acc2);
            h = mix1(h, self.acc3);
            h = mix1(h, self.acc4);

            break :blk h;
        };
        acc +%= self.msg_len +% b.len;

        switch (@intCast(u5, b.len)) {
            0 => {},
            1 => {
                acc = mix8(acc, b[0]);
            },
            2 => {
                acc = mix8(acc, b[0]);
                acc = mix8(acc, b[1]);
            },
            3 => {
                acc = mix8(acc, b[0]);
                acc = mix8(acc, b[1]);
                acc = mix8(acc, b[2]);
            },
            4 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
            },
            5 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
                acc = mix8(acc, b[4]);
            },
            6 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
                acc = mix8(acc, b[4]);
                acc = mix8(acc, b[5]);
            },
            7 => {
                const num = mem.readIntLittle(u32, b[0..4]);
                acc = mix32(acc, num);
                acc = mix8(acc, b[4]);
                acc = mix8(acc, b[5]);
                acc = mix8(acc, b[6]);
            },
            8 => {
                const num = mem.readIntLittle(u64, b[0..8]);
                acc = mix64(acc, num);
            },
            9 => {
                const num = mem.readIntLittle(u64, b[0..8]);
                acc = mix64(acc, num);
                acc = mix8(acc, b[8]);
            },
            10 => {
                const num = mem.readIntLittle(u64, b[0..8]);
                acc = mix64(acc, num);
                acc = mix8(acc, b[8]);
                acc = mix8(acc, b[9]);
            },
            11 => {
                const num = mem.readIntLittle(u64, b[0..8]);
                acc = mix64(acc, num);
                acc = mix8(acc, b[8]);
                acc = mix8(acc, b[9]);
                acc = mix8(acc, b[10]);
            },
            12 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u32, b[8..12]);
                acc = mix64(acc, num1);
                acc = mix32(acc, num2);
            },
            13 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u32, b[8..12]);
                acc = mix64(acc, num1);
                acc = mix32(acc, num2);
                acc = mix8(acc, b[12]);
            },
            14 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u32, b[8..12]);
                acc = mix64(acc, num1);
                acc = mix32(acc, num2);
                acc = mix8(acc, b[12]);
                acc = mix8(acc, b[13]);
            },
            15 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u32, b[8..12]);
                acc = mix64(acc, num1);
                acc = mix32(acc, num2);
                acc = mix8(acc, b[12]);
                acc = mix8(acc, b[13]);
                acc = mix8(acc, b[14]);
            },
            16 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
            },
            17 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix8(acc, b[16]);
            },
            18 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix8(acc, b[16]);
                acc = mix8(acc, b[17]);
            },
            19 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix8(acc, b[16]);
                acc = mix8(acc, b[17]);
                acc = mix8(acc, b[18]);
            },
            20 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u32, b[16..20]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix32(acc, num3);
            },
            21 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u32, b[16..20]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix32(acc, num3);
                acc = mix8(acc, b[20]);
            },
            22 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u32, b[16..20]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix32(acc, num3);
                acc = mix8(acc, b[20]);
                acc = mix8(acc, b[21]);
            },
            23 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u32, b[16..20]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix32(acc, num3);
                acc = mix8(acc, b[20]);
                acc = mix8(acc, b[21]);
                acc = mix8(acc, b[22]);
            },
            24 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
            },
            25 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix8(acc, b[24]);
            },
            26 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix8(acc, b[24]);
                acc = mix8(acc, b[25]);
            },
            27 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix8(acc, b[24]);
                acc = mix8(acc, b[25]);
                acc = mix8(acc, b[26]);
            },
            28 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                const num4 = mem.readIntLittle(u32, b[24..28]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix32(acc, num4);
            },
            29 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                const num4 = mem.readIntLittle(u32, b[24..28]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix32(acc, num4);
                acc = mix8(acc, b[28]);
            },
            30 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                const num4 = mem.readIntLittle(u32, b[24..28]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix32(acc, num4);
                acc = mix8(acc, b[28]);
                acc = mix8(acc, b[29]);
            },
            31 => {
                const num1 = mem.readIntLittle(u64, b[0..8]);
                const num2 = mem.readIntLittle(u64, b[8..16]);
                const num3 = mem.readIntLittle(u64, b[16..24]);
                const num4 = mem.readIntLittle(u32, b[24..28]);
                acc = mix64(acc, num1);
                acc = mix64(acc, num2);
                acc = mix64(acc, num3);
                acc = mix32(acc, num4);
                acc = mix8(acc, b[28]);
                acc = mix8(acc, b[29]);
                acc = mix8(acc, b[30]);
            },
        }

        acc ^= acc >> 33;
        acc *%= primes[1];
        acc ^= acc >> 29;
        acc *%= primes[2];
        acc ^= acc >> 32;

        return acc;
    }
};

fn XXHash(comptime Impl: type) type {
    return struct {
        const Self = @This();

        pub const block_length = Impl.block_length;

        state: Impl,
        buf: [block_length]u8 = undefined,
        buf_len: u8 = 0,

        pub fn init(seed: Impl.Int) Self {
            return Self{ .state = Impl.init(seed) };
        }

        pub fn update(self: *Self, b: []const u8) void {
            var off: usize = 0;

            if (self.buf_len != 0 and self.buf_len + b.len >= block_length) {
                off += block_length - self.buf_len;
                mem.copy(u8, self.buf[self.buf_len..], b[0..off]);
                self.state.update(self.buf[0..]);
                self.buf_len = 0;
            }

            const remain_len = b.len - off;
            const aligned_len = remain_len - (remain_len % block_length);
            self.state.update(b[off .. off + aligned_len]);

            mem.copy(u8, self.buf[self.buf_len..], b[off + aligned_len ..]);
            self.buf_len += @intCast(u8, b[off + aligned_len ..].len);
        }

        pub fn final(self: *Self) Impl.Int {
            const rem_key = self.buf[0..self.buf_len];

            return self.state.final(rem_key);
        }

        pub fn hash(seed: Impl.Int, input: []const u8) Impl.Int {
            const aligned_len = input.len - (input.len % block_length);

            var c = Impl.init(seed);
            @call(.always_inline, c.update, .{input[0..aligned_len]});
            return @call(.always_inline, c.final, .{input[aligned_len..]});
        }
    };
}

const prime32: u32 = 2654435761;
const prime64: u64 = 11400714785074694797;
const test_buffer1 = blk: {
    @setEvalBranchQuota(3000);

    var bytegen: u64 = prime32;
    var buf: [2367]u8 = undefined;

    for (buf) |*c| {
        c.* = @truncate(u8, bytegen >> 56);
        bytegen *%= prime64;
    }

    break :blk buf;
};
const test_buffer2 = blk: {
    var buf: [100]u8 = undefined;
    for (buf) |*c, i| c.* = i;
    break :blk &buf;
};

const Test = struct {
    seed: u64,
    data: []const u8,
    sum: u64,

    fn new(seed: u64, data: []const u8, sum: u64) Test {
        return Test{ .seed = seed, .data = data, .sum = sum };
    }
};
const test_data32 = [_]Test{
    // From the reference C implementation
    Test.new(0, "", 0x02cc5d05),
    Test.new(prime32, "", 0x36b78ae7),
    Test.new(0, test_buffer1[0..1], 0xCF65B03E),
    Test.new(prime32, test_buffer1[0..1], 0xB4545AA4),
    Test.new(0, test_buffer1[0..14], 0x1208E7E2),
    Test.new(prime32, test_buffer1[0..14], 0x6AF1D1FE),
    Test.new(0, test_buffer1[0..222], 0x5BD11DBD),
    Test.new(prime32, test_buffer1[0..222], 0x58803C5F),
    // From the twox-hash rust crate
    Test.new(0, &[_]u8{42}, 0xe0fe705f),
    Test.new(0, "Hello, world!\x00", 0x9e5e7e93),
    Test.new(0, test_buffer2, 0x7f89ba44),
    Test.new(0x42c91977, "", 0xd6bf8459),
    Test.new(0x42c91977, test_buffer2, 0x6d2f6c17),
};
const test_data64 = [_]Test{
    // From the reference C implementation
    Test.new(0, "", 0xef46db3751d8e999),
    Test.new(prime32, test_buffer1[0..0], 0xac75fda2929b17ef),
    Test.new(0, test_buffer1[0..1], 0xe934a84adb052768),
    Test.new(prime32, test_buffer1[0..1], 0x5014607643a9b4c3),
    Test.new(0, test_buffer1[0..4], 0x9136a0dca57457ee),
    Test.new(0, test_buffer1[0..14], 0x8282dcc4994e35c8),
    Test.new(prime32, test_buffer1[0..14], 0xc3bd6bf63deb6df0),
    Test.new(0, test_buffer1[0..222], 0xb641ae8cb691c174),
    Test.new(prime32, test_buffer1[0..222], 0x20cb8ab7ae10c14a),
    // From the twox-hash rust crate
    Test.new(0, &[_]u8{42}, 0x0a9edecebeb03ae4),
    Test.new(0, "Hello, world!\x00", 0x7b06c531ea43e89f),
    Test.new(0, test_buffer2, 0x6ac1e58032166597),
    Test.new(0xae0543311b702d91, "", 0x4b6a04fcdf7a4672),
    Test.new(0xae0543311b702d91, test_buffer2, 0x567e355e0682e1f1),
};

test "XXHash Test Vectors" {
    for (test_data64) |t| try expectEqual(t.sum, XXHash64.hash(t.seed, t.data));
    for (test_data32) |t| try expectEqual(t.sum, XXHash32.hash(@intCast(u32, t.seed), t.data));
}
