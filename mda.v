// Modified from:
// https://github.com/tinyfpga/TinyFPGA-A-Series/tree/master/template_a2
// https://tinyfpga.com/a-series-guide.html used as a basis.

module top
  ((* LOC="13" *)
   output wire led1,
   (* LOC="16" *)
   output wire intensity,
   (* LOC="17" *)
   output wire video,
   (* LOC="20" *)
   output wire hsync,
   (* LOC="21" *)
   output wire vsync
   );

   wire clk;
   OSCH #(.NOM_FREQ("16.63"))
   internal_oscillator_inst (.STDBY(1'b0),
                             .OSC(clk)
                             );

   // video structure constants
   // these values are not set in stone, taken from a parallax forum
   parameter hpixels = 882;     // horizontal pixels per line
   parameter vlines = 370;      // vertical lines per frame
   parameter hpulse = 135;      // hsync pulse length
   parameter vpulse = 16;       // vsync pulse length
   parameter hbp = 143;         // end of horizontal back porch
   parameter hfp = 864;         // beginning of horizontal front porch
   parameter vbp = 19;          // end of vertical back porch
   parameter vfp = 370;         // beginning of vertical front porch

   // registers for storing the horizontal & vertical counters
   reg [9:0] hc = 0;
   reg [9:0] vc = 0;

   assign hsync = (hc < hpulse) ? 1:0;
   assign vsync = (vc < vpulse) ? 0:1;
   assign led1 = 1;

   always @(posedge clk) begin
      // keep counting until the end of the line
      if (hc < hpixels - 1) begin
         hc <= hc + 1;
      end
      else begin
         // When we hit the end of the line, reset the horizontal
         // counter and increment the vertical counter.
         // If vertical counter is at the end of the frame, then
         // reset that one too.
         hc <= 0;
         if (vc < vlines - 1) begin
            vc <= vc + 1;
         end
         else begin
            vc <= 0;
         end
      end
   end

   always @(hc,vc) begin
      // first check if we're within active video range
      if (vc >= vbp && vc < vfp && hc >= hbp && hc < hfp) begin
         // checkerboard pattern (two intensities + black)
         intensity = hc[5] ^ vc[5];
         video = hc[3] ^ vc[3];
      end
      // we're outside active vertical range so display black
      else begin
         intensity = 0;
         video = 0;
      end
   end
endmodule
