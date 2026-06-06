//Behavioural  simulation of a main memory taking multiple cycle to check speed of cache

module main_memory (
    input  wire        clk,
    input  wire        ar,

    
    input  wire        imem_read_en,
    input  wire [31:0] imem_addr,
    output wire [31:0] imem_data_out,
    output wire        imem_ready,

    
    input  wire        dmem_read_en,
    input  wire        dmem_write_en,
    input  wire [31:0] dmem_addr,
    input  wire [31:0] dmem_data_in,
    output wire [31:0] dmem_data_out,
    output wire        dmem_ready
);
   
    reg [31:0] memory [0:255]; 

    initial begin
        $readmemh("p4.dat", memory);
    end

   
    reg [2:0] wait_a;
    reg       ready_a_reg;

    always @(posedge clk or posedge ar) begin
        if (ar) begin
            wait_a <= 0; ready_a_reg <= 0;
        end else if (imem_read_en) begin
            if (wait_a == 3) begin
                ready_a_reg <= 1; wait_a <= 0;
            end else begin
                ready_a_reg <= 0; wait_a <= wait_a + 1;
            end
        end else begin
            wait_a <= 0; ready_a_reg <= 0;
        end
    end

    wire [29:0] word_addr_a = imem_addr[31:2];
    assign imem_data_out = ready_a_reg ? memory[word_addr_a] : 32'hz;
    assign imem_ready    = ready_a_reg;

  
    reg [2:0] wait_b;
    reg       ready_b_reg;

    always @(posedge clk or posedge ar) begin
        if (ar) begin
            wait_b <= 0; ready_b_reg <= 0;
        end else if (dmem_read_en || dmem_write_en) begin
            if (wait_b == 3) begin
                ready_b_reg <= 1; wait_b <= 0;
                
                if (dmem_write_en) memory[dmem_addr[31:2]] <= dmem_data_in; 
            end else begin
                ready_b_reg <= 0; wait_b <= wait_b + 1;
            end
        end else begin
            wait_b <= 0; ready_b_reg <= 0;
        end
    end

    wire [29:0] word_addr_b = dmem_addr[31:2];
    assign dmem_data_out = ready_b_reg ? memory[word_addr_b] : 32'hz;
    assign dmem_ready    = ready_b_reg;

endmodule