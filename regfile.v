module register_32bit (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire [31:0] d,
    output wire [31:0] q
);
    genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : dff_array
            
            d_flip_flop_en dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate
endmodule

module register_32bit_sr (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire SR,
    input wire [31:0] d,
    output wire [31:0] q
);
     genvar i;
    generate
        for (i = 0; i < 32; i = i + 1) begin : dff_array
            
            d_flip_flop_sr dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .SR(SR),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate

endmodule

module register_5bit_sr (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire SR,
    input wire [4:0] d,
    output wire [4:0] q
);
     genvar i;
    generate
        for (i = 0; i < 5; i = i + 1) begin : dff_array
            
            d_flip_flop_sr dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .SR(SR),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate

endmodule

module register_6bit_sr (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire SR,
    input wire [5:0] d,
    output wire [5:0] q
);
     genvar i;
    generate
        for (i = 0; i < 6; i = i + 1) begin : dff_array
            
            d_flip_flop_sr dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .SR(SR),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate

endmodule

module register_8bit (
    input wire CLK,
    input wire AR,
    input wire EN,
    input wire [7:0] d,
    output wire [7:0] q
);
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : dff_array
            
            d_flip_flop_en dff_inst (
                .CLK(CLK),
                .AR(AR),
                .EN(EN),
                .D(d[i]),
                .Q(q[i])
            );
        end
    endgenerate
endmodule

module regfile (
    input wire clk,
    input wire ar,           
    input wire reg_write,    
    input wire [4:0] ra1,    
    input wire [4:0] ra2,    
    input wire [4:0] wa,     
    input wire [31:0] wd,    
    output wire [31:0] rd1,  
    output wire [31:0] rd2   
);
    wire [31:0] dec_out;
    wire [31:0] local_enable;
    wire [31:0] Q [31:0];    

    
    decoder5_32 write_decoder (
        .A(wa), 
        .Y(dec_out)
    );

    
    assign Q[0] = 32'b0;
    assign local_enable[0] = 1'b0;

    
    genvar r, b;
    generate
        for (r = 1; r < 32; r = r + 1) begin : reg_array
            
            and (local_enable[r], dec_out[r], reg_write);

            register_32bit reg_inst (
                .CLK(clk),
                .AR(ar),
                .EN(local_enable[r]),
                .d(wd),
                .q(Q[r])
            );
        end
    endgenerate
    
   
    generate
        for (b = 0; b < 32; b = b + 1) begin : bit_muxes
            wire [31:0] bit_bundle;

           
            for (r = 0; r < 32; r = r + 1) begin : gather
                assign bit_bundle[r] = Q[r][b];
            end

            
            mux_32_to_1_1bit mux_p1 (
                .In(bit_bundle),
                .Sel(ra1),
                .Out(rd1[b])
            );

            
            mux_32_to_1_1bit mux_p2 (
                .In(bit_bundle),
                .Sel(ra2),
                .Out(rd2[b])
            );
        end
    endgenerate

endmodule