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

//`include "random_digit.v"

//`timescale 1ns / 1ps

module game_binary_quiz(
    input  wire clk,
    input  wire reset,
    input  wire btn1,
    input  wire btn2,
    input  wire btn3,
    input  wire btn4,
	input  wire btn5,
	input  wire btn6,
	input  wire btn7,
    output reg  [3:0] value
);
    wire [3:0] rnd;
    random_digit rng (
        .clk(clk),
        .reset(reset),
        .rnd(rnd)
    );

    // --- FSM ---
    reg [2:0] fsm_state, next_fsm_state;
    localparam WAIT        = 3'b000,	//wait for any button press to start
               SHOW_BIT1   = 3'b001,	//show Bit 1
               SHOW_BIT2   = 3'b010,	//show Bit 2
               //SHOW_BIT3   = 3'b011,	//show Bit 3
               QUIZ        = 3'b100,	//show '?' and wait for corresponding button press
               RESULT      = 3'b101;	//show correct or error
    
    reg [1:0] target_num, next_target_num;
    reg [3:0] next_value;

    // Delay-Counter
    localparam COUNTER_LEN = 24;
    localparam DELAY_TIME  = 10_000_000;//1s delay
    reg [COUNTER_LEN-1:0] counter_val, next_counter_val;

	reg [2:0] pressed_btn;
	reg [1:0] new_rnd_num;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fsm_state     <= WAIT;
            counter_val   <= 0;
            target_num    <= 2'd1;
            value         <= 4'd0;
        end else begin
            fsm_state     <= next_fsm_state;
            counter_val   <= next_counter_val;
            target_num    <= next_target_num;
            value         <= next_value;
        end
    end

    always @(*) begin
        next_fsm_state   = fsm_state;
        next_counter_val = counter_val;
        next_target_num  = target_num;
        next_value       = value;
        
		// safe pressed button
        //reg [2:0] pressed_btn;
        if (btn1) 		pressed_btn = 3'd1;
        else if (btn2) 	pressed_btn = 3'd2;
        else if (btn3) 	pressed_btn = 3'd3;
        else if (btn4) 	pressed_btn = 3'd4;
		//else if (btn5) 	pressed_btn = 3'd5;
		//else if (btn6) 	pressed_btn = 3'd6;
		//else if (btn7) 	pressed_btn = 3'd7;
		else 			pressed_btn = 3'd0;

		// new random number
        //reg [2:0] new_rnd_num;
		new_rnd_num = rnd[1:0];	//only use first 2 bits (0-3)
/* 		if (new_rnd_num == 3'd0) begin
			new_rnd_num = 3'd3;
		end */
		
		//next_target_num = new_rnd_num;

        case (fsm_state)
            WAIT: begin
                next_value = 4'd12; // 7seg off
                next_counter_val = 0;
                
                if (pressed_btn != 3'd0) begin // start with any button
                    next_target_num = new_rnd_num;
                    next_fsm_state = SHOW_BIT1;
                end
            end

            SHOW_BIT1, SHOW_BIT2: begin	//, SHOW_BIT3
                next_value = 4'd0; // Default: 0

                if (fsm_state == SHOW_BIT1) 	 next_value = target_num[1] ? 4'd1 : 4'd0;	//2^1
                else if (fsm_state == SHOW_BIT2) next_value = target_num[0] ? 4'd1 : 4'd0;	//2^0
				//if (fsm_state == SHOW_BIT1) 	 next_value = target_num[2] ? 4'd1 : 4'd0; 	// MSD (2^2)
                //else if (fsm_state == SHOW_BIT2) next_value = target_num[1] ? 4'd1 : 4'd0; 	// Middle (2^1)
                //else if (fsm_state == SHOW_BIT3) next_value = target_num[0] ? 4'd1 : 4'd0; 	// LSD (2^0)
                
                next_counter_val = counter_val + 1;
                
                if (counter_val >= DELAY_TIME) begin
                    next_counter_val = 0;
                    if (fsm_state == SHOW_BIT1) next_fsm_state = SHOW_BIT2;
                    //else if (fsm_state == SHOW_BIT2) next_fsm_state = SHOW_BIT3;
                    else next_fsm_state = QUIZ;
                end
            end
            
            QUIZ: begin
                next_value = 4'd13; // show '?'
                next_counter_val = 0;

                if (pressed_btn != 3'd0) begin
                    next_fsm_state = RESULT;
                    
                    if (pressed_btn[1:0] == target_num) begin
                        next_value = 4'd10; // correct
                    end else begin
                        next_value = 4'd11; // error
					end
                end
            end

            RESULT: begin
                next_counter_val = counter_val + 1;
                if (counter_val >= DELAY_TIME) begin
                    next_counter_val = 0;
                    next_fsm_state = WAIT;
                end
            end
            
            default: next_fsm_state = WAIT;
        endcase
    end
endmodule
