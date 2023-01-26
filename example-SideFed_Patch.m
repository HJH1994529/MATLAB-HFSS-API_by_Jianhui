clear;clc;
try
    APIFolder = 'C:\Users\Administrator\Desktop\hfssapi-by-Jianhui Huang\';
    addpath(genpath(APIFolder));
    % tmpPrjFile£ºpath for aedt or hfss project file
    % tmpScriptFile£ºpath for vbs file
    tmpPrjFile = 'F:\vbsScript\SideFed_Patch.aedt';
    tmpScriptFile = 'F:\vbsScript\Helloworld.vbs';

    % hfssExePath£ºpath for HFSS
    hfssExePath = 'D:\software\HFSS\HFSS15.0\Win64\hfss.exe';
    % create a vbs file
    fid = fopen(tmpScriptFile, 'wt');

    % create a new HFSS project and insert a design file.
    hfssNewProject(fid);
    Design_name='Design1';
    hfssInsertDesign(fid, Design_name);
    % insert variables
    Patch_W=16.9;Patch_L=13.3;copper_H=0.035;
    margin_x=20;margin_y=20;
    Feed_W0=0.3;Feed_W1=1.62;
    Feed_L0=7;Feed_L1=3;
    Sub_W=35;Sub_L=30;Sub_H=0.762;lambda=300/4;
    hfssVariableInsert(fid,Design_name,'copper_H', copper_H, 'mm',1);
    hfssVariableInsert(fid,Design_name,'Patch_W', Patch_W, 'mm',1);
    hfssVariableInsert(fid,Design_name,'Patch_L', Patch_L, 'mm',1);
    hfssVariableInsert(fid,Design_name,'margin_x', margin_x, 'mm',1);
    hfssVariableInsert(fid,Design_name,'margin_y', margin_y, 'mm',1);
    hfssVariableInsert(fid,Design_name,'Feed_W0', Feed_W0, 'mm',1);
    hfssVariableInsert(fid,Design_name,'Feed_W1', Feed_W1, 'mm',1);
    hfssVariableInsert(fid,Design_name,'Feed_L0', Feed_L0, 'mm',1);
    hfssVariableInsert(fid,Design_name,'Feed_L1', Feed_L1, 'mm',1);    
    hfssVariableInsert(fid,Design_name,'Sub_W', 'Patch_W+2*margin_y', 'mm',2);
    hfssVariableInsert(fid,Design_name,'Sub_L', 'Patch_L+margin_y+Feed_L0+Feed_L1', 'mm',2);
    hfssVariableInsert(fid,Design_name,'Sub_H', Sub_H, 'mm',1);
    hfssVariableInsert(fid,Design_name,'lambda', lambda, 'mm',1);
    % substrate
    hfssAddMaterial(fid, 'substrate1', 3.66, 1, 0.0037, 0);
    hfssBox(fid, 'Sub', {'-Patch_L/2-margin_x', '-Sub_W/2', '0mm'}, {'Sub_L', 'Sub_W', 'Sub_H'}, 'mm',...
        "(0 128 128)", "substrate1", 0, 2);
    % GND 
    hfssBox(fid, 'GND', {'-Patch_L/2-margin_x', '-Sub_W/2', '0mm'}, {'Sub_L', 'Sub_W', '-copper_H'}, 'mm',...
        "(255 128 0)", "copper", 0, 2);
    % Patch antenna 
    hfssBox(fid, 'Patch', {'-Patch_L/2', '-Patch_W/2', 'Sub_H'}, {'Patch_L', 'Patch_W', 'copper_H'}, 'mm',...
        "(255 128 0)", "copper", 0, 2);   
    % impedance transformer 
    hfssBox(fid, 'Trans_line', {'Patch_L/2', '-Feed_W0/2', 'Sub_H'}, {'Feed_L0', 'Feed_W0', 'copper_H'}, 'mm',...
        "(255 128 0)", "copper", 0, 2);   
    hfssBox(fid, 'LineFor_50ohm', {'Patch_L/2+Feed_L0', '-Feed_W1/2', 'Sub_H'}, {'Feed_L1', 'Feed_W1', 'copper_H'}, 'mm',...
        "(255 128 0)", "copper", 0, 2);   
    hfssUnite(fid, {'Patch', 'Trans_line', 'LineFor_50ohm'});
    % Lumped port face
    hfssRectangle(fid, 'PortFace1', 'X', {'Patch_L/2+Feed_L0+Feed_L1', '-Feed_W1/2', '0mm'}, 'Feed_W1','Sub_H', 'mm',...
       "(255 0 0)", 0, 2);
    % Lumped port excitation
    hfssAssignLumpedPort(fid, 'LumpedPort1','PortFace1', [Patch_L/2+Feed_L0+Feed_L1,0,0;Patch_L/2+Feed_L0+Feed_L1,0,Sub_H],'mm',50,0,[]);
    % Air Box 
    hfssCreateRegion(fid,'AirBox1',{'lambda/4','lambda/4';'lambda/4','lambda/4';'lambda/4','lambda/4'},'mm',2);
    % Radiation     
    hfssAssignRadiation(fid, 'Radiation1','AirBox1');
    % SolutionSetup          
    hfssSolutionSetup(fid, 'Setup1',6,'GHz',20,0.02);
    % FrequencySweep
    hfssInsertFrequencySweep(fid,'Setup1','Sweep1','Fast','true',[4,0.01,6],'GHz');
    % FarFieldSphereSetup   
    hfssInsertFarFieldSphereSetup(fid, 'FarField1',[-180,1,180], [0,1,360]);
    % Save project
    hfssSaveProject(fid, tmpPrjFile,1);    
%     % Analyze
%     hfssAnalyzeSetup(fid,'Setup1');
%     % Create report
%     hfssCreateModalSolutionDataForTwoPort(fid,'report_S11','Setup1','Sweep1','dB','S',{'LumpedPort1','LumpedPort1'},[1,1]);
%     hfssCreate2DFarFieldReport(fid,'report_Gain1','Setup1','Sweep1','FarField1','dB','GainTotal','Theta',...
%         'All',[0,90],[5,5.5,6],'GHz');
%     hfssCreate2DFarFieldReport(fid,'report_Gain2','Setup1','Sweep1','FarField1','dB','GainTotal','Freq',...
%         0,0,linspace(4,6,3),'GHz');
%     hfssCreate3DFarFieldReport(fid,'report_Gain3','Setup1','Sweep1','FarField1','dB','GainTotal','All','All',5.6,'GHz');
% 
%     % Export csv file
%     hfssExportToFile(fid,'report_S11', 'F:\vbsScript\report_S11.csv');    
%     hfssExportToFile(fid,'report_Gain1', 'F:\vbsScript\report_Gain1.csv');    
%     hfssExportToFile(fid,'report_Gain2', 'F:\vbsScript\report_Gain2.csv');    
%     hfssExportToFile(fid,'report_Gain3', 'F:\vbsScript\report_Gain3.csv');    
%     % Save project
%     hfssSaveProject(fid, tmpPrjFile,1);
    % close vbs file
    fclose(fid);
    disp('vbs file is created£¡');
    % MATLAB call HFSS    
    hfssExecuteScript(hfssExePath, tmpScriptFile, false, false);    
catch
    disp('Error£¡');
    fclose(fid);
end