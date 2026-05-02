import sys
import re

filepath = r'c:\Users\wongk\Desktop\fyp\4 Combined power plant\ThermoPower\ThermoPower\CombineCycle.mo'
with open(filepath, 'r', encoding='utf-8') as f:
    text = f.read()

# Replace pstart values for the entire Gas Turbine (OpenLoop and CloseLoop)
# 1. Compressor
# pstart_out = 8.3e5 -> 2.45e6
text = text.replace('pstart_out = 8.3e5', 'pstart_out = 2.45e6')

# 2. Fuel Source p0
# p0 = 811000 -> p0 = 2500000
text = text.replace('p0 = 811000', 'p0 = 2500000')

# 3. Combustion Chamber
# pstart = 8.11e5 -> pstart = 2.41e6
text = text.replace('pstart = 8.11e5', 'pstart = 2.41e6')

# 4. PressDrop1
# pstart = 811000 -> pstart = 2410000
text = text.replace('pstart = 811000', 'pstart = 2410000')

# 5. PressDrop2
# pstart = 8.3e5 -> pstart = 2.45e6
text = text.replace('pstart = 8.3e5', 'pstart = 2.45e6')

# 6. Turbine
# pstart_in = 7.85e5 -> pstart_in = 2.38e6
text = text.replace('pstart_in = 7.85e5', 'pstart_in = 2.38e6')

# 7. Turbine exhaust
# pstart_out = 1.52e5 -> pstart_out = 1.05e5
text = text.replace('pstart_out = 1.52e5', 'pstart_out = 1.05e5')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(text)
print("Initialization pressures updated!")
