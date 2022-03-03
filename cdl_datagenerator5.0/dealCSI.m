% 处理CSI
function [H] = dealCSI(hest,RBNum)
%     hest = permute(hest,[1,2,4,3]); %子载波*OFDM*基站天线*UE天线 
    hest_shape = size(hest);
    hest = reshape(hest,hest_shape(2:end));
    hest_shape = size(hest);
    H = zeros([RBNum,hest_shape(3:end)]);
    hest = mean(hest,2); %子载波*1*基站天线*用户天线，平均OFDM符号数
    hest = reshape(hest,[hest_shape(1),hest_shape(3:4)]);
    for m = 1:RBNum
        temp = hest((m-1)*12+1:m*12,:,:);
        H(m,:,:) = mean(temp,1);
    end 
end

