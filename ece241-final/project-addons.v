// Author: Tristan Seto
// Date: 2023-12-06
// Description: This files contains all the additional parts (add-ons) to my ECE 241 F final project
// that are not a part of the main functionality, but act as helpers to instantiate parts of the project.
// This includes rate divider modules and hex decoder modules.

// Rate Divider
module rate_divider
#(parameter CLOCK_FREQUENCY = 50000000) (input ClockIn, input Reset, output reg Enable);
    // may want to try do a half clock frequency to do a blinking light
    
    wire [31:0] highest;
    reg [31:0] countdown;
    assign highest = CLOCK_FREQUENCY - 1;

    always @ (posedge ClockIn)
        begin
            if(Reset || countdown == 32'b0) countdown <= highest;
            else countdown <= countdown - 1;
        end

    always @ (*)
    begin
        if(countdown != 32'b0) Enable <= 1'b0;
        else Enable <= 1'b1;
    end
    
endmodule


// Hex Decoder for the Countdown
module countdown_hex_decoder(Enable, c, dispR, dispL);
    // only counts values from 1 to 25; @ 0 it will display nothing
    input Enable;
    input [4:0] c;
    output reg [6:0] dispR, dispL;

    // If the # is greater than 25 (or 0), do not display any numbers
    always @ (*)
    begin
      if(!Enable || c > 6'd25) begin // Display will be blank if the input number is reset or is greater than 25
            dispR = 7'b1111111;
            dispL = 7'b1111111;
        end else begin
            // Else display the numbers counting down to zero

        // Right Hand Side (PoS active low, convert to active high)
        dispR[0] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|c[1]|c[0]) & (c[4]|~c[3]|c[2]|~c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|c[0]) & (~c[4]|c[3]|~c[2]|c[1]|~c[0]) & (~c[4]|~c[3]|c[2]|c[1]|c[0]));
        dispR[1] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|~c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|~c[1]|c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|c[2]|c[1]|c[0]) & (~c[4]|~c[3]|c[2]|c[1]|~c[0]));
        dispR[2] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|c[2]|~c[1]|c[0]) & (c[4]|~c[3]|~c[2]|c[1]|c[0]) & (~c[4]|c[3]|~c[2]|~c[1]|c[0]));
        dispR[3] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|c[1]|c[0]) & (c[4]|~c[3]|c[2]|~c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|c[0]) & (~c[4]|c[3]|~c[2]|c[1]|~c[0]) & (~c[4]|~c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|c[2]|c[1]|~c[0]));
        dispR[4] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|c[1]|c[0]) & (c[4]|~c[3]|c[2]|~c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|c[0]) & (~c[4]|c[3]|~c[2]|c[1]|~c[0]) & (~c[4]|~c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|~c[3]|c[2]|c[1]|~c[0]) & (c[4]|c[3]|c[2]|~c[1]|~c[0]) & (c[4]|~c[3]|c[2]|c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|c[1]|~c[0]) & (~c[4]|c[3]|c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|~c[2]|~c[1]|~c[0]));
        dispR[5] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|~c[3]|c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|~c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|c[3]|c[2]|~c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|c[1]|~c[0]) & (~c[4]|c[3]|~c[2]|~c[1]|~c[0]) & (c[4]|c[3]|c[2]|~c[1]|c[0]) & (c[4]|~c[3]|~c[2]|c[1]|c[0]) & (~c[4]|c[3]|~c[2]|~c[1]|c[0]));
        dispR[6] = ~((c[4]|c[3]|c[2]|c[1]|c[0]) & (c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|~c[3]|c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|~c[2]|c[1]|~c[0]) & (c[4]|c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|c[2]|c[1]|~c[0]) & (c[4]|~c[3]|c[2]|~c[1]|c[0]) & (~c[4]|c[3]|~c[2]|c[1]|c[0]));

        // Left Hand Side (PoS active high)
        dispL[0] = ((~c[4]|c[3]|~c[2]|c[1]|c[0]) & (~c[4]|c[3]|~c[2]|c[1]|~c[0]) & (~c[4]|c[3]|~c[2]|~c[1]|c[0]) & (~c[4]|c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|~c[3]|c[2]|c[1]|c[0]) & (~c[4]|~c[3]|c[2]|c[1]|~c[0]));
        dispL[2] = ((c[4]|~c[3]|c[2]|~c[1]|c[0]) & (c[4]|~c[3]|c[2]|~c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|c[1]|c[0]) & (c[4]|~c[3]|~c[2]|c[1]|~c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|c[0]) & (c[4]|~c[3]|~c[2]|~c[1]|~c[0]) & (~c[4]|c[3]|c[2]|c[1]|c[0]) & (~c[4]|c[3]|c[2]|c[1]|~c[0]) & (~c[4]|c[3]|c[2]|~c[1]|c[0]) & (~c[4]|c[3]|c[2]|~c[1]|~c[0]));
        dispL[1] = dispL[0] & dispL[2];
        dispL[3] = dispL[0];
        dispL[4] = dispL[0];
        dispL[5] = 1'b1;
        dispL[6] = dispL[0];

        end
    end
endmodule

// Hex Decoder for the Colours:
module colour_hex_decoder(c, display);
    input [2:0] c;
    output [6:0] display;

    assign display[0] = (c[2]&c[1]&c[0]) | (c[2]&c[1]&~c[0]) | (~c[2]&c[1]&c[0]);
    assign display[1] = (~c[2]&c[1]&~c[0]) | (~c[2]&~c[1]&c[0]) | (c[2]&c[1]&c[0]);
    assign display[2] = (c[2]&~c[1]&c[0]) | (c[2]&c[1]&c[0]);
    assign display[3] = (~c[2]&~c[1]&~c[0]) | (c[2]&c[1]&~c[0]) | (~c[2]&c[1]&c[0]) | (c[2]&c[1]&c[0]);
    assign display[4] = ~(c[2]&~c[1]&c[0]);
    assign display[5] = ~((~c[2]&c[1]&~c[0]) | (~c[2]&c[1]&c[0]));
    assign display[6] = (~c[2]&~c[1]&~c[0]) | (c[2]&c[1]&~c[0]) | (c[2]&c[1]&c[0]);

  // As the design is common anode, the colour mappings are as follows:
  // RED:     FF0000 (255-RGB) = 100 (1-RGB) = "3" (011)
  // YELLOW:  FFFF00 (255-RGB) = 110 (1-RGB) = "1" (001)
  // GREEN:   00FF00 (255-RGB) = 010 (1-RGB) = "5" (101)
endmodule
