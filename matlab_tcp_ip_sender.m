% Clear console and workspace
clc;
clear all;
close all;

% ĐỌC FILE .TXT VÀO BỘ NHỚ TRƯỚC
disp('Reading txt file...');
fid = fopen('data.txt', 'r');
FileData = fread(fid); % Đọc toàn bộ file txt dưới dạng byte nhị phân
fclose(fid);

% Configuration and connection (Nhớ đổi IP cho khớp với Server)
IP_SERVER = '10.10.10.242'; % Sửa lại cho đúng
t = tcpip(IP_SERVER, 4013);

% Open socket
disp('Connecting to server...');
fopen(t);
disp('Connected!');
pause(0.2);

% GỬI FILE TEXT (Vẫn giữ hiệu ứng gửi từ từ để Wireshark bắt cho đẹp)
% Chúng ta sẽ gửi từng ký tự một, hoặc từng cụm ký tự
disp('Sending text data...');
for i = 1:length(FileData)    
    fwrite(t, FileData(i)); % Gửi từng byte/ký tự của file txt
    pause(0.1); % Dừng 0.1s mỗi ký tự để Wireshark hiện nhiều gói PSH
end

% Close and delete connection
disp('Closing connection...');
fclose(t);
delete(t);
clear t;
disp('Done!');