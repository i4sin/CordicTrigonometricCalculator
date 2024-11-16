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
    localparam logic [DATA_WIDTH-1:0] K_FACTOR = 32'b00000000000000001001101101110101;

    logic [DATA_WIDTH-1:0] atan_table [15:0];

    logic [DATA_WIDTH-1:0] x_reg [NUM_ITERATIONS-1:0];
    logic [DATA_WIDTH-1:0] y_reg [NUM_ITERATIONS-1:0];
    logic [DATA_WIDTH-1:0] z_reg [NUM_ITERATIONS-1:0];

    assign atan_table[0]  = 32'b00000000001011010000000000000000;
    assign atan_table[1]  = 32'b00000000000110101001000010100100;
    assign atan_table[2]  = 32'b00000000000011100000100101000111;
    assign atan_table[3]  = 32'b00000000000001110010000000000000;
    assign atan_table[4]  = 32'b00000000000000111001001101110101;
    assign atan_table[5]  = 32'b00000000000000011100101000111101;
    assign atan_table[6]  = 32'b00000000000000001110010100011111;
    assign atan_table[7]  = 32'b00000000000000000111001001101111;
    assign atan_table[8]  = 32'b00000000000000000011100101011000;
    assign atan_table[9]  = 32'b00000000000000000001110010101100;
    assign atan_table[10] = 32'b00000000000000000000111010011000;
    assign atan_table[11] = 32'b00000000000000000000011100101011;
    assign atan_table[12] = 32'b00000000000000000000001110010110;
    assign atan_table[13] = 32'b00000000000000000000000111001011;
    assign atan_table[14] = 32'b00000000000000000000000100000110;
    assign atan_table[15] = 32'b00000000000000000000000010000011;

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            valid <= 0;
            angle <= 0;
            x_reg[0] = x;
            y_reg[0] = y;
            z_reg[0] = 0;
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
