module mem_stage (
    input  wire clk,
    
    input  wire [31:0] alu_result_m,
    input  wire [31:0] write_data_m,
    input  wire        zero_m,
    
    
    input  wire        mem_write_m,
    input  wire        mem_read_m,
    input  wire        branch_m,

    
    output wire [31:0] read_data_m,
    output wire        pc_src_m        
);

    
    and gate_pc_src (pc_src_m, branch_m, zero_m);

    data_memory dmem (
        .Address(alu_result_m),
        .WriteData(write_data_m),
        .MemWrite(mem_write_m),
        .MemRead(mem_read_m),
        .CLK(clk),
        .ReadData(read_data_m)
    );

endmodule