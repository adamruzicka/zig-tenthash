# zig-tenthash

An implementation of TentHash (https://github.com/cessen/tenthash) implemented in zig.

```
# FILE=Fedora-Sway-Live-x86_64-41-1.4.iso

# du -Lh $FILE
1.6G    Fedora-Sway-Live-x86_64-41-1.4.iso

# zig build --release=fast

# for checksum in sha256sum sha512sum md5sum ./zig-out/bin/zig-tenthash; do
# echo -n "$checksum: "
# sh -c "time $checksum <$FILE >/dev/null"
# echo
# done

sha256sum: 
real    0m6.374s
user    0m6.228s
sys     0m0.134s

sha512sum: 
real    0m4.031s
user    0m3.898s
sys     0m0.123s

md5sum: 
real    0m2.212s
user    0m2.091s
sys     0m0.118s

./zig-out/bin/zig-tenthash: 
real    0m0.506s
user    0m0.323s
sys     0m0.183s
```
