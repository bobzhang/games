# Textures: Image Kernel Convolution

This example demonstrates image convolution using custom 3x3 kernels applied to a loaded image. When you run it, you see four vertical strips side by side: sharpen, Sobel edge detection, Gaussian blur (applied 6 times), and the original unprocessed image.

## Build and Run

```bash
moon build --target native raylib_textures_image_kernel/
./_build/native/debug/build/raylib_textures_image_kernel/raylib_textures_image_kernel.exe
```

## Controls

No interactive controls -- runs automatically.

## What It Demonstrates

- **`image_kernel_convolution`**: Applies a 3x3 convolution kernel to an image. The kernel is passed as raw bytes encoding float values, with a size parameter of 9 (3x3).
- **`image_copy`**: Creates independent copies of the original image so each kernel can be applied separately without modifying the source.
- **`image_crop`**: Crops each processed image to a 200x450 strip for side-by-side display.
- **Kernel normalization**: A helper function `normalize_kernel` divides each kernel element by the sum of all elements to prevent brightness changes.
- **Float-to-bytes conversion**: The `make_kernel_bytes` function manually converts a `FixedArray[Float]` into `Bytes` by extracting the IEEE 754 bit representation of each float using `reinterpret_as_int` and bitwise operations, demonstrating low-level byte manipulation in MoonBit.

## Public API Reference

### Package `raylib_textures_image_kernel`

> Single-package example.

No public API -- self-contained main function. The following helper functions are defined but not exported:

- `make_kernel_bytes(kernel : FixedArray[Float]) -> Bytes` -- Converts a float array to raw bytes for passing to the convolution function.
- `normalize_kernel(kernel : FixedArray[Float]) -> Unit` -- Normalizes kernel weights so they sum to 1.0.

## Architecture

The program loads the cat image and creates three copies. Three 3x3 convolution kernels are defined as `FixedArray[Float]`: Gaussian blur `[1,2,1,2,4,2,1,2,1]`, Sobel edge detection `[1,0,-1,2,0,-2,1,0,-1]`, and sharpen `[0,-1,0,-1,5,-1,0,-1,0]`. Each kernel is normalized, converted to bytes via `make_kernel_bytes`, and applied to its respective image copy. The Gaussian kernel is applied 6 times in a loop for a stronger blur effect. All four images are cropped to 200-pixel-wide strips and converted to textures. The render loop draws them side by side at x-positions 0, 200, 400, and 600.

## Key Takeaways

- `image_kernel_convolution` accepts raw bytes encoding float kernel values, requiring manual serialization from MoonBit's float arrays using `reinterpret_as_int` and byte extraction.
- Applying the same kernel multiple times (like the 6-pass Gaussian) produces a stronger effect, equivalent to convolving with a larger kernel.
- Normalizing kernels prevents the output image from becoming overly bright or dark, though some kernels like Sobel intentionally should not be normalized for edge detection.
