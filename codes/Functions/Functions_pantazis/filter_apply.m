function Xf = filter_apply(X,h_filter);
% function Xf = filter_apply(X,h_filter);
%
% Applies the FIR h_filter to the timeseries on the matrix X (ntimeseries x ntimes)
%
% INPUTS:
%   X: matrix of timeseries (nTimeseries x nTimes)
%   h_filter: filter coefficients
%
% OUTPUTS:
%   Xf: matrix of filtered timeseries
%
% Also see: FILTER_DESIGN
%
% Author: Dimitrios Pantazis, February 2009

%test inputs
if nargin == 0 %if no input
    help filter_apply %display help
    return
end

%apply filter
Xf = zeros(size(X));
for i = 1:size(X,1)
    Xf(i,:) = filtfilt(h_filter,1,X(i,:));
end

