`timescale 1ns/1ps
`define PERIOD 20ns/1ps

import vunit_pkg::*;
`include "vunit_defines.svh"

module CordicAtanCalculator_tb();
    localparam DATA_WIDTH = 32;
    localparam NUM_ITERATIONS = 16;
    localparam TOTAL_WORDS_COUNT = 100000;

    typedef logic [DATA_WIDTH-1:0] data_width_logic;
    typedef data_width_logic logic_sequence[$];
    typedef data_width_logic dual_logic_array[2];
    typedef dual_logic_array dual_logic_sequence[$];

    bit clk = 0;
    bit resetn = 0;
    initial forever #(`PERIOD/2) clk = ~clk;

    logic [DATA_WIDTH-1:0] input_x;
    logic [DATA_WIDTH-1:0] input_y;
    logic output_valid;
    logic [DATA_WIDTH-1:0] output_angle;

    dual_logic_sequence generated_sequence;
    logic_sequence expected_angles;
    
    CordicAtanCalculator #(
        .DATA_WIDTH(DATA_WIDTH),
        .NUM_ITERATIONS(NUM_ITERATIONS)
    ) cordic_atan_calculator(
        .clk(clk),
        .resetn(resetn),
        .x(input_x),
        .y(input_y),
        .valid(output_valid),
        .angle(output_angle)
    );

    function dual_logic_array generate_random_x_y_array();
        real x, y;
        data_width_logic x_logic, y_logic;
        dual_logic_array dual_logic_array;
        x = $urandom_range(0, 1000) / 1000;
        y = $sqrt(1 - x**2);
        x_logic = x * (1 << 16);
        y_logic = y * (1 << 16);
        dual_logic_array[0] = x_logic;
        dual_logic_array[1] = y_logic;
        $display("dual_logic_array:\n %p", dual_logic_array);
        return dual_logic_array;
    endfunction

    function dual_logic_sequence generate_random_x_y_sequence();
        dual_logic_sequence dual_logic_sequence;
        for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
            dual_logic_sequence.push_back(generate_random_x_y_array());
        end
    endfunction

    function data_width_logic expect_angle(dual_logic_array array);//todo
        data_width_logic expected_angle;
        $display("expected_angle:\n %p", expected_angle);
        return expected_angle;
    endfunction

    function logic_sequence expect_angles(dual_logic_sequence seq); //todo
        logic_sequence expected_angles;
        $display("expected_angles:\n %p", expected_angles);
        return expected_angles;
    endfunction

    task drive_input(dual_logic_array array);
        input_x <= array[0];
        input_y <= array[1];
        @(posedge clk);
    endtask

    task check_output(data_width_logic current_expected_angle);        
        assert (output_angle == current_expected_angle) begin
            $display("x: %h, y: %h, angle: %h, expected_angle: %h",
                        input_x, input_y, output_angle, current_expected_angle);
        end else $error("Operation wasn't done appropriately; output = %x, expected: %x", 
                                                                output_angle, current_expected_angle);
    endtask

    `TEST_SUITE begin
        `TEST_CASE_SETUP begin
            resetn <= 0;
            repeat(6) @(posedge clk);
            resetn <= 1;
            repeat(6) @(posedge clk);
        end

        `TEST_CASE("random_test") begin
            generated_sequence = generate_random_x_y_sequence();
            expected_angles = expect_angles(generated_sequence);

            for (int i = 0; i < TOTAL_WORDS_COUNT; i++) begin
                drive_input(generated_sequence.pop_front());
                check_output(expected_angles.pop_front());
            end
        end

        `TEST_CASE_CLEANUP begin
            $display("Making Cleanup....");
        end

        // `WATCHDOG(10000ns)
    end
endmodule
