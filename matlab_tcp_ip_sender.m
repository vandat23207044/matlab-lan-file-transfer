clc; clear all; close all;

% 1. Chọn file bất kỳ
disp('Đang chờ bạn chọn file...');
[filename, pathname] = uigetfile('*.*', 'Chọn một file bất kỳ để gửi');
if isequal(filename, 0)
    disp('Bạn đã hủy chọn file.');
    return;
end
fullFilePath = fullfile(pathname, filename);
disp(['Chuẩn bị gửi file: ', filename]);

% Đọc toàn bộ nội dung file dưới dạng nhị phân
fid = fopen(fullFilePath, 'r');
FileData = fread(fid, inf, '*uint8'); 
fclose(fid);

% Lấy kích thước tổng của file
totalBytes = length(FileData);

% 2. Kết nối tới Server (Thay IP phù hợp)
IP_SERVER = '172.18.0.238';  %ip của server
t = tcpclient(IP_SERVER, 5001); 

% ==================== CẤU HÌNH BỘ ĐỆM ====================
% Chọn kích thước chunk là 5MB để 
% 
% gửi siêu tốc, hoặc giữ 8KB nếu muốn an toàn
chunkSize = 5242880; 

% Mở rộng bộ đệm Output của MATLAB cho vừa bằng kích thước 1 chunk
% (Lệnh này PHẢI nằm trước lệnh fopen)
t.OutputBufferSize = chunkSize; 
% =========================================================

disp('Đang kết nối tới Server...');
open(t);
disp('Đã kết nối!');

% -----------------------------------------------------
% 3. GIAI ĐOẠN ĐÓNG GÓI VÀ GỬI (GIAO THỨC TỰ ĐỊNH NGHĨA)
% -----------------------------------------------------
% Phép tính 1: Tính độ dài của tên file (Ví dụ 'tailieu.pdf' dài 11 ký tự)
name_length = length(filename);

% Gửi [HEADER 1]: 1 Byte chứa độ dài của tên file
write(t, uint8(name_length), 'uint8');

% Gửi [HEADER 2]: Các Byte chứa chuỗi ký tự tên file
write(t, uint8(filename), 'uint8');

% Gửi [PAYLOAD]: Toàn bộ nội dung file (ĐÃ ÁP DỤNG BĂM NHỎ)
disp(['Đang truyền dữ liệu file (', num2str(totalBytes), ' bytes)...']);

for i = 1:chunkSize:totalBytes
    % Xác định đoạn dữ liệu cần cắt
    endIdx = min(i + chunkSize - 1, totalBytes);

    % Bơm từng "cục" dữ liệu vào đường truyền
    write(t, FileData(i:endIdx), 'uint8'); 
end
% -----------------------------------------------------

disp('Đã gửi xong toàn bộ file!');
close(t);
delete(t);
clear t;

