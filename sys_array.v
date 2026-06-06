module sys_array (
    input wire CLK,
    input wire AR,
    input wire drain,

    input wire [7:0]  c0,
    input wire [7:0]  c1,
    input wire [7:0]  c2,
    input wire [7:0]  c3,

    input wire [7:0]  r0,
    input wire [7:0]  r1,
    input wire [7:0]  r2,
    input wire [7:0]  r3,

    output wire [31:0] d0,
    output wire [31:0] d1,
    output wire [31:0] d2,
    output wire [31:0] d3
);
    wire [7:0] row[3:0];
    wire [7:0] col[3:0];

    skew_buff #(.N(0)) c00 (
        .stream_in(c0),
        .CLK(CLK),
        .AR(AR),
        .stream_out(col[0])
    );

    skew_buff #(.N(1)) c10 (
        .stream_in(c1),
        .CLK(CLK),
        .AR(AR),
        .stream_out(col[1])
    );

    skew_buff #(.N(2)) c20 (
        .stream_in(c2),
        .CLK(CLK),
        .AR(AR),
        .stream_out(col[2])
    );
    
    skew_buff #(.N(3)) c30 (
        .stream_in(c3),
        .CLK(CLK),
        .AR(AR),
        .stream_out(col[3])
    );

    skew_buff #(.N(0)) r00 (
        .stream_in(r0),
        .CLK(CLK),
        .AR(AR),
        .stream_out(row[0])
    );

    skew_buff #(.N(1)) r10 (
        .stream_in(r1),
        .CLK(CLK),
        .AR(AR),
        .stream_out(row[1])
    );

    skew_buff #(.N(2)) r20 (
        .stream_in(r2),
        .CLK(CLK),
        .AR(AR),
        .stream_out(row[2])
    );

    skew_buff #(.N(3)) r30 (
        .stream_in(r3),
        .CLK(CLK),
        .AR(AR),
        .stream_out(row[3])
    );

    wire [7:0] rw0 [3:0];
    wire [7:0] rw1 [3:0];
    wire [7:0] rw2 [3:0];
    wire [7:0] rw3 [3:0];

    wire [7:0] cl0 [3:0];
    wire [7:0] cl1 [3:0];
    wire [7:0] cl2 [3:0];
    wire [7:0] cl3 [3:0];

    wire [31:0] y0 [3:0];
    wire [31:0] y1 [3:0];
    wire [31:0] y2 [3:0];
    wire [31:0] y3 [3:0];

    //row 0
    pe p00 (
        .A(row[0]),
        .B(col[0]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(32'b0),

        .Y_out(y0[0]),
        .A_out(rw0[0]),
        .B_out(cl0[0])
    );

    pe p01 (
        .A(rw0[0]),
        .B(col[1]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y0[0]),

        .Y_out(y0[1]),
        .A_out(rw0[1]),
        .B_out(cl1[0])
    );

    pe p02 (
        .A(rw0[1]),
        .B(col[2]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y0[1]),

        .Y_out(y0[2]),
        .A_out(rw0[2]),
        .B_out(cl2[0])
    );

    pe p03 (
        .A(rw0[2]),
        .B(col[3]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y0[2]),

        .Y_out(y0[3]),
        .A_out(), 
        .B_out(cl3[0])
    );

    assign d0 = y0[3];

    //row 1

    pe p10 (
        .A(row[1]),
        .B(cl0[0]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(32'b0),

        .Y_out(y1[0]),
        .A_out(rw1[0]),
        .B_out(cl0[1])
    );

    pe p11 (
        .A(rw1[0]),
        .B(cl1[0]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y1[0]),

        .Y_out(y1[1]),
        .A_out(rw1[1]),
        .B_out(cl1[1])
    );

    pe p12 (
        .A(rw1[1]),
        .B(cl2[0]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y1[1]),

        .Y_out(y1[2]),
        .A_out(rw1[2]),
        .B_out(cl2[1])
    );

    pe p13 (
        .A(rw1[2]),
        .B(cl3[0]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y1[2]),

        .Y_out(y1[3]),
        .A_out(), 
        .B_out(cl3[1])
    );

    assign d1 = y1[3];

    //row 2
    pe p20 (
        .A(row[2]),
        .B(cl0[1]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(32'b0),

        .Y_out(y2[0]),
        .A_out(rw2[0]),
        .B_out(cl0[2])
    );

    pe p21 (
        .A(rw2[0]),
        .B(cl1[1]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y2[0]),

        .Y_out(y2[1]),
        .A_out(rw2[1]),
        .B_out(cl1[2])
    );

    pe p22 (
        .A(rw2[1]),
        .B(cl2[1]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y2[1]),

        .Y_out(y2[2]),
        .A_out(rw2[2]),
        .B_out(cl2[2])
    );

    pe p23 (
        .A(rw2[2]),
        .B(cl3[1]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y2[2]),

        .Y_out(y2[3]),
        .A_out(), 
        .B_out(cl3[2])
    );

    assign d2 = y2[3];

    //row 3
    pe p30 (
        .A(row[3]),
        .B(cl0[2]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(32'b0),

        .Y_out(y3[0]),
        .A_out(rw3[0]),
        .B_out()
    );

    pe p31 (
        .A(rw3[0]),
        .B(cl1[2]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y3[0]),

        .Y_out(y3[1]),
        .A_out(rw3[1]),
        .B_out()
    );

    pe p32 (
        .A(rw3[1]),
        .B(cl2[2]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y3[1]),

        .Y_out(y3[2]),
        .A_out(rw3[2]),
        .B_out()
    );

    pe p33 (
        .A(rw3[2]),
        .B(cl3[2]),
        .CLK(CLK),
        .AR(AR),
        .dr(drain),
        .Y_in(y3[2]),

        .Y_out(y3[3]),
        .A_out(), 
        .B_out()
    );

    assign d3 = y3[3];


endmodule