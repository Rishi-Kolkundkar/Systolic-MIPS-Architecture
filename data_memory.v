module data_memory (
    input  wire [31:0] Address,
    input  wire [31:0] WriteData,
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire        CLK,
    output wire [31:0] ReadData
);
    
    wire [63:0] select;
    decoder6_64 u_dec (.A(Address[7:2]), .Y(select));

    
    wire [63:0] we;
    genvar i, b;
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_we
            and g_and (we[i], select[i], MemWrite);
        end
    endgenerate

    
    wire [31:0] mem_q [63:0];
    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_mem
            
            register_32bit u_reg (
                .d(WriteData), 
                .CLK(CLK), 
                .EN(we[i]), 
                .q(mem_q[i]), 
                .AR(1'b0)
            );
        end
    endgenerate

    
    wire [31:0] raw_read_word;
    generate
        for (b = 0; b < 32; b = b + 1) begin : gen_read
            wire [63:0] bit_bus;
            for (i = 0; i < 64; i = i + 1) begin : gather
                buf b_buf (bit_bus[i], mem_q[i][b]);
            end
            
            mux_64_to_1_1bit u_mux (
                .In(bit_bus), 
                .Sel(Address[7:2]), 
                .Out(raw_read_word[b])
            );
        end
    endgenerate

   
    mux_2_to_1 #(.WIDTH(32)) finsel (
        .In0(32'b0),
        .In1(raw_read_word),
        .Sel(MemRead),
        .Out(ReadData)
    );
endmodule