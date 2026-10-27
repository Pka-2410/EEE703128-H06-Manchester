`timescale 1ns/1ps

module tb_h06;
   reg clk;
   reg rst_n;
   reg ena;

   reg [7:0] ui_in;
   reg [7:0] uio_in;

   wire [7:0] uo_out;
   wire [7:0] uio_out;
   wire [7:0] uio_oe;

    tt_um_h06_manchester dut (
        .clk(clk),
        .rst_n(rst_n),
        .ena(ena),
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;
    
task test_byte;
        input [7:0] data;
        input conv;

        integer i;
        reg expected;

        begin
            // Dua du lieu vao H06
            @(negedge clk);
            ui_in = data;
            uio_in[1] = conv;
            uio_in[0] = 1'b1;

            // Cho H06 nhan lenh start
            @(posedge clk);
            #1;
            uio_in[0] = 1'b0;

            // Kiem tra 16 nua-bit
            for (i = 0; i < 16; i = i + 1) begin
                expected = data[7 - (i / 2)]
                           ^ conv ^ (i % 2);

                if (uo_out[0] !== expected ||
                    uo_out[1] !== 1'b1) begin
                    $display("FAIL: data=%h conv=%b half=%0d",
                             data, conv, i);
                    $fatal(1, "Manchester mismatch");
                end

                @(posedge clk);
                #1;
            end

            // Truyen xong thi busy = 0
            if (uo_out[1] !== 1'b0) begin
                $fatal(1, "Busy not cleared");
            end

            $display("PASS: data=%h conv=%b", data, conv);
        end
    endtask

    task test_start_while_busy;
        integer i;
        reg expected;
        reg [7:0] original;
        begin
            original = 8'hA5;
            // Bat dau phat byte A5
            @(negedge clk);
            ui_in = original;
            uio_in[1] = 1'b0;
            uio_in[0] = 1'b1;

            @(posedge clk);
            #1;
            uio_in[0] = 1'b0;

            // Kiem tra ca 16 nua-bit
            for (i = 0; i < 16; i = i + 1) begin
                expected = original[7 - (i / 2)]
                           ^ (i % 2);

                if (uo_out[0] !== expected ||
                    uo_out[1] !== 1'b1)
                    $fatal(1, "FAIL: start while busy");

                if (i == 3) begin
                    // Co tinh gui lenh moi khi busy
                    @(negedge clk);
                    ui_in = 8'hFF;
                    uio_in[1] = 1'b1;
                    uio_in[0] = 1'b1;

                    @(posedge clk);
                    #1;
                    uio_in[0] = 1'b0;
                end
                else begin
                    @(posedge clk);
                    #1;
                end
            end

            if (uo_out[1] !== 1'b0)
                $fatal(1, "FAIL: busy not cleared");

            $display("PASS: start while busy ignored");
        end
    endtask

    task test_reset_mid;
        begin
            // Bat dau phat byte FF
            @(negedge clk);
            ui_in = 8'hFF;
            uio_in[1] = 1'b0;
            uio_in[0] = 1'b1;

            @(posedge clk);
            #1;
            uio_in[0] = 1'b0;

            // Cho truyen mot vai nua-bit
            repeat (4) begin
                @(posedge clk);
                #1;
            end

            if (uo_out[1] !== 1'b1)
                $fatal(1, "FAIL: not busy before reset");

            // Reset khi dang truyen
            @(negedge clk);
            rst_n = 1'b0;
            #1;

            if (uo_out[1] !== 1'b0 ||
                uo_out[0] !== 1'b0)
                $fatal(1, "FAIL: reset during transmit");

            // Thoat reset
            @(negedge clk);
            rst_n = 1'b1;
            #1;

            if (uo_out[1] !== 1'b0)
                $fatal(1, "FAIL: busy after reset");

            $display("PASS: reset during transmission");
        end
    endtask



    initial begin
        // Luu waveform
        $dumpfile("h06.vcd");
        $dumpvars(0, tb_h06);

        // Khoi tao tin hieu
        ena = 1'b1;
        ui_in = 8'h00;
        uio_in = 8'h00;
        rst_n = 1'b1;

        // Reset H06
        #2 rst_n = 1'b0;
        repeat (2) @(negedge clk);
        rst_n = 1'b1;

        // 6 ca bat buoc theo charter
        test_byte(8'h00, 1'b0);
        test_byte(8'h00, 1'b1);

        test_byte(8'hFF, 1'b0);
        test_byte(8'hFF, 1'b1);

        test_byte(8'hA5, 1'b0);
        test_byte(8'hA5, 1'b1);

        // 2 ca kiem tra bo sung
        test_byte(8'h80, 1'b0);
        test_byte(8'h3C, 1'b1);

        // 8 ca kiem tra byte da hoan thanh
        $display("PASS: 8 byte/convention tests");

        // Kiem tra truong hop dac biet
        test_start_while_busy();
        test_reset_mid();

        // Kiem tra mach van truyen duoc sau reset
        test_byte(8'hA5, 1'b0);

        $display("PASS: all tests completed");
        $finish;

    end

endmodule