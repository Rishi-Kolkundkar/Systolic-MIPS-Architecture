module sign_extend (
    input  wire [15:0] inst_imm,
    input wire zero_ext,
    input wire is_lui,
    output wire [31:0] sign_ext_imm
);
   
    assign sign_ext_imm = (is_lui)   ? {inst_imm, 16'b0} :(zero_ext) ? {16'b0, inst_imm} : {{16{inst_imm[15]}}, inst_imm};
endmodule