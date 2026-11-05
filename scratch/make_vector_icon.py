# Python script to generate vector SVG for Opennote "On" converging monogram
from PIL import Image
import os

svg_content = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024" width="1024" height="1024">
  <rect width="1024" height="1024" fill="#050505" />
  <g fill="#FFFFFF" fill-rule="evenodd">
    <!-- Outer O combined with n arch and stems -->
    <path d="
      M 370 252
      A 260 260 0 1 0 575 671
      L 575 772
      L 675 772
      L 675 510
      C 675 440 710 400 765 400
      C 820 400 855 440 855 510
      L 855 772
      L 955 772
      L 955 490
      C 955 370 875 300 755 300
      C 670 300 610 345 575 410
      A 260 260 0 0 0 370 252
      Z
      M 370 352
      A 160 160 0 1 1 370 672
      A 160 160 0 0 1 370 352
      Z
    " />
  </g>
</svg>
"""

svg_path = "assets/icon/opennote_vector_concept.svg"
with open(svg_path, "w", encoding="utf-8") as f:
    f.write(svg_content)
print(f"Generated {svg_path}")
