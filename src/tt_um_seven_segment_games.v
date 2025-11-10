// Copyright 2025 Michael Schurz
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE−2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//`include "button.v"
//`include "button_pulse.v"
//`include "button_sync.v"
//`include "button_debounce.v"
//`include "sevenseg_driver.v"
//`include "game_dice.v"
//`include "game_counter.v"
//`include "game_higher_lower.v"
//`include "game_reaction.v"
//`include "random_digit.v"

module tt_um_seven_segment_games (
    input wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input wire ena,
    input wire clk,
    input wire rst_n
);
    // Reset-signal (active high)
    wire reset = !rst_n;

    // button-signals
	// ui_in[0] to ui_in[6] for games
    wire btn_raw_1 = ui_in[0];
    wire btn_raw_2 = ui_in[1];
    wire btn_raw_3 = ui_in[2];
    wire btn_raw_4 = ui_in[3];
	wire btn_raw_5 = ui_in[4];
	wire btn_raw_6 = ui_in[5];
	wire btn_raw_7 = ui_in[6];
	// ui_in[7] to switch games
	wire btn_raw_switch = ui_in[7]; 
    
    wire btn1_pulse;
    wire btn2_pulse;
    wire btn3_pulse;
    wire btn4_pulse;
	wire btn5_pulse;
	wire btn6_pulse;
	wire btn7_pulse;
    wire btn_switch_pulse;
    
    button btn_mod1 (.clk(clk), .reset(reset), .btn(btn_raw_1), .pulse(btn1_pulse));
    button btn_mod2 (.clk(clk), .reset(reset), .btn(btn_raw_2), .pulse(btn2_pulse));
    button btn_mod3 (.clk(clk), .reset(reset), .btn(btn_raw_3), .pulse(btn3_pulse));
    button btn_mod4 (.clk(clk), .reset(reset), .btn(btn_raw_4), .pulse(btn4_pulse));
	button btn_mod5 (.clk(clk), .reset(reset), .btn(btn_raw_4), .pulse(btn5_pulse));
	button btn_mod6 (.clk(clk), .reset(reset), .btn(btn_raw_4), .pulse(btn6_pulse));
	button btn_mod7 (.clk(clk), .reset(reset), .btn(btn_raw_4), .pulse(btn7_pulse));
    
    button btn_mod_switch (
        .clk(clk),
        .reset(reset),
        .btn(btn_raw_switch),
        .pulse(btn_switch_pulse)
    );
    
	// game selector (00=Counter, 01=Dice, 10=Higher/Lower, 11=quiz)
    reg [1:0] game_select_reg;
    
    // choose game
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            game_select_reg <= 2'b00; // start with counter
        end else if (btn_switch_pulse) begin
            game_select_reg <= game_select_reg + 1'b1;
//			if (game_select_reg == 2'b10) begin
//				game_select_reg <= 2'b00;
//			end else begin
//				game_select_reg <= game_select_reg + 1'b1;
//			end
        end
    end

    // game outputs
    wire [3:0] counter_value;
    wire [3:0] dice_value;
    wire [3:0] higher_lower_value;
	wire [3:0] quiz_value;
    
    reg [3:0] display_value;
	
	// button logic for active game

    wire is_counter_selected = (game_select_reg == 2'b00);
    wire is_dice_selected    = (game_select_reg == 2'b01);
    wire is_hl_selected      = (game_select_reg == 2'b10);
    wire is_quiz_selected	 = (game_select_reg == 2'b11);

    // 1. game_counter (btn1: inc, btn2: dec)
    wire counter_inc_btn = btn1_pulse && is_counter_selected;
    wire counter_dec_btn = btn2_pulse && is_counter_selected;
    
    // 2. game_dice (btn1: roll)
    wire dice_roll_btn = btn1_pulse && is_dice_selected;

    // 3. game_higher_lower (btn1: higher, btn2: lower)
    wire hl_higher_btn = btn1_pulse && is_hl_selected;
    wire hl_lower_btn  = btn2_pulse && is_hl_selected;

	// 4. game_reaction
    wire quiz_btn1 = btn1_pulse && is_quiz_selected;
    wire quiz_btn2 = btn2_pulse && is_quiz_selected;
    wire quiz_btn3 = btn3_pulse && is_quiz_selected;
    wire quiz_btn4 = btn4_pulse && is_quiz_selected;
	wire quiz_btn5 = btn5_pulse && is_quiz_selected;
	wire quiz_btn6 = btn6_pulse && is_quiz_selected;
	wire quiz_btn7 = btn7_pulse && is_quiz_selected;

    // 1. game_counter
    game_counter counter_inst (
        .clk(clk),
        .reset(reset),
        .inc_btn(counter_inc_btn),
        .dec_btn(counter_dec_btn),
        .value(counter_value)
    );

    // 2. game_dice
    game_dice dice_inst (
        .clk(clk),
        .reset(reset),
        .roll_btn(dice_roll_btn),
        .value(dice_value)
    );

    // 3. game_higher_lower
    game_higher_lower higher_lower_inst (
        .clk(clk),
        .reset(reset),
        .btn_higher(hl_higher_btn),
        .btn_lower(hl_lower_btn),
        .value(higher_lower_value)
    );

	// 4. game_binary_quiz
    game_binary_quiz quiz_inst (
        .clk(clk),
        .reset(reset),
        .btn1(quiz_btn1),
        .btn2(quiz_btn2),
        .btn3(quiz_btn3),
        .btn4(quiz_btn4),
		.btn5(quiz_btn5),
		.btn6(quiz_btn6),
		.btn7(quiz_btn7),
		.value(quiz_value)
    );

    // multiplexer for games
    always @(*) begin
        case (game_select_reg)
            2'b00: display_value = counter_value;        // 0: counter
            2'b01: display_value = dice_value;           // 1: dice
            2'b10: display_value = higher_lower_value;   // 2: higher/lower
            2'b11: display_value = quiz_value;       	 // 3: quiz
            default: display_value = 4'd12;              // Default: Off
        endcase
    end

    // 7seg driver
    wire [6:0] seven_seg_output;
    sevenseg_driver driver_inst (
        .value(display_value),
        .seg(seven_seg_output)
    );

    // pin allocation
    assign uo_out[6:0] = seven_seg_output;
    assign uo_out[7]   = 1'b0; 

	assign uio_oe  = 8'h00;
	assign uio_out = 8'h00; 
    
endmodule
