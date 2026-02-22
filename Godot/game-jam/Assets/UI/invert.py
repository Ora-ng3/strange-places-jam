from PIL import Image
import sys

def black_to_white(input_path, output_path, threshold=10):
    """
    Replace black pixels with white while preserving transparency.
    
    threshold: tolerance for detecting black (0–255).
               Lower = stricter black detection.
    """

    img = Image.open(input_path).convert("RGBA")
    pixels = img.load()

    width, height = img.size

    for y in range(height):
        for x in range(width):
            r, g, b, a = pixels[x, y]

            # Keep transparency unchanged
            if a == 0:
                continue

            # Detect near-black pixels
            if r <= threshold and g <= threshold and b <= threshold:
                pixels[x, y] = (255, 255, 255, a)

    img.save(output_path)
    print(f"Saved inverted image to: {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py input.png output.png")
    else:
        black_to_white(sys.argv[1], sys.argv[1])