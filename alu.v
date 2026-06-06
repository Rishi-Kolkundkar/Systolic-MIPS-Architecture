module FA (
    input wire Cin,
    input wire A,
    input wire B,
    output wire S,
    output wire Cout
);
    xor (S, Cin, A, B);

    wire a1,a2,a3;

    and (a1,A,B);
    and(a2,B,Cin);
    and (a3,A,Cin );

    or(Cout,a1,a2,a3);
endmodule

module adder_32bit (
    input wire [31:0] a,
    input wire [31:0] b,
    input wire cin,
    output wire [31:0] sum,
    output wire cout
);
    wire [32:0] c;

   
    assign c[0] = cin; 

    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : fa_loop
           
            FA fa_inst (
                .A(a[i]),
                .B(b[i]),
                .Cin(c[i]),
                .S(sum[i]),
                .Cout(c[i+1])
            );
        end
    endgenerate

    
    assign cout = c[32];
endmodule

module mux_4_to_1_32bit (
    input  wire [31:0] In0,
    input  wire [31:0] In1,
    input  wire [31:0] In2,
    input  wire [31:0] In3,
    input  wire [1:0]  Sel,
    output wire [31:0] Out
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : gen_mux4
            
            mux_4_to_1_1bit m4 (
                .In({In3[i], In2[i], In1[i], In0[i]}), 
                .Sel(Sel), 
                .Out(Out[i])
            );
        end
    endgenerate
endmodule

module zero_detector_32bit (
    input  wire [31:0] In,
    output wire        Zero
);

    wire [15:0] L1;
    wire [7:0]  L2;
    
    wire [3:0]  L3;
    
    wire [1:0]  L2_final;
    
    wire final_or;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : or_l1
            or (L1[i], In[2*i], In[2*i+1]);
        end
        for (i = 0; i < 8; i = i + 1) begin : or_l2
            or (L2[i], L1[2*i], L1[2*i+1]);
        end
        for (i = 0; i < 4; i = i + 1) begin : or_l3
            or (L3[i], L2[2*i], L2[2*i+1]);
        end
        for (i = 0; i < 2; i = i + 1) begin : or_l4
            or (L2_final[i], L3[2*i], L3[2*i+1]);
        end
    endgenerate

    
    or (final_or, L2_final[0], L2_final[1]);
    not (Zero, final_or);
endmodule

module alu_32bit (
    input  wire [31:0] a,
    input  wire [31:0] b,
    input  wire [2:0]  alu_control,
    output wire [31:0] result,
    output wire        zero
);
    wire [31:0] b_not, b_final, sum, and_res, or_res;
    wire cout;

    
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : bitwise
            and (and_res[i], a[i], b[i]);
            or  (or_res[i],  a[i], b[i]);
            not (b_not[i],   b[i]);
        end
    endgenerate

    
    mux_2_to_1 #(.WIDTH(32)) sub_mux (
        .In0(b),
        .In1(b_not),
        .Sel(alu_control[2]),
        .Out(b_final)
    );

    // ripple addder
    //(A + ~B + 1 = A - B)
    adder_32bit main_adder (
        .a(a),
        .b(b_final),
        .cin(alu_control[2]),
        .sum(sum),
        .cout(cout)
    );

    
    // 00: AND, 01: OR, 10: ADD/SUB, 11: SLT
    wire [31:0] slt_val;
    assign slt_val = {31'b0, sum[31]}; 

    mux_4_to_1_32bit res_mux (
        .In0(and_res), 
        .In1(or_res),
        .In2(sum),
        .In3(slt_val),
        .Sel(alu_control[1:0]),
        .Out(result)
    );

    
    zero_detector_32bit zero_unit (
        .In(result),
        .Zero(zero)
    );

endmodule