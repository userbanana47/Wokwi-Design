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

module button_sync(
	input wire clk,
	input wire async_sig,
	output reg sync_sig
);
	reg [1:0] reg_sig;
	
	always @(posedge clk) begin
		reg_sig[0] <= async_sig;
		reg_sig[1] <= reg_sig[0];
		sync_sig <= reg_sig[1];
	end
endmodule
