//Simple Direct mapped caches separate for instructions and data

module icache (
    input  wire        clk,
    input  wire        ar,
    

    input  wire [31:0] cpu_pc,
    output wire [31:0] cpu_instr,
    output wire        stall_cpu,   

    
    output wire [31:0] mem_addr,
    output wire        mem_read_en,
    input  wire [31:0] mem_data,
    input  wire        mem_ready    
);

    reg        valid [0:15];
    reg [25:0] tag   [0:15];
    reg [31:0] data  [0:15];

    wire [3:0]  idx         = cpu_pc[5:2];
    wire [25:0] current_tag = cpu_pc[31:6];

    wire is_hit = valid[idx] && (tag[idx] == current_tag);

    
    parameter COMPARE = 1'b0;
    parameter FETCH   = 1'b1;
    reg state;

    
    integer i;

    always @(posedge clk or posedge ar) begin
        if (ar) begin
            state <= COMPARE;
            
            for (i = 0; i < 16; i = i + 1) valid[i] <= 1'b0;
        end 
        else begin
            case (state)
                COMPARE: begin
                    if (!is_hit) state <= FETCH;
                end
                FETCH: begin
                    if (mem_ready) begin
                        valid[idx] <= 1'b1;
                        tag[idx]   <= current_tag;
                        data[idx]  <= mem_data;
                        state      <= COMPARE;
                    end
                end
            endcase
        end
    end

    
    assign cpu_instr   = is_hit ? data[idx] : 32'h00000000;
    assign stall_cpu   = !is_hit;
    assign mem_addr    = cpu_pc;
    assign mem_read_en = (state == FETCH);

endmodule

module dcache (
    input  wire        clk,
    input  wire        ar,
    
    
    input  wire [31:0] cpu_addr,
    input  wire [31:0] cpu_write_data,
    input  wire        cpu_req_read,
    input  wire        cpu_req_write,
    
    output wire [31:0] cpu_read_data,
    output wire        stall_cpu,

    
    output wire [31:0] mem_addr,
    output wire [31:0] mem_write_data,
    output wire        mem_read_en,
    output wire        mem_write_en,
    input  wire [31:0] mem_read_data,
    input  wire        mem_ready
);

    reg        valid [0:15];
    reg [25:0] tag   [0:15];
    reg [31:0] data  [0:15];

    wire [3:0]  idx         = cpu_addr[5:2];
    wire [25:0] current_tag = cpu_addr[31:6];

    wire is_hit = valid[idx] && (tag[idx] == current_tag);

    parameter IDLE_COMPARE = 2'b00;
    parameter WAIT_READ    = 2'b01;
    parameter WAIT_WRITE   = 2'b10;
    
    reg [1:0] state;
    integer i;

    always @(posedge clk or posedge ar) begin
        if (ar) begin
            state <= IDLE_COMPARE;
            for (i = 0; i < 16; i = i + 1) valid[i] <= 1'b0;
        end else begin
            case (state)
                IDLE_COMPARE: begin
                    if (cpu_req_read && !is_hit) begin
                        state <= WAIT_READ;
                    end 
                    else if (cpu_req_write) begin
                        valid[idx] <= 1'b1;
                        tag[idx]   <= current_tag;
                        data[idx]  <= cpu_write_data;
                        state <= WAIT_WRITE;
                    end
                end
                
                WAIT_READ: begin
                    if (mem_ready) begin
                        valid[idx] <= 1'b1;
                        tag[idx]   <= current_tag;
                        data[idx]  <= mem_read_data;
                        state      <= IDLE_COMPARE;
                    end
                end
                
                WAIT_WRITE: begin
                    if (mem_ready) begin
                        state <= IDLE_COMPARE;
                    end
                end
            endcase
        end
    end

    
    assign cpu_read_data = (state == WAIT_READ && mem_ready) ? mem_read_data :
                           (cpu_req_read && is_hit && state == IDLE_COMPARE) ? data[idx] : 
                           32'h00000000;
    
    
    assign stall_cpu = (cpu_req_read && !is_hit && state == IDLE_COMPARE) || 
                       (cpu_req_write && state == IDLE_COMPARE) || 
                       (state != IDLE_COMPARE && !mem_ready);

    
    assign mem_addr       = cpu_addr;
    assign mem_write_data = cpu_write_data;
    assign mem_read_en    = (state == WAIT_READ)  || (cpu_req_read && !is_hit && state == IDLE_COMPARE);
    assign mem_write_en   = (state == WAIT_WRITE) || (cpu_req_write && state == IDLE_COMPARE);

endmodule