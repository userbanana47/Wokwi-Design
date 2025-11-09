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

module random_digit (
    input wire clk,
    input wire reset,
    output reg [3:0] rnd  //0–9
);
    reg [3:0] lfsr = 4'b1010;
	wire feedback = lfsr[3] ^ lfsr[2];
    
    reg [3:0] rnd_next; 
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 4'b1010;
            rnd  <= 4'd0;
        end else begin
            lfsr <= {lfsr[2:0], feedback};
            rnd  <= rnd_next;
        end
    end

    always @(*) begin
        if (lfsr[3:0] < 4'd10)
            rnd_next = lfsr;
        else
            rnd_next = lfsr - 4'd10;
    end
endmodule
