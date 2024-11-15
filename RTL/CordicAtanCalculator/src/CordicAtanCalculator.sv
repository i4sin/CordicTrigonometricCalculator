module CordicAtanCalculator #(
    parameter DATA_WIDTH,
    parameter NUM_ITERATIONS
) (
    input clk,
    input resetn,
    input [DATA_WIDTH-1:0] x,
    input [DATA_WIDTH-1:0] y,
    output logic valid,
    output logic [DATA_WIDTH-1:0] angle
);
    localparam real K_FACTOR = 0.607252935008881;

    logic [DATA_WIDTH-1:0] atan_table [15:0];

    logic [DATA_WIDTH-1:0] x_reg [NUM_ITERATIONS-1:0];
    logic [DATA_WIDTH-1:0] y_reg [NUM_ITERATIONS-1:0];
    logic [DATA_WIDTH-1:0] z_reg [NUM_ITERATIONS-1:0];

    assign atan_table[0] = 45 * (1 << 16);
    assign atan_table[1] = 26.565 * (1 << 16);
    assign atan_table[2] = 14.036243467 * (1 << 16);
    assign atan_table[3] = 7.125 * (1 << 16);
    assign atan_table[4] = 3.576 * (1 << 16);
    assign atan_table[5] = 1.790 * (1 << 16);
    assign atan_table[6] = 0.895 * (1 << 16);
    assign atan_table[7] = 0.447 * (1 << 16);
    assign atan_table[8] = 0.224 * (1 << 16);
    assign atan_table[9] = 0.112 * (1 << 16);
    assign atan_table[10] = 0.057 * (1 << 16);
    assign atan_table[11] = 0.028 * (1 << 16);
    assign atan_table[12] = 0.014 * (1 << 16);
    assign atan_table[13] = 0.007 * (1 << 16);
    assign atan_table[14] = 0.004 * (1 << 16);
    assign atan_table[15] = 0.002 * (1 << 16);

    assign x_reg[0] = x;
    assign y_reg[0] = y;
    assign z_reg[0] = 0;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            valid <= 0;
            angle <= 0;
        end else begin
            valid <= 0;
            angle <= 0;
            for (int i = 0; i < NUM_ITERATIONS; i++) begin
                if (z_reg[i] < 0) begin
                    x_reg[i + 1] <= x_reg[i] + (y_reg[i] >>> i);
                    y_reg[i + 1] <= y_reg[i] - (x_reg[i] >>> i);
                    z_reg[i + 1] <= z_reg[i] + atan_table[i];
                end else begin
                    x_reg[i + 1] <= x_reg[i] - (y_reg[i] >>> i);
                    y_reg[i + 1] <= y_reg[i] + (x_reg[i] >>> i);
                    z_reg[i + 1] <= z_reg[i] - atan_table[i];
                end
                if (i == NUM_ITERATIONS - 1) begin
                    valid <= 1;
                    angle <= z_reg[i] * K_FACTOR;
                end
            end
        end
    end
endmodule
