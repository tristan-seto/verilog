// This file contains the top-level module for the complete project.

module main(
    input CLOCK_50,
    input [9:0] SW,
    input [3:0] KEY,
    inout PS2_CLK, PS2_DAT,
    output [3:0] LEDR,
    output [6:0] HEX3, HEX2, HEX1, HEX0,
    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
    output [7:0] VGA_R, VGA_G, VGA_B);

    parameter CLOCK_FREQUENCY = 50000000;

    wire std_clock; // standard clock will count per 1 second
    wire forced_reset;
    wire input_signal;
    wire Enable;
    wire green_hor, yellow_hor, red_hor;
    wire green_ver, yellow_ver, red_ver;
    wire walk_hor, countdown_hor, stop_hor;
    wire walk_ver, countdown_ver, stop_ver;
    wire [2:0] colour_hor, colour_ver;
    wire [2:0] vga_signal;
    wire [4:0] CounterValue;

    assign forced_reset = (input_signal != 3'b111);

    // Instatiate a clock that ticks every one second
    rate_divider #(CLOCK_FREQUENCY) standard_clock(.ClockIn(CLOCK_50), .Reset(~KEY[0]), .Enable(std_clock));

    // PS2
    PS2_Demo ps2(.CLOCK_50(CLOCK_50), .KEY(~KEY[0]), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .output_3bits(input_signal));

    // Call display counter module (this module will use a half-second clock for the blinkers)
    display_counter u0(
        .Clock(CLOCK_50), .Reset(~KEY[0] || forced_reset), .Enable(std_clock),
        .red(red_hor || red_ver), .yellow(yellow_hor || yellow_ver), .green(walk_hor || walk_ver), .countdown(countdown_hor || countdown_ver),
        .num_of_cars(SW[1:0]),
        //.Clk(half_clock), // comment out
        .CounterValue(CounterValue),        
        .done(Enable)//, .display(display)
        );
    
    FSM u1(.Clock(CLOCK_50), .Reset(~KEY[0]), .Enable(Enable),
        .input_signal(input_signal), // change when PS2 input comes in
        .green_hor(green_hor), .yellow_hor(yellow_hor), .red_hor(red_hor),
        .green_ver(green_ver), .yellow_ver(yellow_ver), .red_ver(red_ver),
        .walk_hor(walk_hor), .countdown_hor(countdown_hor), .stop_hor(stop_hor),
        .walk_ver(walk_ver), .countdown_ver(countdown_ver), .stop_ver(stop_ver)
    );

    lights_datapath u2(
        .Clock(CLOCK_50), .Reset(~KEY[0]),
        .green_hor(green_hor), .yellow_hor(yellow_hor), .red_hor(red_hor),
        .green_ver(green_ver), .yellow_ver(yellow_ver), .red_ver(red_ver),
        .colour_hor(colour_hor), .colour_ver(colour_ver), .out_signal(vga_signal)
    );

    crosswalk_datapath #(CLOCK_FREQUENCY) u3(
        .ClockIn(CLOCK_50), .Reset(~KEY[0]),
        .walk_hor(walk_hor), .countdown_hor(countdown_hor), .stop_hor(stop_hor),
        .walk_ver(walk_ver), .countdown_ver(countdown_ver), .stop_ver(stop_ver),
        .go_h(LEDR[3]), .stop_h(LEDR[2]), .go_v(LEDR[1]), .stop_v(LEDR[0])
    );

    countdown_hex_decoder hex(.Enable(countdown_hor || countdown_ver), .c(CounterValue), .dispR(HEX0), .dispL(HEX1));

    colour_hex_decoder light_horizontal(.c(colour_hor), .display(HEX3));
    colour_hex_decoder light_vertical(.c(colour_ver), .display(HEX2));

    fill vga_map(.CLOCK_50(CLOCK_50),
		.KEY(KEY),
		.my_3_bit_input(vga_signal),
		.VGA_CLK(VGA_CLK),   						//	VGA Clock
		.VGA_HS(VGA_HS),							//	VGA H_SYNC
		.VGA_VS(VGA_VS),							//	VGA V_SYNC
		.VGA_BLANK_N(VGA_BLANK_N),					//	VGA BLANK
		.VGA_SYNC_N(VGA_SYNC_N),					//	VGA SYNC
		.VGA_R(VGA_R),   						//	VGA Red[9:0]
		.VGA_G(VGA_G),	 						//	VGA Green[9:0]
		.VGA_B(VGA_B)   						//	VGA Blue[9:0]
	);

endmodule
