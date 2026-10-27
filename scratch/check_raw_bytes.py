with open(r"E:\02_Projects\Opennote\scratch\raw.bin", "rb") as f:
    f.seek(16)
    data = f.read()

from collections import Counter
c = Counter(data)
print("Byte frequency in raw.bin:")
for b, count in c.most_common(10):
    print(f"Byte {b} (0x{b:02x}): {count}")
