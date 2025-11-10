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

module sevenseg_driver(
    input  wire [3:0] value,
    output reg  [6:0] seg
);
    always @(*) begin
        case (value)
            0: 	seg = 7'b0111111; // 0
            1: 	seg = 7'b0000110; // 1
            2: 	seg = 7'b1011011; // 2
            3: 	seg = 7'b1001111; // 3
            4: 	seg = 7'b1100110; // 4
            5: 	seg = 7'b1101101; // 5
            6: 	seg = 7'b1111101; // 6
            7: 	seg = 7'b0000111; // 7
            8: 	seg = 7'b1111111; // 8
            9: 	seg = 7'b1101111; // 9
			10: seg = 7'b0111001; // Correct
			11: seg = 7'b1111001; // Error
			12: seg = 7'b0000000; //off
			13: seg = 7'b1001011; //?
            default: seg = 7'b0000000; // off
        endcase
    end
endmodule
