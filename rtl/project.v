module tt_um_h06_manchester (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    reg [7:0] shift_reg;  // Du lieu can truyen
    reg [2:0] bit_count;  // so bit da truyen
    reg half_phase;       // Phan biet hai nua
    reg busy_reg;         // Trang thai dang truyen
    reg convention_reg;   // Quy uoc

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg      <= 8'b00000000;
            bit_count      <= 3'b000;
            half_phase     <= 1'b0;
            busy_reg       <= 1'b0;
            convention_reg <= 1'b0;
        end
        else if (!busy_reg && uio_in[0]) begin
            shift_reg      <= ui_in;
            bit_count      <= 3'b000;
            half_phase     <= 1'b0;
            busy_reg       <= 1'b1;
            convention_reg <= uio_in[1];
        end
        else if (busy_reg) begin
            if (half_phase == 1'b0) begin
                half_phase <= 1'b1;
                end
                else begin
                    half_phase <= 1'b0;

                    if (bit_count ==  3'd7) begin
                        busy_reg <= 1'b0;
                        end
                        else begin
                            bit_count <= bit_count + 1'b1;
                            shift_reg <= {shift_reg[6:0], 1'b0};
                            end
                        end
                    end
    end

    
    wire manchester_bit;

    assign manchester_bit =
        busy_reg
        ? (shift_reg[7] ^ convention_reg ^ half_phase)
        : 1'b0;

    assign uo_out = {6'b000000, busy_reg, manchester_bit};

    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;


endmodule