module mult36x36  (
    input clk,
    input rstn,
    input ce,
    input valid_in,
    input signed [35:0] data_a,
    input signed [35:0] data_b,
    output reg valid_out,
    output reg signed  [71:0] mult_result
);
    
always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        valid_out <= 0;
    end else begin
        valid_out <= valid_in;
    end

    if(!rstn) begin
        mult_result <= 0;
    end else if(ce && valid_in) begin
        mult_result <= $signed(data_a) * $signed(data_b);
    end
end
endmodule