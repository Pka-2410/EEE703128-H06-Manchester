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

    assign uo_out  = 8'b00000000;
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;


endmodule