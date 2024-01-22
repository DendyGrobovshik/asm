#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jpeglib.h>
#include <windows.h>

// install libjpeg `sudo apt-get install libjpeg-dev`
// This code can be used as visual test of rgb to yuv transformation
// # RGB2YUV 256 range transformation based on page 4:
// - https://www.w3.org/Graphics/JPEG/jfif.pdf
// # A bit more about jpeg(RU):
// - https://habr.com/ru/articles/454944/
// # About ranges of colors(RU):
// - https://projectorworld.ru/blog/793.html
// -
// https://mechaweaponsvidya.wordpress.com/2015/05/03/full-range-ycbcr-in-jpeg/
// # Big review of color spaces
// - https://www.compression.ru/download/articles/color_space/ch03.pdf

extern void _fastcall RGB2YUV(const uint8_t *in, uint8_t *restrict out,
                              size_t width, size_t height, ptrdiff_t in_stride,
                              ptrdiff_t out_stride);

extern void _fastcall YUV2RGB(const uint8_t *in, uint8_t *restrict out,
                              size_t width, size_t height, ptrdiff_t in_stride,
                              ptrdiff_t out_stride);

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
  float b = max(ycb.y + 1.772 * (ycb.cb - 128), 0.0);
  rgb.b = (uint8_t)b;

  return rgb;
}

void c_RGB2YUV(const uint8_t *in, uint8_t *restrict out, size_t width,
               size_t height, ptrdiff_t in_stride, ptrdiff_t out_stride) {
  printf("c_RGB2YUV in: %p, out: %p, width: %zi, height: %zi, in_stride: %ti, "
         "out_stride: %ti\n",
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
  printf("c_YUV2RGB in: %p, out: %p, width: %zi, height: %zi, in_stride: %ti, "
         "out_stride: %ti\n",
         in, out, width, height, in_stride, out_stride);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x += 3) {
      const uint8_t *pixel_in = in + y * in_stride + x;
      uint8_t *pixel_out = out + y * out_stride + x;
      RGB rgb = ycbcr2rgb((YCbCr){pixel_in[0], pixel_in[1], pixel_in[2]});
      pixel_out[0] = rgb.r;
      pixel_out[1] = rgb.g;
      pixel_out[2] = rgb.b;
    }
  }
}

void print_solution_score(uint8_t *etalon, uint8_t *buffer, size_t row_stride,
                          size_t height) {
  int max_delta = 0;
  int sum_delta = 0;

  size_t size = row_stride * height;
  for (size_t i = 0; i < size; i++) {
    int delta = abs(etalon[i] - buffer[i]);
    sum_delta += delta;
    if (delta >= max_delta) {
      if (delta > 3) {
        printf("delta: %i, pos=[%zi][%zi](%zi) {%i}!={%i} %c %p\n", delta,
               i / row_stride, i % row_stride, (i % row_stride) % 3, etalon[i],
               buffer[i], "RGB"[i % 3], &etalon[i]);
      }
      max_delta = delta;
    }
  }

  printf("(size=%zi)max_delta=%i, sum_delta=%i k=%f\n\n", size, max_delta,
         sum_delta, (float)sum_delta / size);
}

void YUV3toYUV4(uint8_t *in3, uint8_t *out4, size_t new_size) {
  size_t pixels = new_size / 4;
  for (size_t pixel = 0; pixel < pixels; pixel += 1) {
    out4[pixel * 4] = in3[pixel * 3];
    out4[pixel * 4 + 1] = in3[pixel * 3 + 1];
    out4[pixel * 4 + 2] = in3[pixel * 3 + 2];
    out4[pixel * 4 + 3] = 0; // fake byte
  }
}

void YUV4toYUV3(uint8_t *in4, uint8_t *out3, size_t new_size) {
  size_t pixels = new_size / 4;
  for (size_t pixel = 0; pixel < pixels; pixel += 1) {
    out3[pixel * 3] = in4[pixel * 4];
    out3[pixel * 3 + 1] = in4[pixel * 4 + 1];
    out3[pixel * 3 + 2] = in4[pixel * 4 + 2];
  }
}

void write_jpeg(uint8_t *buffer, int width, int height, int out_components,
                int is_rgb) {
  struct jpeg_compress_struct cinfo_out;
  struct jpeg_error_mgr jerr;
  FILE *outfile;

  char *file_name[10];
  sprintf(&file_name, "out%c.jpeg", "RY"[is_rgb]);
  if ((outfile = fopen(file_name, "wb")) == NULL) {
    fprintf(stderr, "can't open %s\n", "out.jpeg");
    return 1;
  }

  cinfo_out.err = jpeg_std_error(&jerr);
  jpeg_create_compress(&cinfo_out);
  jpeg_stdio_dest(&cinfo_out, outfile);

  cinfo_out.image_width = width;
  cinfo_out.image_height = height;
  cinfo_out.input_components = out_components;
  if (is_rgb) {
    cinfo_out.in_color_space = JCS_RGB;
  }
  jpeg_set_defaults(&cinfo_out);
  jpeg_set_quality(&cinfo_out, 100, TRUE);

  jpeg_start_compress(&cinfo_out, TRUE);

  while (cinfo_out.next_scanline < cinfo_out.image_height) {
    JSAMPROW row_pointer[1];
    row_pointer[0] = &buffer[cinfo_out.next_scanline * width * out_components];
    jpeg_write_scanlines(&cinfo_out, row_pointer, 1);
  }

  jpeg_finish_compress(&cinfo_out);
  jpeg_destroy_compress(&cinfo_out);

  fclose(outfile);
}

int main() {
  struct jpeg_decompress_struct cinfo;
  struct jpeg_error_mgr jerr;
  FILE *infile;
  size_t row_stride, buffer_size, width, height;
  uint64_t start_time, end_time;

  if ((infile = fopen("in.jpeg", "rb")) == NULL) {
    fprintf(stderr, "can't open %s\n", "in.jpeg");
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
  buffer_size = row_stride * cinfo.output_height;
  width = row_stride;
  height = cinfo.output_height;

  // Allocate memory for one row
  JSAMPARRAY buffer = (*cinfo.mem->alloc_sarray)((j_common_ptr)&cinfo,
                                                 JPOOL_IMAGE, row_stride, 1);

  // Allocate memory for the whole image
  uint8_t *in_buffer = (uint8_t *)malloc(buffer_size);

  // Read the entire image
  while (cinfo.output_scanline < cinfo.output_height) {
    jpeg_read_scanlines(&cinfo, buffer, 1);
    memcpy(&in_buffer[(cinfo.output_scanline - 1) * row_stride], buffer[0],
           row_stride);
  }

  uint8_t *out_buffer_rgb2yuv_etalon = (uint8_t *)malloc(buffer_size);
  uint8_t *out_buffer_rgb2yuv = (uint8_t *)malloc(buffer_size);
  uint8_t *out_buffer_yuv2rgb_etalon = (uint8_t *)malloc(buffer_size);
  uint8_t *out_buffer_yuv2rgb = (uint8_t *)malloc(buffer_size);
  uint8_t *yuv4 = (uint8_t *)malloc(buffer_size / 3 * 4);

  memcpy(out_buffer_rgb2yuv_etalon, in_buffer, buffer_size);
  memcpy(out_buffer_rgb2yuv, in_buffer, buffer_size);

  ptrdiff_t offset = (width * (height / 5) + (width / 4));
  ptrdiff_t out_offset = (width * (height / 5 * 3) + (width / 4));

  // RGB2YUV
  c_RGB2YUV(in_buffer + offset, out_buffer_rgb2yuv_etalon + out_offset,
            width / 2 + 9, height / 2, width, -width);

  start_time = __rdtsc();
  YUV3toYUV4(in_buffer, yuv4, buffer_size / 3 * 4);
  RGB2YUV(in_buffer + offset, yuv4 + (out_offset / 3 * 4), width / 3 * 2 / 4 + 2,
          height / 2, width, -(width / 3 * 4));
  end_time = __rdtsc();

  YUV4toYUV3(yuv4, out_buffer_rgb2yuv, buffer_size / 3 * 4);

  printf("C RGB2YUV rdtsc time: %llu\n", (end_time - start_time) / 1000);
  print_solution_score(out_buffer_rgb2yuv_etalon, out_buffer_rgb2yuv,
                       row_stride, cinfo.output_height);

  memcpy(out_buffer_yuv2rgb_etalon, out_buffer_rgb2yuv_etalon, buffer_size);
  memcpy(out_buffer_yuv2rgb, out_buffer_rgb2yuv, buffer_size);
  YUV3toYUV4(out_buffer_rgb2yuv_etalon, yuv4, buffer_size / 3 * 4);

  // YUV2RGB
  c_YUV2RGB(out_buffer_rgb2yuv_etalon + offset,
            out_buffer_yuv2rgb_etalon + out_offset, width / 4 + 9, height / 4,
            width, -width);

  start_time = __rdtsc();
  YUV2RGB(yuv4 + (offset / 3 * 4), out_buffer_yuv2rgb + out_offset, width / 3 / 4 + 2,
          height / 4, width / 3 * 4, -width);
  end_time = __rdtsc();

  printf("C YUV2RGB rdtsc time: %llu\n", (end_time - start_time) / 1000);
  print_solution_score(out_buffer_yuv2rgb_etalon, out_buffer_yuv2rgb,
                       row_stride, cinfo.output_height);

  // Save images
  write_jpeg(out_buffer_rgb2yuv, cinfo.image_width, cinfo.image_height,
             cinfo.output_components, 0);
  write_jpeg(out_buffer_yuv2rgb, cinfo.image_width, cinfo.image_height,
             cinfo.output_components, 1);

  jpeg_finish_decompress(&cinfo);
  jpeg_destroy_decompress(&cinfo);

  fclose(infile);

  free(in_buffer);
  free(out_buffer_rgb2yuv_etalon);
  free(out_buffer_rgb2yuv);
  free(out_buffer_yuv2rgb_etalon);
  free(out_buffer_yuv2rgb);
  free(yuv4);

  return 0;
}
