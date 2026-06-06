module pe (
    input wire [7:0] A,
    input wire [7:0] B,
    input wire CLK,
    input wire AR,
    input wire [31:0] Y_in,
    input wire dr,

    output wire [31:0] Y_out, 
    output wire [7:0] A_out,
    output wire [7:0] B_out
);

    register_8bit a (
        .CLK(CLK),
        .AR(AR),
        .d(A),
        .q(A_out),
        .EN(1'b1)
    );

    register_8bit b (
        .CLK(CLK),
        .AR(AR),
        .d(B),
        .q(B_out),
        .EN(1'b1)
    );
    wire [31:0] Y_temp,Y_fin;
    assign Y_temp= Y_out+ (A*B);
    assign Y_fin = dr ? Y_in:Y_temp;

    register_32bit Y (
        .CLK(CLK),
        .AR(AR),
        .EN(1'b1),
        .d(Y_fin),
        .q(Y_out)
    );


endmodule