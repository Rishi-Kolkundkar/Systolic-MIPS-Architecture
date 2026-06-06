module ex_stage (
    input  wire [31:0] rd1_out,
    input  wire [31:0] rd2_out,
    input  wire [31:0] imm_ext_out,
    input  wire [31:0] pc_inc_out,
    input  wire [4:0]  rt_out,
    input  wire [4:0]  rd_out,
    input  wire [5:0]  funct_out,
    
    input  wire [31:0] alu_result_m, 
    input  wire [31:0] result_w,    
    
    input  wire [1:0]  ForwardAE,
    input  wire [1:0]  ForwardBE,

    input wire         alu_src_out,
    input wire         reg_dst_out,
    input wire [1:0]   alu_op_out,
    input wire         branch_e,        

    //branch predictor inputs
    input wire         pred_taken_e,
    input wire [31:0]  pred_trgt_e,
    input wire [31:0]  pc_curr_e,

    output wire [31:0] alu_result,
    output wire [31:0] write_data_ex, 
    output wire [31:0] pc_branch_ex,
    output wire [4:0]  write_reg_ex,
    output wire        zero_ex,

    // branch predictor outputs
    output wire        mispred_flsh,
    output wire [31:0] correct_nxt_pc,
    output wire        ex_update_en,
    output wire        ex_brnch_tkn 
);
    wire [31:0] src_a_fwd;
    wire [31:0] src_b_fwd;
    wire [31:0] src_b_alu;
    wire [2:0]  alu_ctrl_final;

    mux_2_to_1 #(.WIDTH(5)) dest_reg_mux (
        .In0(rt_out), .In1(rd_out), .Sel(reg_dst_out), .Out(write_reg_ex)
    );

    alu_control ac_unit (
        .alu_op(alu_op_out), .funct(funct_out), .alu_ctrl(alu_ctrl_final)
    );

    mux_3_to_1 #(.WIDTH(32)) forward_a_mux (
        .In00(rd1_out), .In01(result_w), .In10(alu_result_m),
        .Sel(ForwardAE), .Out(src_a_fwd)
    );

    mux_3_to_1 #(.WIDTH(32)) forward_b_mux (
        .In00(rd2_out), .In01(result_w), .In10(alu_result_m),
        .Sel(ForwardBE), .Out(src_b_fwd)
    );

    mux_2_to_1 #(.WIDTH(32)) src_b_imm_mux (
        .In0(src_b_fwd),       
        .In1(imm_ext_out),
        .Sel(alu_src_out),
        .Out(src_b_alu)
    );

    
    alu_32bit main_alu (
        .a(src_a_fwd),         
        .b(src_b_alu),        
        .alu_control(alu_ctrl_final),
        .result(alu_result),
        .zero(zero_ex)
    );

    
    wire [31:0] imm_shifted = {imm_ext_out[29:0], 2'b00};
    adder_32bit branch_adder (
        .a(pc_inc_out), .b(imm_shifted), .cin(1'b0),
        .sum(pc_branch_ex), .cout()
    );

    assign write_data_ex = src_b_fwd;

    and(ex_brnch_tkn, branch_e, zero_ex);
    
    
    assign correct_nxt_pc = ex_brnch_tkn ? pc_branch_ex : pc_inc_out;

    wire [31:0] pred_nxt_pc = pred_taken_e ? pred_trgt_e : pc_inc_out;

    wire is_brnch = branch_e | pred_taken_e;

    assign mispred_flsh = is_brnch & (correct_nxt_pc != pred_nxt_pc);
    
    assign ex_update_en = branch_e;

endmodule