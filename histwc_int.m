% HISTWC  Weighted histogram count given number of bins
%
% This function generates a vector of cumulative weights for data
% histogram. Equal number of bins will be considered using minimum and 
% maximum values of the data. Weights will be summed in the given bin.
%
% Usage: [histw] = histwc_int(vv, ww, vinterval)
%
% Arguments:
%       vv    - values as a vector
%       ww    - weights as a vector
%       vinterval - intervals used
%
% Returns:
%       histw     - weighted histogram
%       
%       
%
%
% See also: HISTC, HISTWCV

% Author:
% mehmet.suzen physics org
% BSD License
% July 2013

function [histw] = histwc_int(vv, ww, vinterval)
nbins = length(vinterval);
histw = zeros(nbins, 1);
for i=1:length(vv)
    ind = find(vinterval < vv(i), 1, 'last' );
    if ~isempty(ind)
        histw(ind) = histw(ind) + ww(i);
    end
end
