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

module game_counter(
    input  wire clk,
    input  wire reset,        // global reset
    input  wire inc_btn,      // increment pulse (+1)
    input  wire dec_btn,      // decrement pulse (-1)
    output reg  [3:0] value   // current number (0–9)
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            value <= 4'd0;
        end else begin
            if (inc_btn && !dec_btn) begin
                // +1 mit wrap-around
                if (value == 4'd9)
                    value <= 4'd0;
                else
                    value <= value + 1;
            end else if (dec_btn && !inc_btn) begin
                // -1 mit wrap-around
                if (value == 4'd0)
                    value <= 4'd9;
                else
                    value <= value - 1;
            end
        end
    end
endmodule
