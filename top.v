module mips_pipelined_top (
    input wire CLK,
    input wire AR
);

    //IF
    wire [31:0] pc_plus4_f, instr_f;
    
    //ID
    wire [31:0] instr_d, pc_plus4_d;
    wire [31:0] rd1_d, rd2_d, imm_ext_d;
    wire        reg_write_d, reg_dst_d, alu_src_d, mem_to_reg_d;
    wire        mem_read_d, mem_write_d, branch_d, jump_d;
    wire [1:0]  alu_op_d;
    wire [31:0] jump_target_d;
    
    //EX
    wire [31:0] rd1_e, rd2_e, imm_ext_e, pc_plus4_e;
    wire [4:0]  rs_e, rt_e, rd_e;
    wire [5:0]  funct_e;
    wire [1:0]  alu_op_e;
    wire        reg_write_e, reg_dst_e, alu_src_e, mem_to_reg_e;
    wire        mem_read_e, mem_write_e, branch_e;
    wire [31:0] alu_result_e, write_data_e;
    wire [4:0]  write_reg_e;
    wire        zero_e;
    wire [31:0] pc_branch_target_e;
    
    // MEM
    wire [31:0] alu_result_m, write_data_m, read_data_m;
    wire [4:0]  write_reg_m;
    wire        reg_write_m, mem_to_reg_m, mem_read_m, mem_write_m, zero_m;
    
    // WB
    wire [31:0] read_data_w, alu_result_w, result_w;
    wire [4:0]  write_reg_w;
    wire        mem_to_reg_w, reg_write_w;

    // Hazard
    wire [1:0]  ForwardAE, ForwardBE;
    wire        stall_hazard;
    wire        sgn_jump;
    
    // BP
    wire        predict_taken_f, predict_taken_d, predict_taken_e;
    wire [31:0] predict_target_f, predict_target_d, predict_target_e;
    wire [31:0] pc_current_f, pc_current_d, pc_current_e;
    wire        mispredict_flush;
    wire [31:0] correct_next_pc;
    wire        ex_update_en, ex_branch_taken;

    wire        stall_icache,stall_dcache; 
    wire        global_stall = stall_icache | stall_dcache;

    // Pipeline cntrl
    wire pc_en       = ~(stall_hazard|global_stall);       
    wire if_id_en    = ~(stall_hazard|global_stall); 

    wire pipe_en     = ~global_stall;

    wire id_ex_flush = (mispredict_flush | stall_hazard) & ~global_stall;
    wire if_id_flush = (mispredict_flush | sgn_jump) & ~global_stall; 

    wire [31:0] imem_addr, imem_data,dc_read_data,npu_read_data;
    wire        imem_read_en, imem_ready;

    wire [31:0] dmem_addr, dmem_write_data, dmem_read_data;
    wire        dmem_read_en, dmem_write_en, dmem_ready;

    wire is_npu;


    main_memory slow_ram (
        .clk(CLK), .ar(AR),
        
        .imem_read_en(imem_read_en), .imem_addr(imem_addr),
        .imem_data_out(imem_data), .imem_ready(imem_ready),
       
        .dmem_read_en(dmem_read_en), .dmem_write_en(dmem_write_en),
        .dmem_addr(dmem_addr), .dmem_data_in(dmem_write_data),
        .dmem_data_out(dmem_read_data), .dmem_ready(dmem_ready)
    );

    
    fetch_stage IF_stage (
        .clk(CLK), .ar(AR), .pc_en(pc_en),
        .ex_flush(mispredict_flush), .ex_correct_pc(correct_next_pc),
        .jump_d(sgn_jump), .jump_target_d(jump_target_d),
        .ex_update_en(ex_update_en), .ex_pc(pc_current_e), .ex_target(pc_branch_target_e), .ex_taken(ex_branch_taken),
        
        
        .stall_icache(stall_icache),
        .imem_addr(imem_addr), .imem_read_en(imem_read_en),
        .imem_data(imem_data), .imem_ready(imem_ready),
        
        .instr_f(instr_f), .pc_plus4_f(pc_plus4_f),
        .predict_taken_f(predict_taken_f), .predict_target_f(predict_target_f), .current_pc_f(pc_current_f)
    );

    pipeline_fetch_reg if_id_reg (
        .CLK(CLK), .AR(AR), .EN(if_id_en), .SR(if_id_flush),
        .instr_in(instr_f), .pc_plus4_in(pc_plus4_f),
        
         
        .pred_taken_in(predict_taken_f), .pred_target_in(predict_target_f), .pc_curr_in(pc_current_f),
        
        .instr_out(instr_d), .pc_inc_out(pc_plus4_d),
        
         
        .pred_taken_out(predict_taken_d), .pred_target_out(predict_target_d), .pc_curr_out(pc_current_d)
    );

    
    decode_stage ID_stage (
        .clk(CLK), .ar(AR), .instr_d(instr_d), .pc_plus4_d(pc_plus4_d),
        .reg_write_w(reg_write_w), .write_reg_w(write_reg_w), .write_data_w(result_w),
        .rd1_d(rd1_d), .rd2_d(rd2_d), .imm_ext_d(imm_ext_d),
        .rs_d(), .rt_d(), .rd_d(),
        .reg_write_d(reg_write_d), .reg_dst_d(reg_dst_d), .alu_src_d(alu_src_d),
        .mem_to_reg_d(mem_to_reg_d), .mem_read_d(mem_read_d), .mem_write_d(mem_write_d),
        .branch_d(branch_d), .jump_d(jump_d), .alu_op_d(alu_op_d)
    );

    hazard_detection_unit hdu (
        .mem_read_e(mem_read_e),        
        .rt_e(rt_e),                    
        .rs_d(instr_d[25:21]),          
        .rt_d(instr_d[20:16]),          
        .stall(stall_hazard)            
    );

    assign jump_target_d = {pc_plus4_d[31:28], instr_d[25:0], 2'b00};
    assign sgn_jump = jump_d & ~mispredict_flush;

    pipeline_dec id_ex_reg (
        .CLK(CLK), .AR(AR), .EN(pipe_en), .SR(id_ex_flush),
        
        .pc_inc_in(pc_plus4_d), .rd1_d(rd1_d), .rd2_d(rd2_d), .imm_ext_d(imm_ext_d),
        .rs_d(instr_d[25:21]), .rt_d(instr_d[20:16]), .rd_d(instr_d[15:11]), .funct_in(instr_d[5:0]),
        .reg_write_d(reg_write_d), .reg_dst_d(reg_dst_d), .alu_src_d(alu_src_d),
        .mem_to_reg_d(mem_to_reg_d), .mem_read_d(mem_read_d), .mem_write_d(mem_write_d),
        .branch_d(branch_d), .jump_d(jump_d), .alu_op_d(alu_op_d),
        
        
        .pred_taken_d(predict_taken_d), .pred_target_d(predict_target_d), .pc_curr_d(pc_current_d),

        .pc_inc_out(pc_plus4_e), .rd1_out(rd1_e), .rd2_out(rd2_e), .imm_ext_out(imm_ext_e),
        .rs_out(rs_e), .rt_out(rt_e), .rd_out(rd_e), .funct_out(funct_e),
        .reg_write_out(reg_write_e), .reg_dst_out(reg_dst_e), .alu_src_out(alu_src_e),
        .mem_to_reg_out(mem_to_reg_e), .mem_read_out(mem_read_e), .mem_write_out(mem_write_e),
        .branch_out(branch_e), .alu_op_out(alu_op_e),
        
        
        .pred_taken_e(predict_taken_e), .pred_target_e(predict_target_e), .pc_curr_e(pc_current_e)
    );

    
    forwarding_unit fwd_unit (
        .regwriteM(reg_write_m), .regwriteW(reg_write_w),
        .wregM(write_reg_m), .wregW(write_reg_w),
        .rsE(rs_e), .rtE(rt_e),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );

    ex_stage EX_logic (
        .rd1_out(rd1_e), .rd2_out(rd2_e), .imm_ext_out(imm_ext_e), .pc_inc_out(pc_plus4_e),
        .rt_out(rt_e), .rd_out(rd_e), .funct_out(funct_e),
        .alu_result_m(alu_result_m), 
        .result_w(result_w),         
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE),
        .alu_src_out(alu_src_e), .reg_dst_out(reg_dst_e), .alu_op_out(alu_op_e),
        
        .branch_e(branch_e), 
        
        .pred_taken_e(predict_taken_e), .pred_trgt_e(predict_target_e), .pc_curr_e(pc_current_e),
        .alu_result(alu_result_e), .write_data_ex(write_data_e),
        .pc_branch_ex(pc_branch_target_e), .write_reg_ex(write_reg_e), .zero_ex(zero_e),
        .mispred_flsh(mispredict_flush), .correct_nxt_pc(correct_next_pc),
        .ex_update_en(ex_update_en), .ex_brnch_tkn(ex_branch_taken)
    );

    pipeline_ex_mem ex_mem_reg (
        .CLK(CLK), .AR(AR), .EN(pipe_en), .SR(1'b0),
        .alu_result_in(alu_result_e), .write_data_in(write_data_e), .write_reg_in(write_reg_e),
        .zero_in(zero_e), .reg_write_in(reg_write_e), .mem_to_reg_in(mem_to_reg_e),
        .mem_read_in(mem_read_e), .mem_write_in(mem_write_e), .branch_in(branch_e),
        .alu_result_out(alu_result_m), .write_data_out(write_data_m), .write_reg_out(write_reg_m),
        .zero_out(zero_m), .reg_write_out(reg_write_m), .mem_to_reg_out(mem_to_reg_m),
        .mem_read_out(mem_read_m), .mem_write_out(mem_write_m), .branch_out()
    );

   

    assign is_npu = (alu_result_m[31:28]==4'h8) ? 1:0;
    wire dc_req_read, dc_req_write, npu_req_read, npu_req_write;
    

    assign dc_req_read= mem_read_m && (~is_npu);
    assign dc_req_write= mem_write_m  && (~is_npu);

    assign npu_req_read= mem_read_m && is_npu;
    assign npu_req_write=mem_write_m && is_npu; 

   dcache data_cache (
        .clk(CLK), .ar(AR),
        
        
        .cpu_addr(alu_result_m),
        .cpu_write_data(write_data_m),
        .cpu_req_read(dc_req_read),
        .cpu_req_write(dc_req_write),
        .cpu_read_data(dc_read_data),
        .stall_cpu(stall_dcache),
        
        
        .mem_addr(dmem_addr),
        .mem_write_data(dmem_write_data),
        .mem_read_en(dmem_read_en),
        .mem_write_en(dmem_write_en),
        .mem_read_data(dmem_read_data),
        .mem_ready(dmem_ready)
    );

    npu_top NPU (
        .CLK(CLK),
        .AR(AR),

        .mem_addr(alu_result_m),
        .mem_write_data(write_data_m),
        .mem_write_en(npu_req_write),
        .mem_read_en(npu_req_read),
        .mem_read_data(npu_read_data)
    );

    assign read_data_m= (is_npu) ? npu_read_data:dc_read_data;

    pipeline_mem_wb mem_wb_reg (
        .CLK(CLK), .AR(AR), .EN(pipe_en), .SR(1'b0),
        .read_data_in(read_data_m), .alu_result_in(alu_result_m), .write_reg_in(write_reg_m),
        .reg_write_in(reg_write_m), .mem_to_reg_in(mem_to_reg_m),
        .read_data_out(read_data_w), .alu_result_out(alu_result_w), .write_reg_out(write_reg_w),
        .reg_write_out(reg_write_w), .mem_to_reg_out(mem_to_reg_w)
    );

        
    mux_2_to_1 #(.WIDTH(32)) wb_mux (
        .In0(alu_result_w), .In1(read_data_w), .Sel(mem_to_reg_w), .Out(result_w)
    );

endmodule