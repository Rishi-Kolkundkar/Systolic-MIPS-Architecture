module npu_top (
    input wire CLK,
    input wire AR,
    
    // from CPU
    input wire [31:0] mem_addr,         
    input wire [31:0] mem_write_data,   
    input wire mem_write_en,            
    input wire mem_read_en,             
    
    output reg [31:0] mem_read_data
);
   
    reg [31:0] mat_A_buff [0:3]; 
    reg [31:0] mat_B_buff [0:3];
    
    
    reg [31:0] output_buffer [0:15];

    
    reg [1:0] state; 
    // states
    localparam IDLE = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DRAIN = 2'b10;

    reg [4:0] clk_cycles;

    
    // in
    reg [7:0] r0_in, r1_in, r2_in, r3_in;
    reg [7:0] c0_in, c1_in, c2_in, c3_in;
    wire arr_drain;
    
    //out
    wire [31:0] d0_out, d1_out, d2_out, d3_out;
    integer i;
     


    always @(posedge CLK or posedge AR) begin
        if (AR) begin 
            state = IDLE;
            clk_cycles<=5'd0;
            
            for (i=0;i<4;i=i+1) begin 
                mat_A_buff[i]<=32'b0;
                mat_B_buff[i]<=32'b0;
            end
            for (i=0;i<16;i=i+1) begin
                output_buffer[i] <= 32'b0;
            end

        end

        else begin
            case(state)
                IDLE: begin
                    clk_cycles<=5'd0;
                    if(mem_write_en) begin
                        case(mem_addr)
                            32'h8000_0000: mat_A_buff[0]<=mem_write_data;
                            32'h8000_0004: mat_A_buff[1]<=mem_write_data;
                            32'h8000_0008: mat_A_buff[2]<=mem_write_data;
                            32'h8000_000C: mat_A_buff[3]<=mem_write_data;

                            32'h8000_0010: mat_B_buff[0]<=mem_write_data;
                            32'h8000_0014: mat_B_buff[1]<=mem_write_data;
                            32'h8000_0018: mat_B_buff[2]<=mem_write_data;
                            32'h8000_001C: mat_B_buff[3]<=mem_write_data;

                            32'h8000_0020: begin
                                if (mem_write_data == 32'd1) begin
                                    state <= COMPUTE;
                                end
                            end
                        endcase
                    end
                end

                COMPUTE: begin
                    clk_cycles<=clk_cycles+1'b1;
                    if(clk_cycles==5'd14) begin
                        clk_cycles<=0;
                        state<=DRAIN;
                    end
                end

                DRAIN: begin
                    clk_cycles<=clk_cycles+1'b1;

                    if(clk_cycles==5'd0) begin 
                        output_buffer[3] <= d0_out;
                        output_buffer[7] <= d1_out;
                        output_buffer[11] <= d2_out;
                        output_buffer[15] <= d3_out;
                    end

                    if(clk_cycles==5'd1) begin 
                        output_buffer[2] <= d0_out;
                        output_buffer[6] <= d1_out;
                        output_buffer[10] <= d2_out;
                        output_buffer[14] <= d3_out;
                    end

                    if(clk_cycles==5'd2) begin 
                        output_buffer[1] <= d0_out;
                        output_buffer[5] <= d1_out;
                        output_buffer[9] <= d2_out;
                        output_buffer[13] <= d3_out;
                    end

                    if(clk_cycles==5'd3) begin 
                        output_buffer[0] <= d0_out;
                        output_buffer[4] <= d1_out;
                        output_buffer[8] <= d2_out;
                        output_buffer[12] <= d3_out;
                    end
                    
                    if(clk_cycles==5'd4) begin
                        state <= IDLE;
                    end
                end

                
        
        endcase
        end
    end

    always @(*) begin
        mem_read_data = 32'b0; 
        
        if (mem_read_en) begin
            case(mem_addr)
                32'h8000_0030: mem_read_data=output_buffer[0];
                32'h8000_0034: mem_read_data=output_buffer[1];
                32'h8000_0038: mem_read_data=output_buffer[2];
                32'h8000_003C: mem_read_data=output_buffer[3];

                32'h8000_0040: mem_read_data=output_buffer[4];
                32'h8000_0044: mem_read_data=output_buffer[5];
                32'h8000_0048: mem_read_data=output_buffer[6];
                32'h8000_004C: mem_read_data=output_buffer[7];

                32'h8000_0050: mem_read_data=output_buffer[8];
                32'h8000_0054: mem_read_data=output_buffer[9];
                32'h8000_0058: mem_read_data=output_buffer[10];
                32'h8000_005C: mem_read_data=output_buffer[11];

                32'h8000_0060: mem_read_data=output_buffer[12];
                32'h8000_0064: mem_read_data=output_buffer[13];
                32'h8000_0068: mem_read_data=output_buffer[14];
                32'h8000_006C: mem_read_data=output_buffer[15];
                
                
                default: mem_read_data = 32'b0;
            endcase
        end
    end

    assign arr_drain= (state==DRAIN);

   
    always @(*) begin
        
        r0_in = 8'b0; r1_in = 8'b0; r2_in = 8'b0; r3_in = 8'b0;
        c0_in = 8'b0; c1_in = 8'b0; c2_in = 8'b0; c3_in = 8'b0;
        
        if (state == COMPUTE && clk_cycles < 5'd4) begin
            case (clk_cycles)
                5'd0: begin
                    
                    r0_in = mat_A_buff[0][7:0];
                    r1_in = mat_A_buff[1][7:0];
                    r2_in = mat_A_buff[2][7:0];
                    r3_in = mat_A_buff[3][7:0];

                    c0_in=mat_B_buff[0][7:0];
                    c1_in=mat_B_buff[1][7:0];
                    c2_in=mat_B_buff[2][7:0];
                    c3_in=mat_B_buff[3][7:0];
                    
                end
                5'd1: begin
                    
                    r0_in = mat_A_buff[0][15:8];
                    r1_in = mat_A_buff[1][15:8];
                    r2_in = mat_A_buff[2][15:8];
                    r3_in = mat_A_buff[3][15:8];

                    c0_in=mat_B_buff[0][15:8];
                    c1_in=mat_B_buff[1][15:8];
                    c2_in=mat_B_buff[2][15:8];
                    c3_in=mat_B_buff[3][15:8];
                    
                end
                5'd2: begin
                    
                    r0_in = mat_A_buff[0][23:16];
                    r1_in = mat_A_buff[1][23:16];
                    r2_in = mat_A_buff[2][23:16];
                    r3_in = mat_A_buff[3][23:16];

                    c0_in=mat_B_buff[0][23:16];
                    c1_in=mat_B_buff[1][23:16];
                    c2_in=mat_B_buff[2][23:16];
                    c3_in=mat_B_buff[3][23:16];
                end
                5'd3: begin
                    
                    r0_in = mat_A_buff[0][31:24];
                    r1_in = mat_A_buff[1][31:24];
                    r2_in = mat_A_buff[2][31:24];
                    r3_in = mat_A_buff[3][31:24];

                    c0_in=mat_B_buff[0][31:24];
                    c1_in=mat_B_buff[1][31:24];
                    c2_in=mat_B_buff[2][31:24];
                    c3_in=mat_B_buff[3][31:24];
                end
                default: begin
                    
                    r0_in = 8'd0;
                    r1_in = 8'd0;
                    r2_in = 8'd0;
                    r3_in = 8'd0;

                    c0_in=8'd0;
                    c1_in=8'd0;
                    c2_in=8'd0;
                    c3_in=8'd0;
                end
            endcase
        end
    end

    sys_array core (
        .CLK(CLK),
        .AR(AR),
        .drain(arr_drain),
        .r0(r0_in), .r1(r1_in), .r2(r2_in), .r3(r3_in),
        .c0(c0_in), .c1(c1_in), .c2(c2_in), .c3(c3_in),
        .d0(d0_out), .d1(d1_out), .d2(d2_out), .d3(d3_out)
    );






endmodule