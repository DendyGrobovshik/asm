#include <jpeglib.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// install libjpeg `sudo apt-get install libjpeg-dev`
// This code can be used as visual test of rgb to yuv transformation
// RGB2YUV 256 range transformation based on page 4:
// https://www.w3.org/Graphics/JPEG/jfif.pdf A bit more about jpeg(RU):
// https://habr.com/ru/articles/454944/ About ranges of colors(RU):
// https://projectorworld.ru/blog/793.html,
// https://mechaweaponsvidya.wordpress.com/2015/05/03/full-range-ycbcr-in-jpeg/

extern RGB2YUV(const uint8_t *in, uint8_t *restrict out, size_t width,
               size_t height, ptrdiff_t in_stride, ptrdiff_t out_stride);

extern YUV2RGB(const uint8_t *in, uint8_t *restrict out, size_t width,
               size_t height, ptrdiff_t in_stride, ptrdiff_t out_stride);

typedef struct {
  uint8_t r;
  uint8_t g;
  uint8_t b;
} RGB;

typedef struct {
  uint8_t y;
  uint8_t cb;
  uint8_t cr;
} YCbCr;

YCbCr rgb2ycbcr(RGB rgb) {
  YCbCr ybr;

  float y = (0.299 * rgb.r + 0.587 * rgb.g + 0.114 * rgb.b);
  ybr.y = (uint8_t)y;
  float cb = (128 - 0.168736 * rgb.r - 0.331264 * rgb.g + 0.5 * rgb.b);
  ybr.cb = (uint8_t)cb;
  float cr = (128 + 0.5 * rgb.r - 0.418688 * rgb.g - 0.081312 * rgb.b);
  ybr.cr = (uint8_t)cr;

  return ybr;
}

RGB ycbcr2rgb(YCbCr ycb) {
  RGB rgb;

  float r = ycb.y + 1.402 * (ycb.cr - 128);
  rgb.r = (uint8_t)r;

  float g = ycb.y - 0.34414 * (ycb.cb - 128) - 0.71414 * (ycb.cr - 128);
  rgb.g = (uint8_t)g;

  float b = ycb.y + 1.772 * (ycb.cb - 128);
  rgb.b = (uint8_t)b;

  return rgb;
}

void c_RGB2YUV(const uint8_t *in, uint8_t *restrict out, size_t width,
               size_t height, ptrdiff_t in_stride, ptrdiff_t out_stride) {
  printf("c_RGB2YUV in: %p, out: %p, width: %li, height: %li, in_stride: %li, "
         "out_stride: %li\n",
         in, out, width, height, in_stride, out_stride);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x += 3) {
      const uint8_t *pixel_in = in + y * in_stride + x;
      uint8_t *pixel_out = out + y * out_stride + x;
      YCbCr ycbcr = rgb2ycbcr((RGB){pixel_in[0], pixel_in[1], pixel_in[2]});
      pixel_out[0] = ycbcr.y;
      pixel_out[1] = ycbcr.cb;
      pixel_out[2] = ycbcr.cr;
    }
  }
}

void c_YUV2RGB(const uint8_t *in, uint8_t *restrict out, size_t width,
               size_t height, ptrdiff_t in_stride, ptrdiff_t out_stride) {
  printf("cYUV2RGB");
}

int main() {
  struct jpeg_decompress_struct cinfo;
  struct jpeg_compress_struct cinfo_out;
  struct jpeg_error_mgr jerr;
  FILE *infile, *outfile;
  JSAMPARRAY buffer;
  int row_stride;

  if ((infile = fopen("in.jpeg", "rb")) == NULL) {
    fprintf(stderr, "can't open %s\n", "in.jpeg");
    return 1;
  }

  if ((outfile = fopen("out.jpeg", "wb")) == NULL) {
    fprintf(stderr, "can't open %s\n", "out.jpeg");
    return 1;
  }

  // Set up the error handler
  cinfo.err = jpeg_std_error(&jerr);

  // Initialize the decompression
  jpeg_create_decompress(&cinfo);
  jpeg_stdio_src(&cinfo, infile);
  jpeg_read_header(&cinfo, TRUE);
  jpeg_start_decompress(&cinfo);

  row_stride = cinfo.output_width * cinfo.output_components;

  // Allocate memory for one row
  buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr)&cinfo, JPOOL_IMAGE,
                                      row_stride, 1);

  // Allocate memory for the whole image
  uint8_t *in_buffer = (uint8_t *)malloc(row_stride * cinfo.output_height);
  uint8_t *out_buffer = (uint8_t *)malloc(row_stride * cinfo.output_height);

  // Read the entire image
  while (cinfo.output_scanline < cinfo.output_height) {
    jpeg_read_scanlines(&cinfo, buffer, 1);
    memcpy(&in_buffer[(cinfo.output_scanline - 1) * row_stride], buffer[0],
           row_stride);
  }

  memcpy(out_buffer, in_buffer, row_stride * cinfo.output_height);

  size_t width = row_stride;
  size_t height = cinfo.output_height;
  // ptrdiff_t offset = (width * (height / 15) + (width / 5));
  // c_RGB2YUV(in_buffer + offset, out_buffer + offset, width / 2, height
  // / 1.67,
  //           width, width);
  ptrdiff_t offset = (width * (height / 5) + (width / 4));
  ptrdiff_t out_offset = (width * (height / 5 * 3) + (width / 4));
  RGB2YUV(in_buffer + offset, out_buffer + out_offset, width / 2, height / 2,
          width, -width); // TODO:
  c_RGB2YUV(in_buffer + offset, out_buffer + out_offset, width / 2, height / 2,
            width, -width);

  // Finish decompression
  jpeg_finish_decompress(&cinfo);
  jpeg_destroy_decompress(&cinfo);

  // Close input file
  fclose(infile);

  // Set up the compression
  cinfo_out.err = jpeg_std_error(&jerr);
  jpeg_create_compress(&cinfo_out);
  jpeg_stdio_dest(&cinfo_out, outfile);

  // Set compression parameters
  cinfo_out.image_width = cinfo.image_width;
  cinfo_out.image_height = cinfo.image_height;
  cinfo_out.input_components = cinfo.output_components;
  //   cinfo_out.in_color_space = JCS_RGB;
  jpeg_set_defaults(&cinfo_out);
  jpeg_set_quality(&cinfo_out, 95, TRUE);

  // Start compression
  jpeg_start_compress(&cinfo_out, TRUE);

  // Write the processed image
  while (cinfo_out.next_scanline < cinfo_out.image_height) {
    JSAMPROW row_pointer[1];
    row_pointer[0] = &out_buffer[cinfo_out.next_scanline * row_stride];
    jpeg_write_scanlines(&cinfo_out, row_pointer, 1);
  }

  // Finish compression
  jpeg_finish_compress(&cinfo_out);
  jpeg_destroy_compress(&cinfo_out);

  // Close output file
  fclose(outfile);

  // Free the image buffer
  free(in_buffer);
  free(out_buffer);

  return 0;
}
