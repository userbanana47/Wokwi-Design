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

module game_dice(
    input  wire clk,
    input  wire reset,
    input  wire roll_btn,
    output reg  [3:0] value
);
    wire [3:0] rnd;
    random_digit rng (
        .clk(clk),
        .reset(reset),
        .rnd(rnd)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            value <= 4'd1; // start
        end else if (roll_btn) begin
            // limit to range 1-6
            value <= (rnd % 6) + 1;
        end
    end
endmodule
