clc;clear;close all;
%%
%定义参数
number = input("请输入需要生成的样本数据：\n");
f_A = input("请输入面板A频段中心频率（例如3GHz输入3e9）：\n");
f_B = input("请输入面板B频段中心频率（例如28GHz输入28e9）：\n");
type = input("请输入信道类型(可选项为CDL-A,B,C,D,E): \n" , 's')
Vc = [4.8, 24, 40, 60];    %用户移动速度km/h

NRB = 6;    %资源块数
carrnum = NRB*12;      %子载波数 = 资源块数*12
OFDMNum = 14;       %OFDM符号数14
%分别定义基站和用户端的天线阵列,求出基站和用户的天线数
BSAtNum = 64;
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

%数据保存路径
filename = "../data/"+type+"_"+num2str(carrnum)+"_"+num2str(BSAtNum)+"_"+num2str(UEAtNum)+"_"+num2str(number)+".mat" %保存路径
%打开文件保存数据
mimo_panelA = complex(zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum),zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum));%下行A面板信道，基站——用户
mimo_panelB = complex(zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum),zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum));%下行B面板信道，基站——用户
save(filename,'mimo_panelA','mimo_panelB','-v7.3')
m = matfile(filename,'Writable',true);

%%
raseed_total = randperm(number);
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
    mimo_panelA = complex(zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum),zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum));%下行A面板信道，基站——用户
    mimo_panelB = complex(zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum),zeros(batch,carrnum,OFDMNum,UEAtNum,BSAtNum));%下行B面板信道，基站——用户

    for i = 1:batch
        raseed = raseed_arr(i);
        index = index_arr(i);
        mimo_panelA(i,:,:,:,:) = PDSCH(type,NRB,f_A,Vc(index),BSAtNum,UEAtNum,DelayS,raseed); %上行频段2.0GHz
        mimo_panelB(i,:,:,:,:) = PDSCH(type,NRB,f_B,Vc(index),BSAtNum,UEAtNum,DelayS,raseed); %下行频段2.1GHz
        fprintf("epoch:%d/%d,第%d组数据已生成\n",j,epoch,i)
    end
    m.mimo_panelA(batch*(j-1)+1:batch*j,:,:,:,:) = mimo_panelA;
    m.mimo_panelB(batch*(j-1)+1:batch*j,:,:,:,:) = mimo_panelB;
    fprintf("保存提示：前%d组数据已保存\n",batch*j)
    
    clear mimo_panelA mimo_panelB;
         
end
fprintf("保存提示：所有数据均已保存\n")
