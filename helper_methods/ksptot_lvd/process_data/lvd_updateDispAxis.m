function lvd_updateDispAxis(handles, maStateLog, orbitNumToPlot, orbitPlotType, lvdData)
%lvd_updateDispAxis Summary of this function goes here
%   Detailed explanation goes here    

    celBodyData = lvdData.celBodyData;

    hDispAxes = handles.dispAxes;
    hShowSoICheckBox = handles.showSoICheckBox;
    hShowChildrenCheckBox = handles.showChildrenCheckBox;
    hDispAxisTitleLabel = handles.dispAxisTitleLabel;
    hShowChildBodyMarker = handles.showChildBodyMarker;
    
    if(isempty(orbitNumToPlot))
        orbitNumToPlot = 1;
        set(hDispAxes,'UserData',orbitNumToPlot);
    end

%     showSoICheckBoxINT = get(hShowSoICheckBox,'value');
%     if(showSoICheckBoxINT == 1)
%         showSoI = true;
%     else
%         showSoI = false;
%     end
    
%     hShowChildrenCheckBoxINT = get(hShowChildrenCheckBox,'value');
%     if(hShowChildrenCheckBoxINT == 1)
%         showChildBodies = true;
%     else
%         showChildBodies = false;
%     end
    
%     hShowOtherSpacecraftCheckBoxINT = get(hShowOtherSpacecraftCheckBox,'value');
%     if(hShowOtherSpacecraftCheckBoxINT == 1)
%         showOtherSC = true;
%     else
        showOtherSC = false;
%     end
    
%     showChildBodyMarkerINT = get(hShowChildBodyMarker,'value');
%     if(showChildBodyMarkerINT == 1)
%         showChildMarker = true;
%     else
%         showChildMarker = false;
%     end
    
    axes(hDispAxes);
    cla(gca);
    
    lvd_plotStateLog(maStateLog, [], showSoI, showChildBodies, showChildMarker, showOtherSC, orbitNumToPlot, hDispAxisTitleLabel, orbitPlotType, lvdData, celBodyData);
end