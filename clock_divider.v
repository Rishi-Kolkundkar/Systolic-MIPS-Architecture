module clock_divider (
    input  wire clk_50MHz,    // fast in CLK
    input  wire reset,       
    output reg  clk_1kHz      // slow out CLK
);

    // 16-bit counter
    reg [15:0] counter;

    always @(posedge clk_50MHz or posedge reset) begin
        if (reset) begin
            counter <= 16'd0;
            clk_1kHz <= 1'b0;
        end else begin
            
            if (counter == 16'd24999) begin
                counter <= 16'd0;
                clk_1kHz <= ~clk_1kHz;
            end else begin
                counter <= counter + 16'd1;
            end
        end
    end

endmodule
