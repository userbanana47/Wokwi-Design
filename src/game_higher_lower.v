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

module game_higher_lower(
    input  wire clk,
    input  wire reset,
    input  wire btn_higher,
    input  wire btn_lower,
    output reg  [3:0] value
);
    wire [3:0] rnd;
    random_digit rng (
        .clk(clk),
        .reset(reset),
        .rnd(rnd)
    );
	
    // FSM
    reg [1:0] fsm_state, next_fsm_state;
    localparam INIT   = 2'b00,
               CHECK  = 2'b01,
               UPDATE = 2'b10;

    reg [3:0] current_num, next_num;
	
    // Delay-Counter
    localparam COUNTER_LEN = 24;
    localparam DELAY_TIME = 10_000_000;//5_000
    reg [COUNTER_LEN-1:0] counter_val, next_counter_val;

    reg [3:0] next_value;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fsm_state    <= INIT;
            current_num  <= 4'd0;
            counter_val  <= 0;
            value        <= 4'd0;
        end else begin
            fsm_state    <= next_fsm_state;
            current_num  <= next_num;
            counter_val  <= next_counter_val;
            value        <= next_value;
        end
    end
	
    always @(*) begin
        next_fsm_state   = fsm_state;
        next_num         = current_num;
        next_counter_val = counter_val;
        next_value       = value;

        case (fsm_state)
            INIT: begin
				next_value     = rnd;
                next_num       = rnd;
                next_counter_val = 0;
                next_fsm_state = CHECK;
			end
			
			CHECK: begin
                next_value = current_num;
                next_counter_val = 0;

                if (btn_higher && !btn_lower) begin
                    next_value = (rnd > current_num) ? 4'd10 : 4'd11;
                    next_fsm_state = UPDATE;
                end else if (!btn_higher && btn_lower) begin
                    next_value = (rnd < current_num) ? 4'd10 : 4'd11;
                    next_fsm_state = UPDATE;
                end
            end
			
            UPDATE: begin
                if (counter_val >= DELAY_TIME) begin
                    next_fsm_state   = CHECK;
                    next_counter_val = 0;
					next_num = rnd;
                end else begin
                    next_counter_val = counter_val + 1;
                end
            end
			
            default: begin
                next_fsm_state = INIT;
            end
        endcase
    end
endmodule
