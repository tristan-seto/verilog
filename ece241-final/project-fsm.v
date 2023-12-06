// Author: Tristan Seto
// Date: 2023-12-06
// Description: This file contains the project's Finite State Machine (FSM) control path and data paths for both
// traffic light signals and pedestrian crossing signals. 
// The countdown/counter module that counts the time between states is also declared and defined in this file.


// Finite State Machine (FSM) control path
module FSM(
    input Clock,
    input Reset, Enable,
    input [2:0] input_signal,
    output reg green_hor, yellow_hor, red_hor,
    output reg green_ver, yellow_ver, red_ver,
    output reg walk_hor, countdown_hor, stop_hor,
    output reg walk_ver, countdown_ver, stop_ver
    );

    reg [3:0] current_state, next_state;

    localparam  STOP_HORIZONTAL           = 4'd0,
                SH_HOLD                   = 4'd1,
                GO_HORIZONTAL             = 4'd2,
                GH_HOLD                   = 4'd3,
                COUNTDOWN_HORIZONTAL      = 4'd4,
                CH_HOLD                   = 4'd5,
                YELLOW_HORIZONTAL         = 4'd6,
                YH_HOLD                   = 4'd7,     
                STOP_VERTICAL             = 4'd8,
                SV_HOLD                   = 4'd9,
                GO_VERTICAL               = 4'd10,
                GV_HOLD                   = 4'd11,
                COUNTDOWN_VERTICAL        = 4'd12,
                CV_HOLD                   = 4'd13,
                YELLOW_VERTICAL           = 4'd14,
                YV_HOLD                   = 4'd15;  

    // Next state logic

    // check after every posedge of Clock
    // States should only update when the Enable signal is sent from display_counter
    always @ (*) 
    if(Reset) next_state = SH_HOLD;
    else
    begin: state_table
    if(input_signal == 3'b000)      next_state = GV_HOLD;
    else if(input_signal == 3'b001) next_state = YV_HOLD;
    else if(input_signal == 3'b010) next_state = GH_HOLD;
    else if(input_signal == 3'b011) next_state = YH_HOLD;
    else if(input_signal == 3'b100) next_state = SV_HOLD;
    else if(input_signal == 3'b101) next_state = SH_HOLD;
    else begin
            case (current_state)
                STOP_HORIZONTAL: 
                    next_state = Enable ? STOP_HORIZONTAL : SH_HOLD;
                SH_HOLD: 
                    next_state = Enable ? GO_HORIZONTAL : SH_HOLD;
                GO_HORIZONTAL:
                    next_state = Enable ? GO_HORIZONTAL : GH_HOLD;
                GH_HOLD:
                    next_state = Enable ? COUNTDOWN_HORIZONTAL : GH_HOLD;
                COUNTDOWN_HORIZONTAL:
                    next_state = Enable ? COUNTDOWN_HORIZONTAL : CH_HOLD;
                CH_HOLD:
                    next_state = Enable ? YELLOW_HORIZONTAL : CH_HOLD;
                YELLOW_HORIZONTAL:
                    next_state = Enable ? YELLOW_HORIZONTAL : YH_HOLD;
                YH_HOLD:
                    next_state = Enable ? STOP_VERTICAL : YH_HOLD;                
                STOP_VERTICAL: 
                    next_state = Enable ? STOP_VERTICAL : SV_HOLD;
                SV_HOLD: 
                    next_state = Enable ? GO_VERTICAL : SV_HOLD;
                GO_VERTICAL:
                    next_state = Enable ? GO_VERTICAL : GV_HOLD;
                GV_HOLD:
                    next_state = Enable ? COUNTDOWN_VERTICAL : GV_HOLD;
                COUNTDOWN_VERTICAL:
                    next_state = Enable ? COUNTDOWN_VERTICAL : CV_HOLD;
                CV_HOLD:
                    next_state = Enable ? YELLOW_VERTICAL : CV_HOLD;
                YELLOW_VERTICAL:
                    next_state = Enable ? YELLOW_VERTICAL : YV_HOLD;
                YV_HOLD:
                    next_state = Enable ? STOP_HORIZONTAL : YV_HOLD;
            default:     next_state = SH_HOLD;
        endcase
    end
    end // state_table

    // Output logic aka all of our datapath control signals
    always @ (posedge Clock)
    begin: enable_signals
        // By default make all our signals 0:

        // Traffic Light Signals
        green_hor = 1'b0;
        yellow_hor = 1'b0;
        red_hor = 1'b0;
        // left_hor = 1'b0;
        green_ver = 1'b0;
        yellow_ver = 1'b0;
        red_ver = 1'b0;
        // left_ver = 1'b0;

        // Pedestrian Signals
        walk_hor = 1'b0;        // Walk LED (3) ON
        countdown_hor = 1'b0;   // Stop LED (2) FLASHING 1/2 RATE OF CLOCK, ENABLE COUNTODWN
        stop_hor = 1'b0;        // Stop LED (2) ON
        walk_ver = 1'b0;        // Walk LED (1) ON
        countdown_ver = 1'b0;   // Stop LED (0) FLASHING 1/2 RATE OF CLOCK, ENABLE COUNTDOWN
        stop_ver = 1'b0;        // Stop LED (0) ON
        // Stop LEDs (2) and 0 should be on by default

        case (current_state)
            STOP_HORIZONTAL: begin // all red signals should be ON
                // horizontal signals
                red_hor = 1'b1;
                stop_hor = 1'b1;
                // vertical signals
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            SH_HOLD: begin // all red signals should be ON
                // horizontal signals
                red_hor = 1'b1;
                stop_hor = 1'b1;
                // vertical signals
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            STOP_VERTICAL: begin // all red signals should be ON
                // horizontal signals
                red_hor = 1'b1;
                stop_hor = 1'b1;
                // vertical signals
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            SV_HOLD: begin // all red signals should be ON
                // horizontal signals
                red_hor = 1'b1;
                stop_hor = 1'b1;
                // vertical signals
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            // HORIZONTAL GO STATES
            GO_HORIZONTAL: begin
                // horizontal signals set to go
                green_hor = 1'b1;
                walk_hor = 1'b1;

                // vertical signals unchanged
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            GH_HOLD: begin
                // horizontal signals set to go
                green_hor = 1'b1;
                walk_hor = 1'b1;

                // vertical signals unchanged
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            COUNTDOWN_HORIZONTAL: begin
                green_hor = 1'b1; // traffic light remains green
                countdown_hor = 1'b1; // act as countdown enable

                // vertical signals unchanged
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            CH_HOLD: begin
                green_hor = 1'b1; // traffic light remains green
                countdown_hor = 1'b1; // act as countdown enable

                // vertical signals unchanged
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            YELLOW_HORIZONTAL: begin
                yellow_hor = 1'b1; // traffic light turns yellow
                stop_hor = 1'b1; // crossing should be complete

                // vertical signals unchanged
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            YH_HOLD: begin
                yellow_hor = 1'b1; // traffic light turns yellow
                stop_hor = 1'b1; // crossing should be complete

                // vertical signals unchanged
                red_ver = 1'b1;
                stop_ver = 1'b1;
            end

            // VERTICAL GO STATES
            GO_VERTICAL: begin
                // horizontal signals remain unchanged
                red_hor = 1'b1;
                stop_hor = 1'b1;

                // vertical signals set to go
                green_ver = 1'b1;
                walk_ver = 1'b1;
            end

            GV_HOLD: begin
                // horizontal signals remain unchanged
                red_hor = 1'b1;
                stop_hor = 1'b1;

                // vertical signals set to go
                green_ver = 1'b1;
                walk_ver = 1'b1;
            end

            COUNTDOWN_VERTICAL: begin
                // horizontal signals remain unchanged
                red_hor = 1'b1;
                stop_hor = 1'b1;

                green_ver = 1'b1; // traffic light remains green
                countdown_ver = 1'b1; // act as countdown enable
            end

            CV_HOLD: begin
                // horizontal signals remain unchanged
                red_hor = 1'b1;
                stop_hor = 1'b1;

                green_ver = 1'b1; // traffic light remains green
                countdown_ver = 1'b1; // act as countdown enable
            end

            YELLOW_VERTICAL: begin
                // horizontal signals remain unchanged
                red_hor = 1'b1;
                stop_hor = 1'b1;

                yellow_ver = 1'b1; // traffic light turns yellow
                stop_ver = 1'b1; // crossing should be complete
            end

            YV_HOLD: begin
                // horizontal signals remain unchanged
                red_hor = 1'b1;
                stop_hor = 1'b1;

                yellow_ver = 1'b1; // traffic light turns yellow
                stop_ver = 1'b1; // crossing should be complete
            end

        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always @ (posedge Clock)
    begin: state_FFs
        current_state <= next_state;
    end // state_FFS
endmodule



// Datapath for Traffic Light signals
module lights_datapath(
    input Clock,
    input Reset,
    input green_hor, yellow_hor, red_hor,
    input green_ver, yellow_ver, red_ver,
    output reg [2:0] colour_hor, colour_ver, out_signal

    );

    localparam  RED = 3'b100,
                YELLOW = 3'b110,
                GREEN = 3'b010;

    always @ (*) begin
        if(Reset) begin
            colour_hor <= RED;
            colour_ver <= RED;
        end

        if(red_hor) colour_hor <= RED;
        else if(green_hor) colour_hor <= GREEN;
        else if(yellow_hor) colour_hor <= YELLOW;

        if(red_ver) colour_ver <= RED;
        else if(green_ver) colour_ver <= GREEN;
        else if(yellow_ver) colour_ver <= YELLOW;

        // VGA SIGNALS
        if(green_ver) out_signal       <= 3'b000;
        else if(yellow_ver) out_signal <= 3'b001;
        else if(green_hor)  out_signal <= 3'b010;
        else if(yellow_hor) out_signal <= 3'b011;
        else out_signal <= 3'b100;
    end
endmodule


// Datapath for Pedestrian Crosswalk signals
module crosswalk_datapath
#(parameter CLOCK_FREQUENCY = 50000000)(
    input ClockIn,
    input Reset,
    input walk_hor, countdown_hor, stop_hor,
    input walk_ver, countdown_ver, stop_ver,
    output reg go_h, stop_h, go_v, stop_v

    );

    wire countOn;
    rate_divider #(CLOCK_FREQUENCY / 2) crosswalk_count(.ClockIn(ClockIn), .Reset(Reset), .Enable(countOn));

    always @ (posedge countOn) begin
        if(Reset) begin
            stop_h <= 1'b1;
            go_h <= 1'b0;
            stop_v <= 1'b1;
            go_v <= 1'b0;
        end
        
        // horizontal signals
        if(stop_hor) begin
            stop_h <= 1'b1;
            go_h <= 1'b0;
        end
        else if(walk_hor) begin
            stop_h <= 1'b0;
            go_h <= 1'b1;
        end
        else if(countdown_hor) begin
            stop_h <= !stop_h;
            go_h <= 1'b0;
        end

        // vertical signals
        if(stop_ver) begin
            stop_v <= 1'b1;
            go_v <= 1'b0;
        end
        else if(walk_ver) begin
            stop_v <= 1'b0;
            go_v <= 1'b1;
        end
        else if(countdown_ver) begin
            stop_v <= !stop_v;
            go_v <= 1'b0;
        end
    end
endmodule



// Display Counter
// This module sets the countdown time (from user input) and counts down the time for each state accordingly.

module display_counter(
        input Clock, Reset, Enable,
        input red, yellow, green, countdown,
        input [1:0] num_of_cars,
        output reg [4:0] CounterValue,
        output reg done
        );

    reg [5:0] highest;

    always @ (posedge Clock)
    begin
        
        // default done signal
        done <= 1'b0;
        
        // input highest value
        if(yellow) begin
            highest = 6'd3;
        end
        else if (green) begin
            case (num_of_cars)
                2'd0: highest = 5'd5;
                2'd1: highest = 5'd5;
                2'd2: highest = 5'd10;
                2'd3: highest = 5'd15;
            endcase
        end
        else if (countdown) begin
            case (num_of_cars)
                2'd0: highest = 5'd10;
                2'd1: highest = 5'd15;
                2'd2: highest = 5'd20;
                2'd3: highest = 5'd25;
            endcase
        end
        else highest = 6'd3; // default if necessary

        // actual counter
        if(Reset) CounterValue = highest;
        else if(Enable) begin 
            done <= 1'b0;
            if (CounterValue == 5'b0) CounterValue = highest;
            else CounterValue <= CounterValue - 1;
            
        end
        else if (CounterValue == 5'b0) begin
            done <= 1'b1;
        end
        else CounterValue <= CounterValue;

    end

endmodule
