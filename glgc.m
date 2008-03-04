function [varargout]=glgc(data,varargin)
%GLGC    Get logic words from SAClab logic header field
%
%    Description: Returns cellstring array containing 'true' 'false'
%     'undefined' or 'unknown' corresponding to values from the specified 
%     SAClab data field(s).
%
%    Usage: [lgccellstr1,lgccellstr2,...]=glgc(data,'field1','field2',...)
%
%    Examples:
%     To check if all records are evenly spaced:
%      if(all(strcmp(glgc(data,'leven'),'true'))) 
%          disp('evenly spaced data')
%      end
%
%    See also: gh, genum, genumdesc

% require at least two inputs
if(nargin<2)
    error('MATLAB:nargchk:notEnoughInputs',...
        'Not enough input arguments.')
end

% preallocate output
varnargin=length(varargin);
nvarargout=cell(1,varnargin);
varargout=nvarargout;
[varargout{:}]=deal(cell(length(data),1));

% get header info
[nvarargout{:}]=gh(data,varargin{:});

% loop over versions
v=[data.version];
for i=unique(v)
    % grab header setup
    h=seishi(i);
    
    % indexing of data with this header version
    ind=find(v==i);
    
    % loop over fields
    for j=1:length(varargin)
        [varargout{j}{ind(nvarargout{j}(ind)==h.true)}]=deal('true');
        [varargout{j}{ind(nvarargout{j}(ind)==h.false)}]=deal('false');
        [varargout{j}{ind(nvarargout{j}(ind)==h.undef.ntype)}]=deal('undefined');
        [varargout{j}{ind(nvarargout{j}(ind)~=h.true & ...
            nvarargout{j}(ind)~=h.false & ...
            nvarargout{j}(ind)~=h.undef.ntype)}]=deal('unknown');
    end
end

end
