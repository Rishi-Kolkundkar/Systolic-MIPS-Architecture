module MUX_2 (
    input wire [1:0] A,
    input wire S,
    output wire Y
);
    wire ns0;
    not(ns0,S);


    wire r0,r1;

    and(r0,ns0,A[0]);
    and(r1,S,A[1]);
    

    or(Y,r0,r1);

endmodule

module mux_2_to_1 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] In0,
    input  wire [WIDTH-1:0] In1,
    input  wire             Sel,
    output wire [WIDTH-1:0] Out
);

    wire nSel;
    not u_not(nSel, Sel);

    genvar i;
    generate
        for (i=0; i<WIDTH; i=i+1) begin : gen_mux
            wire a, b;
            and u_and0(a, In0[i], nSel); 
            and u_and1(b, In1[i], Sel);  
            or  u_or(Out[i], a, b);      
        end
    endgenerate

endmodule

module mux_4_to_1_1bit (
    input wire [3:0] In,
    input wire [1:0] Sel,
    output wire Out
);
    wire m01, m23;

    
    mux_2_to_1 #(.WIDTH(1)) mux_low (
        .In0(In[0]), 
        .In1(In[1]), 
        .Sel(Sel[0]), 
        .Out(m01)
    );

    mux_2_to_1 #(.WIDTH(1)) mux_high (
        .In0(In[2]), 
        .In1(In[3]), 
        .Sel(Sel[0]), 
        .Out(m23)
    );

    
    mux_2_to_1 #(.WIDTH(1)) mux_final (
        .In0(m01), 
        .In1(m23), 
        .Sel(Sel[1]), 
        .Out(Out)
    );
endmodule

module mux_8_to_1_1bit (
    input wire [7:0] In,
    input wire [2:0] Sel,
    output wire Out
);
    wire m03, m47;

    
    mux_4_to_1_1bit mux_low_4 (
        .In(In[3:0]),
        .Sel(Sel[1:0]),
        .Out(m03)
    );

    mux_4_to_1_1bit mux_high_4 (
        .In(In[7:4]),
        .Sel(Sel[1:0]),
        .Out(m47)
    );

    
    mux_2_to_1 #(.WIDTH(1)) mux_final (
        .In0(m03),
        .In1(m47),
        .Sel(Sel[2]),
        .Out(Out)
    );
endmodule

module mux_32_to_1_1bit (
    input wire [31:0] In,
    input wire [4:0] Sel,
    output wire Out
);
    wire [3:0] intermediate;

    
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin : stage1
           
            mux_8_to_1_1bit m8 (
                .In(In[i*8 +: 8]), 
                .Sel(Sel[2:0]), 
                .Out(intermediate[i])
            );
        end
    endgenerate

    
    mux_4_to_1_1bit m4 (
        .In(intermediate), 
        .Sel(Sel[4:3]), 
        .Out(Out)
    );
endmodule

module mux_64_to_1_1bit (
    input wire [63:0] In,
    input wire [5:0]  Sel,
    output wire       Out
);
    wire [7:0] intermediate;

    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : stage1
            mux_8_to_1_1bit m8_l1 (
                .In(In[i*8 +: 8]), 
                .Sel(Sel[2:0]), 
                .Out(intermediate[i])
            );
        end
    endgenerate

    
    mux_8_to_1_1bit m8_final (
        .In(intermediate),
        .Sel(Sel[5:3]),
        .Out(Out)
    );
endmodule

module mux_3_to_1_bit (
    input wire in00,
    input wire in01,
    input wire in10,
    input wire s1,
    input wire s0,
    output wire out
);
    wire ns1, ns0;
    wire w0, w1, w2;

    
    not (ns1, s1);
    not (ns0, s0);

    
    and (w0, in00, ns1, ns0);
    
    
    and (w1, in01, ns1, s0);
    
    
    and (w2, in10, s1, ns0);

    
    or (out, w0, w1, w2);

endmodule

module mux_3_to_1 #(parameter WIDTH = 32) (
    input  wire [WIDTH-1:0] In00,  
    input  wire [WIDTH-1:0] In01,  
    input  wire [WIDTH-1:0] In10,  
    input  wire [1:0]       Sel,
    output wire [WIDTH-1:0] Out    
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : mux_array
            mux_3_to_1_bit mux_inst (
                .in00(In00[i]),
                .in01(In01[i]),
                .in10(In10[i]),
                .s1(Sel[1]),
                .s0(Sel[0]),
                .out(Out[i])
            );
        end
    endgenerate

endmodule