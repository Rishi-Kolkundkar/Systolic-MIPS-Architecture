module pipeline_fetch_reg (
    input wire [31:0] instr_in,
    input wire [31:0] pc_plus4_in,
    input wire CLK,
    input wire SR,
    input wire EN,
    input wire AR,
    //for BP
    input wire pred_taken_in,
    input wire [31:0] pred_target_in,
    input wire [31:0] pc_curr_in,

    output wire [31:0] instr_out,
    output wire [31:0] pc_inc_out,
    output wire pred_taken_out,
    output wire [31:0] pred_target_out,
    output wire [31:0] pc_curr_out
    
);

    register_32bit_sr inst_out (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(instr_in),
        .q(instr_out)
    );

    register_32bit_sr pc_out (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(pc_plus4_in),
        .q(pc_inc_out)
    );

    register_32bit_sr pc_curr_out1 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(pc_curr_in),
        .q(pc_curr_out)
    );

    register_32bit_sr pred_tgt (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(pred_target_in),
        .q(pred_target_out)
    );

    d_flip_flop_sr pred_tkn (
        .CLK(CLK),
        .AR(AR),
        .D(pred_taken_in),
        .Q(pred_taken_out),
        .EN(EN),
        .SR(SR)
    );

endmodule

module pipeline_dec (
    input wire CLK,
    input wire SR,
    input wire EN,
    input wire AR,

    input wire [31:0] pc_inc_in,

    input wire [31:0] rd1_d,
    input wire [31:0] rd2_d,
    input wire [31:0] imm_ext_d,
    input wire [4:0]  rs_d,
    input wire [4:0]  rt_d,
    input wire [4:0]  rd_d,
    
    // Control Signals
    input wire        reg_write_d,
    input wire        reg_dst_d,
    input wire        alu_src_d,
    input wire        mem_to_reg_d,
    input wire        mem_read_d,
    input wire        mem_write_d,
    input wire        branch_d,
    input wire        jump_d,
    input wire [1:0]  alu_op_d,
    input wire [5:0] funct_in,

    //BP
    input wire        pred_taken_d,
    input wire [31:0] pred_target_d,
    input wire [31:0] pc_curr_d,

    output wire [31:0] rd1_out,
    output wire [31:0] rd2_out,
    output wire [31:0] imm_ext_out,
    output wire [4:0]  rs_out,
    output wire [4:0]  rt_out,
    output wire [4:0]  rd_out,
    
    // Control Signals
    output wire        reg_write_out,
    output wire        reg_dst_out,
    output wire        alu_src_out,
    output wire        mem_to_reg_out,
    output wire        mem_read_out,
    output wire        mem_write_out,
    output wire        branch_out,
    output wire        jump_out,
    output wire [1:0]  alu_op_out,
    output wire [5:0] funct_out,

    output wire [31:0] pc_inc_out,
    output wire        pred_taken_e,
    output wire [31:0] pred_target_e,
    output wire [31:0] pc_curr_e

);

    register_32bit_sr rd1_out1 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(rd1_d),
        .q(rd1_out)
    );

    register_32bit_sr rd2_out2 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(rd2_d),
        .q(rd2_out)
    );

    register_32bit_sr imm_out (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(imm_ext_d),
        .q(imm_ext_out)
    );

    register_32bit_sr pc_out3 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(pc_inc_in),
        .q(pc_inc_out)
    );

    register_5bit_sr rs_out2 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(rs_d),
        .q(rs_out)
    );

    register_5bit_sr rt_out2 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(rt_d),
        .q(rt_out)
    );

    register_5bit_sr rd_out2 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(rd_d),
        .q(rd_out)
    );

    wire [4:0] cluster1 = {reg_write_d,reg_dst_d,alu_src_d,mem_to_reg_d,mem_read_d};
    wire[4:0] cluster2 = {mem_write_d,branch_d,jump_d,alu_op_d};

    register_5bit_sr cntrl_out1 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(cluster1),
        .q({reg_write_out,reg_dst_out,alu_src_out,mem_to_reg_out,mem_read_out})
    );

    register_5bit_sr cntrl_out2 (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(cluster2),
        .q({mem_write_out,branch_out,jump_out,alu_op_out})
    );

    register_6bit_sr funct (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(funct_in),
        .q(funct_out)
    );

    d_flip_flop_sr    pred_tkn (
        .CLK(CLK), .AR(AR), .SR(SR), .EN(EN), 
        .D(pred_taken_d), .Q(pred_taken_e)
        );

    register_32bit_sr pred_trgt (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(pred_target_d),
        .q(pred_target_e)
    );

    register_32bit_sr pc_curr (
        .CLK(CLK),
        .AR(AR),
        .SR(SR),
        .EN(EN),
        .d(pc_curr_d),
        .q(pc_curr_e)
    );




endmodule


module pipeline_ex_mem (
    input wire CLK, AR, EN, SR,

    // from EX
    input wire [31:0] alu_result_in,
    input wire [31:0] write_data_in, // From rd2
    input wire [4:0]  write_reg_in,
    input wire        zero_in,

    // Control Signals
    input wire        reg_write_in,
    input wire        mem_to_reg_in,
    input wire        mem_read_in,
    input wire        mem_write_in,
    input wire        branch_in,

    
    output wire [31:0] alu_result_out,
    output wire [31:0] write_data_out,
    output wire [4:0]  write_reg_out,
    output wire        zero_out,
    output wire        reg_write_out,
    output wire        mem_to_reg_out,
    output wire        mem_read_out,
    output wire        mem_write_out,
    output wire        branch_out
);
    
    register_32bit_sr reg_alu  (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .d(alu_result_in), .q(alu_result_out));
    register_32bit_sr reg_data (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .d(write_data_in), .q(write_data_out));
    
    
    register_5bit_sr  reg_wa   (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .d(write_reg_in),  .q(write_reg_out));
    d_flip_flop_sr    reg_zero (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .D(zero_in),       .Q(zero_out));

    
    wire [4:0] cluster_in  = {reg_write_in, mem_to_reg_in, mem_read_in, mem_write_in, branch_in};
    register_5bit_sr reg_ctrl (
        .CLK(CLK), .AR(AR), .SR(SR), .EN(EN),
        .d(cluster_in),
        .q({reg_write_out, mem_to_reg_out, mem_read_out, mem_write_out, branch_out})
    );
endmodule

module pipeline_mem_wb (
    input wire CLK, AR, EN, SR,

    
    input wire [31:0] read_data_in,
    input wire [31:0] alu_result_in,
    input wire [4:0]  write_reg_in,

     
    input wire        reg_write_in,
    input wire        mem_to_reg_in,

    
    output wire [31:0] read_data_out,
    output wire [31:0] alu_result_out,
    output wire [4:0]  write_reg_out,
    output wire        reg_write_out,
    output wire        mem_to_reg_out
);
    register_32bit_sr reg_rd   (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .d(read_data_in),  .q(read_data_out));
    register_32bit_sr reg_alu  (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .d(alu_result_in), .q(alu_result_out));
    register_5bit_sr  reg_wa   (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .d(write_reg_in),  .q(write_reg_out));

    
    wire [1:0] cluster_in = {reg_write_in, mem_to_reg_in};
    
    d_flip_flop_sr reg_rw (.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .D(cluster_in[1]), .Q(reg_write_out));
    d_flip_flop_sr reg_m2r(.CLK(CLK), .AR(AR), .SR(SR), .EN(EN), .D(cluster_in[0]), .Q(mem_to_reg_out));
endmodule