

module fetch_stage (
    input wire clk, ar, pc_en,        
    input wire        ex_flush,      
    input wire [31:0] ex_correct_pc, 
    input wire        jump_d,
    input wire [31:0] jump_target_d,
    input wire        ex_update_en,
    input wire [31:0] ex_pc, ex_target,
    input wire        ex_taken,

    
    output wire        stall_icache,
    output wire [31:0] imem_addr,
    output wire        imem_read_en,
    input  wire [31:0] imem_data,
    input  wire        imem_ready,

    output wire [31:0] instr_f, pc_plus4_f,
    output wire        predict_taken_f,
    output wire [31:0] predict_target_f, current_pc_f
);

    wire [31:0] pc_next, pc_current;
    wire [31:0] btb_target;
    wire        btb_taken;

    branch_predictor btb (
        .clk(clk), .ar(ar),
        .pc_fetch(pc_current), .predict_taken(btb_taken), .predict_target(btb_target),
        .update_en(ex_update_en), .pc_update(ex_pc), .target_update(ex_target), .branch_taken(ex_taken)
    );

    
    wire [31:0] pc_after_btb;
    mux_2_to_1 #(.WIDTH(32)) mux_predict (
        .In0(pc_plus4_f), .In1(btb_target), .Sel(btb_taken), .Out(pc_after_btb)
    );

    
    wire [31:0] pc_after_jump;
    mux_2_to_1 #(.WIDTH(32)) mux_jmp (
        .In0(pc_after_btb), .In1(jump_target_d), .Sel(jump_d), .Out(pc_after_jump)
    );

   
    mux_2_to_1 #(.WIDTH(32)) mux_flush (
        .In0(pc_after_jump), .In1(ex_correct_pc), .Sel(ex_flush), .Out(pc_next)
    );

    register_32bit pc_reg (
        .CLK(clk), .AR(ar), .EN(pc_en), .d(pc_next), .q(pc_current)
    );

    

    icache instruction_cache (
        .clk(clk), .ar(ar),
        .cpu_pc(pc_current),
        .cpu_instr(instr_f),
        .stall_cpu(stall_icache),    
        .mem_addr(imem_addr),        
        .mem_read_en(imem_read_en),  
        .mem_data(imem_data),        
        .mem_ready(imem_ready)
    );

    adder_32bit pc_adder (
        .a(pc_current), .b(32'd4), .cin(1'b0), .sum(pc_plus4_f), .cout() 
    );

    assign predict_taken_f  = btb_taken;
    assign predict_target_f = btb_target;
    assign current_pc_f     = pc_current;

endmodule