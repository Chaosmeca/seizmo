function [data,mvo,fh]=usermoveout(data,varargin)
%USERMOVEOUT    Interactivly add a distance-dependent moveout
%
%    Usage:    data=usermoveout(data)
%              data=usermoveout(data,'field1',value1,...,'fieldN',valueN)
%              [data,mvo]=usermoveout(...)
%              [data,mvo,fh]=usermoveout(...)
%
%    Description: DATA=USERMOVEOUT(DATA) presents an interactive menu and
%     record section plot (arranged by degree distance) to facilitate
%     timeshifting data by a particular moveout.  This is useful for
%     pre-aligning on a particular seismic phase before stacking or
%     windowing.  All moveouts are expressed in seconds per degree and are
%     applied relative to the lowest record's degree distance (given by the
%     GCARC field).
%
%     DATA=USERMOVEOUT(DATA,'FIELD1',VALUE1,...,'FIELDN',VALUEN) passes
%     field/value pairs to RECORDSECTION to allow plot customization.
%
%     [DATA,MVO]=USERMOVEOUT(...) returns a struct MVO with the following
%     fields:
%      MVO.moveout  --  moveout used in calculating the shifts (in sec/deg)
%      MVO.shift    --  actual time shifts applied to the data (in sec)
%
%     [DATA,MVO,FH]=USERMOVEOUT(...) returns the record section's figure
%      handle in FH.
%
%    Notes:
%     - Make sure you have the GCARC field set for all records!
%
%    Header changes: NZYEAR, NZJDAY, NZHOUR, NZMIN, NZSEC, NZMSEC
%                    A, B, E, F, O, Tn
%
%    Examples:
%     Typically one runs this followed by USERWINDOW & USERTAPER:
%      [data,mvo,fh(1)]=usermoveout(data);
%      [data,win,fh(2:3)]=userwindow(data);
%      [data,tpr,fh(4:5)]=usertaper(data);
%
%    See also: USERWINDOW, USERTAPER, USERALIGN

%     Version History:
%        Mar. 16, 2010 - initial version
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Mar. 16, 2010 at 14:30 GMT

% todo:

% check nargin
msg=nargchk(1,inf,nargin);
if(~isempty(msg)); error(msg); end

% check data structure
versioninfo(data,'dep');

% turn off struct checking
oldseizmocheckstate=seizmocheck_state(false);

% attempt header check
try
    % check headers
    data=checkheader(data);
    
    % turn off header checking
    oldcheckheaderstate=checkheader_state(false);
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
end

% attempt to add moveout
try
    % get distance
    gcarc=getheader(data,'gcarc');
    mindist=min(gcarc);
    
    % default moveout
    mvo.moveout=0;
    mvo.adjust=-(gcarc-mindist)*mvo.moveout;
    
    % outer loop - only breaks free on user command
    happy_user=false;
    while(~happy_user)
        % plot records vs distance
        fh=recordsection(timeshift(data,mvo.adjust),varargin{:});
        
        % get choice from user
        choice=menu('Adjust Moveout of the Data?','YES','NO');
        
        % act on choice
        if(choice==1)
            % ask user how much
            choice=menu('Adjust moveout by how much?',...
                '+0.500 sec/deg',...
                '+0.250 sec/deg',...
                '+0.100 sec/deg',...
                '+0.050 sec/deg',...
                '+0.025 sec/deg',...
                '+0.010 sec/deg',...
                ['KEEP CURRENT (' num2str(mvo.moveout) ')'],...
                '-0.010 sec/deg',...
                '-0.025 sec/deg',...
                '-0.050 sec/deg',...
                '-0.100 sec/deg',...
                '-0.250 sec/deg',...
                '-0.500 sec/deg',...
                'ADD CUSTOM');
            
            switch choice
                case 1
                    mvo.moveout=mvo.moveout+0.5;
                case 2
                    mvo.moveout=mvo.moveout+0.25;
                case 3
                    mvo.moveout=mvo.moveout+0.1;
                case 4
                    mvo.moveout=mvo.moveout+0.05;
                case 5
                    mvo.moveout=mvo.moveout+0.025;
                case 6
                    mvo.moveout=mvo.moveout+0.01;
                case 7
                    % do nothing
                case 8
                    mvo.moveout=mvo.moveout-0.01;
                case 9
                    mvo.moveout=mvo.moveout-0.025;
                case 10
                    mvo.moveout=mvo.moveout-0.05;
                case 11
                    mvo.moveout=mvo.moveout-0.1;
                case 12
                    mvo.moveout=mvo.moveout-0.25;
                case 13
                    mvo.moveout=mvo.moveout-0.5;
                case 14
                    % customized
                    tmp=inputdlg(...
                        'Add how much moveout (in sec/deg)? [0]:',...
                        'Custom Moveout',1,{'0'});
                    if(~isempty(tmp))
                        try
                            tmp=str2double(tmp{:});
                            if(isscalar(tmp) && isreal(tmp))
                                mvo.moveout=mvo.moveout+tmp;
                            end
                        catch
                            % do not change mvo.moveout
                        end
                    end
            end
            mvo.adjust=-(gcarc-mindist)*mvo.moveout;
            
            % close old figure
            close(fh(ishandle(fh)));
        else
            happy_user=true;
        end
    end
    
    % apply moveout
    if(mvo.moveout)
        data=timeshift(data,mvo.adjust);
    end
    
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    checkheader_state(oldcheckheaderstate);
catch
    % toggle checking back
    seizmocheck_state(oldseizmocheckstate);
    checkheader_state(oldcheckheaderstate);
    
    % rethrow error
    error(lasterror)
end

end