module branch_predictor (
    input wire clk,
    input wire ar,             
    input  wire [31:0] pc_fetch,
    input wire         update_en,     
    input wire [31:0]  pc_update,     
    input wire [31:0]  target_update, 
    input wire         branch_taken ,
    output wire        predict_taken,
    output wire [31:0] predict_target

);

   
    reg valid   [0:15];
    reg [25:0] tag     [0:15];
    reg [31:0] target  [0:15];
    reg [1:0]  history [0:15];

    
    wire [3:0]  fetch_idx = pc_fetch[5:2];
    wire [25:0] fetch_tag = pc_fetch[31:6];
    
    
    wire is_hit = valid[fetch_idx] && (tag[fetch_idx] == fetch_tag);

    
    assign predict_taken  = is_hit && (history[fetch_idx][1] == 1'b1);
    assign predict_target = target[fetch_idx];

   
    wire [3:0]  upd_idx = pc_update[5:2];
    wire [25:0] upd_tag = pc_update[31:6];

    integer i;

    always @(posedge clk or posedge ar) begin
        if (ar) begin
            
            for (i = 0; i < 16; i = i + 1) begin
                valid[i]   <= 1'b0;
                history[i] <= 2'b00;
            end
        end 
        else if (update_en) begin
            
            valid[upd_idx]  <= 1'b1;
            tag[upd_idx]    <= upd_tag;
            target[upd_idx] <= target_update;

            
            if (branch_taken) begin
                
                if (history[upd_idx] == 2'b00) history[upd_idx] <= 2'b01;
                else if (history[upd_idx] == 2'b01) history[upd_idx] <= 2'b10;
                else if (history[upd_idx] == 2'b10) history[upd_idx] <= 2'b11;
                else history[upd_idx] <= 2'b11; // Saturated
            end 
            else begin
                
                if (history[upd_idx] == 2'b11) history[upd_idx] <= 2'b10;
                else if (history[upd_idx] == 2'b10) history[upd_idx] <= 2'b01;
                else if (history[upd_idx] == 2'b01) history[upd_idx] <= 2'b00;
                else history[upd_idx] <= 2'b00; // Saturated
            end
        end
    end

endmodule