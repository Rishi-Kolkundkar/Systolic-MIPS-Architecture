module control_unit (
    input  wire [5:0] Opcode,
    output wire       RegWrite,
    output wire       RegDst,
    output wire       ALUSrc,
    output wire       MemtoReg,
    output wire       MemRead,
    output wire       MemWrite,
    output wire       Branch,
    output wire       Jump,
    output wire [1:0] ALUOp,
    output wire zero_ext,
    output wire is_lui
    
);

   
    wire nO5, nO4, nO3, nO2, nO1, nO0;
    not (nO0, Opcode[0]);
    not (nO1, Opcode[1]);
    not (nO2, Opcode[2]);
    not (nO3, Opcode[3]);
    not (nO4, Opcode[4]);
    not (nO5, Opcode[5]);

    
    wire op_R, op_J, op_ADDI, op_BEQ, op_LW, op_SW, op_LUI, op_ORI;

    // R
    and (op_R, nO5, nO4, nO3, nO2, nO1, nO0);

    // Jump 
    and (op_J, nO5, nO4, nO3, nO2, Opcode[1], nO0);

    // ADDI
    and (op_ADDI, nO5, nO4, Opcode[3], nO2, nO1, nO0);

    // BEQ
    and (op_BEQ, nO5, nO4, nO3, Opcode[2], nO1, nO0);

    // LW
    and (op_LW, Opcode[5], nO4, nO3, nO2, Opcode[1], Opcode[0]);

    // SW
    and (op_SW, Opcode[5], nO4, Opcode[3], nO2, Opcode[1], Opcode[0]);
    //LUI
    and (op_LUI,nO5,nO4, Opcode[3],Opcode[2],Opcode[1],Opcode[0]);

    //ori
    and(op_ORI, nO5,nO4, Opcode[3],Opcode[2],nO1,Opcode[0]);

    
    wire regwrite_raw;
    
    or  (regwrite_raw, op_R, op_ADDI, op_LW, op_LUI, op_ORI);
    
    
    buf (RegDst, op_R);

    
    or  (ALUSrc, op_ADDI, op_LW, op_SW,op_LUI,op_ORI);

    buf (MemtoReg, op_LW);
    buf (MemRead,  op_LW);
    buf (MemWrite, op_SW);
    buf (Branch,   op_BEQ);
    buf (Jump,     op_J);
    buf(zero_ext, op_ORI);
    buf(is_lui,op_LUI);

    
    wire aluop0, aluop1;
    
    or(aluop0,op_BEQ,op_ORI);
    or(aluop1,op_R,op_ORI);   
    assign ALUOp = {aluop1, aluop0};

    
   
    wire any_match;
    or (any_match, op_R, op_J, op_ADDI, op_BEQ, op_LW, op_SW,op_LUI,op_ORI);
    and (RegWrite, regwrite_raw, any_match);

endmodule


module alu_control (
    input  wire [1:0] alu_op,
    input  wire [5:0] funct,
    output wire [2:0] alu_ctrl
);

    
    wire n_aluop0, n_aluop1;
    not (n_aluop0, alu_op[0]);
    not (n_aluop1, alu_op[1]);

    wire op_sub, op_rtype, op_ori;
    //  01 (BEQ)
    and (op_sub,   n_aluop1, alu_op[0]);
    
    //10 (R-Type)
    and (op_rtype, alu_op[1], n_aluop0);
    
    //11 (ORI)
    and (op_ori,   alu_op[1], alu_op[0]);


   
    
    wire is_r_sub;
    and (is_r_sub, op_rtype, funct[1]);
    or  (alu_ctrl[2], op_sub, is_r_sub);


    

    wire n_funct2, is_r_addsub;
    not (n_funct2, funct[2]);
    and (is_r_addsub, op_rtype, n_funct2);
    or  (alu_ctrl[1], n_aluop1, is_r_addsub);


   
    
    wire is_r_or, is_r_slt;
    and (is_r_or,  op_rtype, funct[0], funct[2]); 
    and (is_r_slt, op_rtype, funct[3], funct[1]); 
    or  (alu_ctrl[0], op_ori, is_r_or, is_r_slt);

endmodule