function styleLabelAsValid(hLabel,validStr)
%styleLabelAsValid Summary of this function goes here
%   Detailed explanation goes here
    lblStr = strWrapForLabel(hLabel, validStr);
    
    set(hLabel,'Visible','on');
    set(hLabel,'BackgroundColor',[34,139,34]/255);
    set(hLabel,'ForegroundColor',[1,1,1]);
    set(hLabel,'String',lblStr);
    set(hLabel,'TooltipString','');
    set(hLabel,'FontWeight','bold');
    
    setappdata(hLabel,'tooltipstring',validStr);
end

