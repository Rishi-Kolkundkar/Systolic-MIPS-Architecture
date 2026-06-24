module display_controller (
    input  wire clk_50MHz,
    input  wire reset,
    input  wire [31:0] data_in,   
    output wire [6:0] seg_out,    
    output reg  [7:0] anode_select 
);

    wire clk_1kHz;
    reg [2:0] refresh_counter; 
    reg [3:0] current_hex_digit;

    
    clock_divider clk_div (
        .clk_50MHz(clk_50MHz),
        .reset(reset),
        .clk_1kHz(clk_1kHz)
    );

    
    always @(posedge clk_1kHz or posedge reset) begin
        if (reset)
            refresh_counter <= 3'd0;
        else
            refresh_counter <= refresh_counter + 3'd1;
    end

    

    always @(*) begin
        case(refresh_counter)
            3'd0: current_hex_digit = data_in[3:0];   
            3'd1: current_hex_digit = data_in[7:4];   
            3'd2: current_hex_digit = data_in[11:8];  
            3'd3: current_hex_digit = data_in[15:12]; 
            3'd4: current_hex_digit = data_in[19:16]; 
            3'd5: current_hex_digit = data_in[23:20]; 
            3'd6: current_hex_digit = data_in[27:24]; 
            3'd7: current_hex_digit = data_in[31:28]; 
            default: current_hex_digit = 4'h0;
        endcase
    end

    //Multiplexer
   
    always @(*) begin
        case(refresh_counter)
            3'd0: anode_select = 8'b11111110; 
            3'd1: anode_select = 8'b11111101; 
            3'd2: anode_select = 8'b11111011; 
            3'd3: anode_select = 8'b11110111; 
            3'd4: anode_select = 8'b11101111; 
            3'd5: anode_select = 8'b11011111; 
            3'd6: anode_select = 8'b10111111; 
            3'd7: anode_select = 8'b01111111; 
            default: anode_select = 8'b11111111;
        endcase
    end


    hex_decoder decoder (
        .hex_in(current_hex_digit),
        .seg_out(seg_out)
    );

endmodule