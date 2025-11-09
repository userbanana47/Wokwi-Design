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

`include "button_debounce.v"
`include "button_sync.v"
`include "button_pulse.v"

module button(
    input wire clk, 
    input wire reset, 
    input wire btn,
    output wire pulse
);
    wire debounced;
    button_debounce debouncer(
        .clk(clk), 
        .reset(reset), 
        .btn(btn), 
        .debounce(debounced)
    );

    wire synced;
    button_sync synchronizer(
        .clk(clk), 
        .async_sig(debounced), 
        .sync_sig(synced)
    );

    button_pulse button_to_pulse(
        .clk(clk), 
        .reset(reset), 
        .btn(synced),
        .pulse(pulse)
    );
endmodule
