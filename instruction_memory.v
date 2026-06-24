module main_memory (
    input  wire        clk,
    input  wire        ar,

    // Instruction Cache Interface
    input  wire        imem_read_en,
    input  wire [31:0] imem_addr,
    output wire [31:0] imem_data_out,
    output wire        imem_ready,

    // Data Cache Interface
    input  wire        dmem_read_en,
    input  wire        dmem_write_en,
    input  wire [31:0] dmem_addr,
    input  wire [31:0] dmem_data_in,
    output wire [31:0] dmem_data_out,
    output wire        dmem_ready
);

    // 1. Instantiate the Instruction BRAM (256 depth = 8-bit word address)
    // We map the 32-bit byte address down to a word address using [9:2]
    inst_bram u_inst_mem (
      .clka(clk),
      .addra(imem_addr[9:2]),
      .douta(imem_data_out)
    );

    // 2. Instantiate the Data BRAM (64 depth = 6-bit word address)
    // We map the 32-bit byte address down to a word address using [7:2]
    data_bram u_data_mem (
      .clka(clk),
      .wea(dmem_write_en),
      .addra(dmem_addr[7:2]),
      .dina(dmem_data_in),
      .douta(dmem_data_out)
    );

    // FPGAs are incredibly fast. Since BRAM operates natively in 1 clock cycle,
    // we can eliminate your old 3-cycle simulation wait-states. 
    // We simply tell your cache controllers that the backing memory is always ready.
    assign imem_ready = 1'b1;
    assign dmem_ready = 1'b1;

endmodule