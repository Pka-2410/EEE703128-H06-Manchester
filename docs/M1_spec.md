# M1 - Dac ta H06 Manchester

## 1. Chuc nang
Mach nhan 1 byte du lieu 8 bit va phat ra
tin hieu duoc ma hoa Manchester.

## 2. Giao dien
- ui_in[7:0]: Byte du lieu dau vao
- uio_in[0]: Lenh bat dau truyen (start)
- uio_in[1]: Chon quy uoc Manchester
- uo_out[0]: Tin hieu Manchester
- uo_out[1]: Bao dang truyen (busy)

## 3. Quy uoc de xuat
- Convention = 0: bit 0 -> 01, bit 1 -> 10
- Convention = 1: bit 0 -> 10, bit 1 -> 01
- Truyen bit 7 truoc, bit 0 sau
- Moi nua bit keo dai 1 chu ky clock
- Khi dang busy, bo qua lenh start moi
- Khi idle, busy = 0 va tin hieu ra = 0