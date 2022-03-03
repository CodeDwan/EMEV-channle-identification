function [data_out] = my_transpose(data_in)
%MY_TRANSPOSE 此处显示有关此函数的摘要
%   此函数用于转置downlink CSI，使其维度与uplink保持相同
%   即将天线维度进行转置，输出为：子载波x发射天线x接收天线的维度
    dim = ndims(data_in);
    list = 1:dim;
    tlist = list;
    tlist(end) = dim-1;
    tlist(end-1) = dim;
    data_out = permute(data_in,tlist);
end

