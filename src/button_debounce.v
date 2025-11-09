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

//`timescale 1ns / 1ps

module button_debounce(
	input wire clk,
	input wire reset,
	input wire btn,
	output reg debounce
);
	// FSM
	reg [1:0] 	fsm_state, next_fsm_state;
	parameter 	IDLE = 2'b00,
				CHANGE = 2'b01;
				//STABLE = 2'b10;
	
	// counter
	parameter COUNTER_LEN = 19;
	parameter DEBOUNCE_VALUE = 5_000;//500_000;
	reg [COUNTER_LEN-1:0] counter_val, next_counter_val;
	
	reg next_debounce;
	
	always @(posedge clk or posedge reset) begin
		if (reset) begin
			fsm_state <= IDLE;
			counter_val <= 0;
			debounce <= 0;
		end else begin
			fsm_state <= next_fsm_state;
			counter_val <= next_counter_val;
			debounce <= next_debounce;
		end
	end
	
	always @(*) begin
		next_fsm_state = fsm_state;
		next_counter_val = counter_val;
		next_debounce = debounce;
		
		case (fsm_state)
			IDLE: begin
				if (btn != debounce) begin
					next_fsm_state = CHANGE;
					next_counter_val = 0;
				end
			end
			
			CHANGE: begin
				if (btn == debounce) begin
					next_fsm_state = IDLE;
				end else if (counter_val >= DEBOUNCE_VALUE) begin
					next_fsm_state = IDLE;
					next_debounce = btn;
				end else if (btn == 0) begin
					next_fsm_state = IDLE;
					next_debounce = 0;
				end else begin
					next_counter_val = counter_val + 1;
				end
			end
/* 			
			STABLE: begin
				next_fsm_state = IDLE;
			end */
			
			default: begin
				next_fsm_state = IDLE;
				next_debounce = 0;
			end
		endcase
	end
endmodule
