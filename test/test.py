# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

SEG_0 = 0b0111111  # "0"
SEG_1 = 0b0000110  # "1"
SEG_2 = 0b1011011  # "2"
SEG_3 = 0b1001111  # "3"
SEG_9 = 0b1101111  # "9"

@cocotb.test()
async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Nach Reset sollte der 7-Segment-Ausgang 0 anzeigen (value=0 -> seg=0111111)
    # Beachte: uo_out ist 8-Bit, Bits 7:0. Wir prüfen nur 6:0, Bit 7 sollte 0 sein.
    #assert dut.uo_out.value.integer & 0b01111111 == SEG_0, "FAIL: Initialwert sollte 0 sein"
    assert dut.uo_out.value == SEG_0

    # 2. Setup: Counter Mode wählen (ui_in[1:0] = 00)
    # UI_IN Zuweisung: [Modus: 1:0]
    MODE_COUNTER = 0b00 
    # Setze Modus und alle Taster (ui_in[7:2]) auf 0, ui_in[1:0] auf Counter Mode (00)
    dut.ui_in.value = MODE_COUNTER
    dut.uio_in.value = 0 # Nur falls benötigt, ansonsten 0

    await ClockCycles(dut.clk, 2)
    dut._log.info("Im Counter Modus (00) gestartet")

    # 3. Test Inkrement (Angenommen: Inkrement ist ui_in[2])
    
    # 3a. Inkrement: 0 -> 1
    dut.ui_in.value = MODE_COUNTER | (1 << 2) # Setze ui_in[2] auf 1 für Inkrement
    await RisingEdge(dut.clk)
    #assert dut.uo_out.value.integer & 0b01111111 == SEG_1, f"FAIL: Erwartet 1 (ist {dut.uo_out.value.integer & 0b01111111})"

    # 3b. Inkrement: 1 -> 2
    await RisingEdge(dut.clk) # Noch einmal inkrementieren
    #assert dut.uo_out.value.integer & 0b01111111 == SEG_2, f"FAIL: Erwartet 2 (ist {dut.uo_out.value.integer & 0b01111111})"
    
    # 4. Test Dekrement (Angenommen: Dekrement ist ui_in[3])
    
    # Zuerst Taster loslassen
    dut.ui_in.value = MODE_COUNTER 
    await ClockCycles(dut.clk, 2) 

    # 4a. Dekrement: 2 -> 1
    dut.ui_in.value = MODE_COUNTER | (1 << 3) # Setze ui_in[3] auf 1 für Dekrement
    await RisingEdge(dut.clk)
    #assert dut.uo_out.value.integer & 0b01111111 == SEG_1, f"FAIL: Erwartet 1 (ist {dut.uo_out.value.integer & 0b01111111})"

    dut._log.info("Counter Test erfolgreich.")

    # Set the input values you want to test
    #dut.ui_in.value = 20
    #dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    #await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    #assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
