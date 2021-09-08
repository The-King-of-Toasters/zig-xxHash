Zig implementaions of the original xxHash digest algorithms: xxHash32
and xxHash64. There exists [another
implementation](https://github.com/clownpriest/xxhash), but it has
unfortunately bit-rotted over time due to the many changes in the Zig
language. This implementation is structured to have a similar API to the
existing hashing algorithms in the standard library. The performance is
competitive with them too - here is the result of running
`src/benchmark.zig` with the `ReleaseFast` build mode. The first column
was from a Ryzen 7 3700X, the second an i7-2620M:

```
wyhash
   iterative:    6787 MiB/s    7050 MiB/s [84b9fcc452c9983b]
  small keys:   12846 MiB/s    7160 MiB/s [3959292c08000000]
fnv1a
   iterative:    1002 MiB/s     805 MiB/s [1e3d9d378e4b7325]
  small keys:    1641 MiB/s    1359 MiB/s [b949e3e834400000]
adler32
   iterative:    3627 MiB/s    2811 MiB/s [a302147400000000]
  small keys:    2851 MiB/s    1957 MiB/s [3a4403c240000000]
crc32-slicing-by-8
   iterative:    2739 MiB/s    1709 MiB/s [ab94acd000000000]
  small keys:    4199 MiB/s    2204 MiB/s [3b4945b200000000]
crc32-half-byte-lookup
   iterative:     243 MiB/s     177 MiB/s [ab94acd000000000]
  small keys:     309 MiB/s     197 MiB/s [3b4945b200000000]
cityhash-32
  small keys:    6413 MiB/s    3499 MiB/s [323c336000000000]
cityhash-64
  small keys: 1145004 MiB/s  697623 MiB/s [b9bf898c9dc00000]
murmur2-32
  small keys:    4628 MiB/s    3003 MiB/s [1041b9c940000000]
murmur2-64
  small keys:    8514 MiB/s    5097 MiB/s [1d2b492b8b800000]
murmur3-32
  small keys:    4296 MiB/s    2477 MiB/s [37385682c0000000]
xxhash-32
   iterative:    8043 MiB/s    5468 MiB/s [dad3604000000000]
  small keys:   10010 MiB/s    3868 MiB/s [db11230c00000000]
xxhash-64
   iterative:    9587 MiB/s   10916 MiB/s [53b384fe4fb92291]
  small keys:    4586 MiB/s    2642 MiB/s [bfa9f0074d400000]

```
