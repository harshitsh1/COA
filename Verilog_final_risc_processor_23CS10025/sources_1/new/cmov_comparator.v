module cmov_comparator(
    input wire isCmov,
    input wire [31:0] rs_val, rt_val, aluip1, aluip2,
    output reg [31:0] aluip_fin1, aluip_fin2
);

    always @(*) begin
        if(isCmov) begin
            aluip_fin1 <= (rs_val < rt_val)? rs_val : rt_val;
            aluip_fin2 <= 0;
        end
        else begin
            aluip_fin1 <= aluip1;
            aluip_fin2 <= aluip2;
        end
    end

endmodule