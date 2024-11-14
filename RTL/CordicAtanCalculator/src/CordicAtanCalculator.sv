module CordicAtanCalculator(
    input clk,
    input resetn,

    input degree,
    input valid,
    output reg detected
);

    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) begin
        end else begin
        end
    end

    always_comb begin

    end
endmodule
