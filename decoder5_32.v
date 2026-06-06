module decoder3_8 ( 
    input wire A0,A1,A2,
    output wire [7:0] Y
);
    wire n0,n1,n2;
    not(n0,A0);
    not(n1,A1);
    not(n2,A2);

    and(Y[0],n0,n1,n2);
    and(Y[1],n2,n1,A0);
    and(Y[2],n2,A1,n0);
    and(Y[3],n2, A1, A0);
    and(Y[4],A2,n1,n0);
    and(Y[5],A2,n1,A0);
    and(Y[6],A2,A1,n0);
    and(Y[7],A2,A1,A0);

endmodule

module decoder2_4 (
    input wire A0, A1,
    output wire [3:0] Y
);
    wire n0, n1;

    not (n0, A0);
    not (n1, A1);

    
    and (Y[0], n1, n0); 
    and (Y[1], n1, A0); 
    and (Y[2], A1, n0); 
    and (Y[3], A1, A0); 
endmodule

module decoder5_32 (
    input wire [4:0] A,
    output wire [31:0] Y
);
    wire [3:0] bank_en;
    wire [7:0] raw_y0, raw_y1, raw_y2, raw_y3;

    
    decoder2_4 bank_select (
        .A0(A[3]), 
        .A1(A[4]), 
        .Y(bank_en)
    );

    
    decoder3_8 b0 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .Y(raw_y0));
    decoder3_8 b1 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .Y(raw_y1));
    decoder3_8 b2 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .Y(raw_y2));
    decoder3_8 b3 (.A0(A[0]), .A1(A[1]), .A2(A[2]), .Y(raw_y3));

    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gating
            and (Y[i],    raw_y0[i], bank_en[0]);
            and (Y[i+8],  raw_y1[i], bank_en[1]);
            and (Y[i+16], raw_y2[i], bank_en[2]);
            and (Y[i+24], raw_y3[i], bank_en[3]);
        end
    endgenerate

endmodule

module decoder6_64 (
    input wire [5:0] A,
    output wire [63:0] Y
);
    wire [7:0] bank_sel;   
    wire [7:0] offset_sel; 

    decoder3_8 bank_dec (
        .A0(A[3]), .A1(A[4]), .A2(A[5]), 
        .Y(bank_sel)
    );

    decoder3_8 offset_dec (
        .A0(A[0]), .A1(A[1]), .A2(A[2]), 
        .Y(offset_sel)
    );

    
    genvar i, j;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_banks
            for (j = 0; j < 8; j = j + 1) begin : gen_offsets
                and gate_y (Y[i*8 + j], bank_sel[i], offset_sel[j]);
            end
        end
    endgenerate
endmodule