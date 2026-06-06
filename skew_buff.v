module skew_buff #(parameter N=3) (
    input wire [7:0] stream_in,
    input wire CLK,
    input wire AR,

    output wire [7:0] stream_out
);
    generate
    if(N==0) begin
        assign stream_out=stream_in;
    end

    else begin
        wire [7:0] chain[N:0];
        assign chain[0]=stream_in;

        genvar i;
        
            for (i=0;i<N;i=i+1) begin: stream
                register_8bit chain_prop (
                    .CLK(CLK),
                    .AR(AR),
                    .EN(1'b1),
                    .d(chain[i]),
                    .q(chain[i+1])
                );
            end

        assign stream_out=chain[N];
    end
    endgenerate

endmodule