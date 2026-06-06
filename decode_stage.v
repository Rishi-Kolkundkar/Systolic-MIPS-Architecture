module decode_stage (
    input  wire        clk,
    input  wire        ar,
    
    input  wire [31:0] instr_d,
    input  wire [31:0] pc_plus4_d,
    
    //WB
    input  wire        reg_write_w,
    input  wire [4:0]  write_reg_w,
    input  wire [31:0] write_data_w,

    
    output wire [31:0] rd1_d,
    output wire [31:0] rd2_d,
    output wire [31:0] imm_ext_d,
    output wire [4:0]  rs_d,
    output wire [4:0]  rt_d,
    output wire [4:0]  rd_d,
    
    // Control Signals
    output wire        reg_write_d,
    output wire        reg_dst_d,
    output wire        alu_src_d,
    output wire        mem_to_reg_d,
    output wire        mem_read_d,
    output wire        mem_write_d,
    output wire        branch_d,
    output wire        jump_d,
    output wire [1:0]  alu_op_d
);

    
    assign rs_d = instr_d[25:21];
    assign rt_d = instr_d[20:16];
    assign rd_d = instr_d[15:11];
    wire zero_sgn, lui_sgn;

    
    control_unit cu (
        .Opcode(instr_d[31:26]),
        .RegWrite(reg_write_d),
        .RegDst(reg_dst_d),
        .ALUSrc(alu_src_d),
        .MemtoReg(mem_to_reg_d),
        .MemRead(mem_read_d),
        .MemWrite(mem_write_d),
        .Branch(branch_d),
        .Jump(jump_d),
        .ALUOp(alu_op_d),
        .zero_ext(zero_sgn),
        .is_lui(lui_sgn)
    );

    
    regfile rf (
        .clk(clk),
        .ar(ar),
        .reg_write(reg_write_w),
        .ra1(rs_d),
        .ra2(rt_d),
        .wa(write_reg_w),
        .wd(write_data_w),
        .rd1(rd1_d),
        .rd2(rd2_d)
    );

    
    sign_extend se (
        .inst_imm(instr_d[15:0]),
        .zero_ext(zero_sgn),
        .is_lui(lui_sgn),
        .sign_ext_imm(imm_ext_d)
    );

endmodule