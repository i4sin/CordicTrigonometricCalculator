`timescale 1ns/1ps
`define PERIOD 20ns/1ps

import vunit_pkg::*;
`include "vunit_defines.svh"

module CordicAtanCalculator_tb();
    localparam TOTAL_WORDS_COUNT = 100000;

    typedef logic logic_array[$];

    logic_array seq_array;
    logic_array expected_detected_array;

    bit clk = 0;
    bit resetn = 0;
    initial forever #(`PERIOD/2) clk = ~clk;
    
    CordicAtanCalculator sequenceDetector(
        .clk(clk),
        .resetn(resetn),
        .seq(input_seq),
        .valid(input_valid),
        .detected(output_detected)
    );

    function logic_array generate_random_seq();
        logic_array random_seq;
        $display("random_seq:\n %p", random_seq);
        return random_seq;
    endfunction

    function automatic logic_array expect_detected_output(logic_array seq_array);
        logic_array expected_detected_array;
        $display("expected_detected_array:\n %p", expected_detected_array);
        return expected_detected_array;
    endfunction

    task drive_input(logic seq);
        input_seq <= seq;
        input_valid <= 1;
        @(posedge clk);
    endtask

    task check_output(logic current_expected_output);        
        assert (output_detected == current_expected_output) begin
            $display("seq: %h, detected: %h, expected_output: %h",
                        input_seq, output_detected, current_expected_output);
        end else $error("Operation wasn't done appropriately; output = %x, expected: %x", 
                                                                output_detected, current_expected_output);
    endtask

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            resetn <= 0;
            repeat(6) @(posedge clk);
            resetn <= 1;
            repeat(6) @(posedge clk);
        end

        `TEST_CASE("random_test_with_back_pressure") begin
            seq_array = generate_random_seq();
            expected_detected_array = expect_detected_output(seq_array);

            for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
                drive_input(seq_array.pop_front());
                check_output(expected_detected_array.pop_front());
            end
        end

        `TEST_CASE_CLEANUP begin
            $display("Making Cleanup....");
        end

        // `WATCHDOG(10000ns)
    end
endmodule
