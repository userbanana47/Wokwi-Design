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

module game_reaction(
    input  wire clk,
    input  wire reset,
    input  wire btn1,
    input  wire btn2,
    input  wire btn3,
    input  wire btn4,
    output reg  [3:0] value
);
    wire [3:0] rnd;
    random_digit rng (
        .clk(clk),
        .reset(reset),
        .rnd(rnd)
    );

    reg [1:0] fsm_state, next_fsm_state;
    localparam WAIT    = 2'b00,
               SHOW    = 2'b01,
               RESULT  = 2'b10;

    reg [3:0] target_num, next_target_num;
    reg [3:0] next_value;

    // random delay
    localparam COUNTER_LEN = 24;
    reg [COUNTER_LEN-1:0] counter_val, next_counter_val;
	localparam DELAY_TIME = 10_000_000;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            fsm_state     <= WAIT;
            counter_val   <= 0;
            target_num    <= 0;
            value         <= 0;
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

        case (fsm_state)
            WAIT: begin
                next_value = 0;
                next_counter_val = counter_val + 1;

                // random delay time
                if (counter_val >= (DELAY_TIME + (rnd * 10_000_000))) begin
                    next_target_num = (rnd % 4) + 1;
                    next_counter_val = 0;
                    next_fsm_state = SHOW;
                end
            end

            SHOW: begin
                next_value = target_num;

                if (btn1 || btn2 || btn3 || btn4) begin
                    next_fsm_state = RESULT;
                    next_counter_val = 0;

                    // correct?
                    if ((btn1 && target_num == 1) ||
                        (btn2 && target_num == 2) ||
                        (btn3 && target_num == 3) ||
                        (btn4 && target_num == 4))
                        next_value = 4'd10; // right
                    else
                        next_value = 4'd11; // wrong
                end
            end

            RESULT: begin
                // show result
                next_counter_val = counter_val + 1;
                if (counter_val >= 10_000_000) begin
                    next_counter_val = 0;
                    next_fsm_state = WAIT;
                end
            end

            default: next_fsm_state = WAIT;
        endcase
    end
endmodule
