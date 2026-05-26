clc; clear all; close all;

HOST = '0.0.0.0';  
PORT = 5001;       
t = tcpip(HOST, PORT, 'NetworkRole', 'server');
t.InputBufferSize = 10000000; % Để hẳn 10MB cho thoải mái nhận file bự

disp(['[*] Đang lắng nghe trên cổng ', num2str(PORT), '...']);
fopen(t); 
disp('[+] Đã kết nối với Client! Đang phân tích gói tin...');

% -----------------------------------------------------
% GIAI ĐOẠN BÓC TÁCH (GIẢI MÃ GIAO THỨC)
% -----------------------------------------------------

% 1. Chờ và đọc 1 Byte đầu tiên (Độ dài tên file)
while t.BytesAvailable < 1
    pause(0.1);
end
name_length = fread(t, 1, 'uint8');

% 2. Chờ và đọc số lượng byte đúng bằng name_length để lấy Tên file
while t.BytesAvailable < name_length
    pause(0.1);
end
name_bytes = fread(t, name_length, 'uint8');

% Chuyển mảng số nhị phân vừa nhận thành chuỗi ký tự (string)
received_filename = char(name_bytes');
save_filename = ['copy_of_', received_filename]; % Thêm chữ để phân biệt

disp(['[*] Đã nhận diện được định dạng! File sẽ lưu tên: ', save_filename]);
% -----------------------------------------------------

% Tạo file với tên và định dạng đã bóc tách được
fid = fopen(save_filename, 'w');

% Bắt đầu nhận ruột dữ liệu (Payload) như bình thường
disp('[*] Đang tải nội dung file về...');
pause(0.5); 

while true
    if t.BytesAvailable > 0
        data = fread(t, t.BytesAvailable, 'uint8');
        fwrite(fid, data, 'uint8');
    else
        pause(0.1);
    end
    
    if strcmp(t.Status, 'closed') && t.BytesAvailable == 0
        break;
    end
end

fclose(fid);
disp(['[*] Đã tải và lưu hoàn chỉnh file: ', save_filename]);
fclose(t);
delete(t);
clear t;