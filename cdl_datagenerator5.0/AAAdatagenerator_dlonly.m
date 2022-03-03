clc;clear;close all;
%%
%定义参数
number = input("请输入需要生成的样本数据：\n");

f_dowlink = 28e9;
type = "CDL-A";
NRB = 13;
SCS = 60;
Vc = [4.8, 24, 40, 60];    %用户移动速度km/h
% NRB = 6;    %资源块数
% carrnum = NRB*12;      %子载波数 = 资源块数*12
% OFDMNum = 14;       %OFDM符号数14
% OFCh = 3;  %选择第3个OFDM符号代表14个OFDM符号
%分别定义基站和用户端的天线阵列,求出基站和用户的天线数
BSAtNum = 64;
UEAtNum = 4;

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
batch = input("请输入每次生成的batch数，建议根据内存动态调整: \n");
epoch = number/batch;

%%  数据保存路径,打开文件
filename = "../cdl_data5/dl_"+num2str(f_dowlink/1e9)+"_"+type+"_NRB"+num2str(NRB)+"_"+num2str(BSAtNum)+"_"+num2str(UEAtNum)+"_"+num2str(number)+".mat" %保存路径
%打开文件保存数据

HCSI = complex(zeros(batch,NRB,UEAtNum,BSAtNum),zeros(batch,NRB,UEAtNum,BSAtNum));%downlink = 100x2x32
seedlist = zeros(1,number);
save(filename,'HCSI','seedlist','-v7.3')
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
    
    HCSI = complex(zeros(batch,NRB,UEAtNum,BSAtNum),zeros(batch,NRB,UEAtNum,BSAtNum));%downlink = 100x32x2(转置后)
    
    for i = 1:batch
        raseed = raseed_arr(i);
        index = index_arr(i);
     
        temp_downlink = PDSCH(type,NRB,f_dowlink,Vc(index),BSAtNum,UEAtNum,DelayS,raseed,SCS);
        temp_downlink = dealCSI(temp_downlink, NRB);
        
        HCSI(i,:,:,:) = temp_downlink; 
        fprintf("epoch:%d/%d,第%d组数据已生成\n",j,epoch,i)
    end
    
    m.HCSI(batch*(j-1)+1:batch*j,:,:,:) = HCSI;
    fprintf("保存提示：前%d组数据已保存\n",batch*j)
    
    clear  HCSI;
         
end

fprintf("保存提示：所有数据均已保存\n")


