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

btn_1 = 0b00000001    # button 1
btn_2 = 0b00000010    # button 2
btn_3 = 0b00000100    # button 3
btn_4 = 0b00001000    # button 4
btn_sw = 0b00010000    # button switch game
btn_off = 0b00000000    # disable button

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

    # After the reset the 7seg should show the number 0 (SEG_0 -> 0b0111111)
    assert dut.uo_out.value == SEG_0, f"FAIL: Test 1 expected 0b0111111"
    
    await ClockCycles(dut.clk, 2)

    # After two clock cycles the 7seg should still show the number 0
    assert dut.uo_out.value == SEG_0, f"FAIL: Test 2 expected 0b0111111"

    # 3. Test increment
    
    # increment: 0 -> 1
    dut.ui_in.value = btn_1
    await ClockCycles(dut.clk, 500010) # wait for debounce time
    assert dut.uo_out.value == SEG_1, f"FAIL: Test 3 expected 0b0000110"

    # disable btn, check if value is still the same
    dut.ui_in.value = btn_off
    await ClockCycles(dut.clk, 100) 
    assert dut.uo_out.value == SEG_1, f"FAIL: Test 4 expected 0b0000110"

    # increment: 1 -> 2
    dut.ui_in.value = btn_1
    await ClockCycles(dut.clk, 500010) # wait for debounce time
    assert dut.uo_out.value == SEG_2, f"FAIL: Test 5 expected 0b0000110"

    # disable btn, check if value is still the same
    dut.ui_in.value = btn_off
    await ClockCycles(dut.clk, 100) 
    assert dut.uo_out.value == SEG_2, f"FAIL: Test 6 expected 0b0000110"
    
    # 4. Test decrement
    
    # decrement: 2 -> 1
    dut.ui_in.value = btn_2
    await ClockCycles(dut.clk, 500010) # wait for debounce time
    assert dut.uo_out.value == SEG_1, f"FAIL: Test 7 expected 0b0000110"

    # disable btn, check if value is still the same
    dut.ui_in.value = btn_off
    await ClockCycles(dut.clk, 100) 
    assert dut.uo_out.value == SEG_1, f"FAIL: Test 8 expected 0b0000110"

    # decrement: 1 -> 0
    dut.ui_in.value = btn_2
    await ClockCycles(dut.clk, 500010) # wait for debounce time
    assert dut.uo_out.value == SEG_0, f"FAIL: Test 9 expected 0b0111111"

    # disable btn, check if value is still the same
    dut.ui_in.value = btn_off
    await ClockCycles(dut.clk, 100) 
    assert dut.uo_out.value == SEG_0, f"FAIL: Test 10 expected 0b0111111"

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
