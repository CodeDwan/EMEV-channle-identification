clc;clear;close all;
%%
%定义参数
number = input("请输入需要生成的样本数据：\n");
f_uplink = input("请输入上行频段中心频率（例如3GHz输入3e9）：\n");
f_dowlink = input("请输入下行频段中心频率（例如28GHz输入28e9）：\n");
type = input("请输入信道类型(可选项为CDL-A,B,C,D,E): \n" , 's');
NRB = input("请输入资源块数(子载波数=资源块数x12):\n");
Vc = [4.8, 24, 40, 60];    %用户移动速度km/h

% NRB = 6;    %资源块数
carrnum = NRB*12;      %子载波数 = 资源块数*12
OFDMNum = 14;       %OFDM符号数14
OFCh = 3;  %选择第3个OFDM符号代表14个OFDM符号
%分别定义基站和用户端的天线阵列,求出基站和用户的天线数
BSAtNum = 32;
UEAtNum = 2;

switch type
    case 'CDL-A'
        DelayS = 129e-9;
    case 'CDL-B'
        DelayS = 634e-9;
    case 'CDL-C'
        DelayS = 634e-9;
    otherwise
        DelayS = 65e-9;
end

%将number个样本分batch处理
batch = input("请输入每次生成的batch数，建议根据内存动态调整: \n")
epoch = number/batch;

%%  数据保存路径,打开文件
filename = "../data5/(2.0+2.1)"+type+"_NRB"+num2str(NRB)+"_"+num2str(BSAtNum)+"_"+num2str(UEAtNum)+"_"+num2str(number)+".mat" %保存路径
%打开文件保存数据
NR_uplink = complex(zeros(batch,NRB,BSAtNum,UEAtNum),zeros(batch,NRB,BSAtNum,UEAtNum));%uplink = 100x32x2
NR_downlink = complex(zeros(batch,NRB,BSAtNum,UEAtNum),zeros(batch,NRB,BSAtNum,UEAtNum));%downlink = 100x2x32
seedlist = zeros(1,number);
save(filename,'NR_uplink','NR_downlink','seedlist','-v7.3')
m = matfile(filename,'Writable',true);

%%
raseed_total = randperm(number);
m.seedlist = raseed_total;
index_total = randi(length(Vc),1,number);

%生成速度矩阵
for p = 1:length(index_total)
    Vmatrix(p) = Vc(index_total(p));
end
%分批次生成数据
for j = 1:epoch
    %生成随机种子序列
    raseed_arr = raseed_total((j-1)*batch+1:j*batch);
    index_arr = index_total((j-1)*batch+1:j*batch);
    NR_uplink = complex(zeros(batch,NRB,BSAtNum,UEAtNum),zeros(batch,NRB,BSAtNum,UEAtNum));%uplink = 100x32x2
    NR_downlink = complex(zeros(batch,NRB,BSAtNum,UEAtNum),zeros(batch,NRB,BSAtNum,UEAtNum));%downlink = 100x32x2(转置后)

    for i = 1:batch
        raseed = raseed_arr(i);
        index = index_arr(i);
        temp_uplink = PUSCH(type,NRB,f_uplink,Vc(index),UEAtNum,BSAtNum,DelayS,raseed);
        temp_downlink = PDSCH(type,NRB,f_dowlink,Vc(index),BSAtNum,UEAtNum,DelayS,raseed);
        temp_downlink = my_transpose(temp_downlink);
        NR_uplink(i,:,:,:) = reshape(temp_uplink(1,1:12:end,OFCh,:,:),[NRB,BSAtNum,UEAtNum]); 
        NR_downlink(i,:,:,:) = reshape(temp_downlink(1,1:12:end,OFCh,:,:),[NRB,BSAtNum,UEAtNum]); 
        fprintf("epoch:%d/%d,第%d组数据已生成\n",j,epoch,i)
    end
    m.NR_uplink(batch*(j-1)+1:batch*j,:,:,:) = NR_uplink;
    m.NR_downlink(batch*(j-1)+1:batch*j,:,:,:) = NR_downlink;
    fprintf("保存提示：前%d组数据已保存\n",batch*j)
    
    clear NR_uplink NR_downlink;
         
end

fprintf("保存提示：所有数据均已保存\n")
