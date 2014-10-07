% LM3 demo
% This demo shows how to get data from the LM3 light meter. It continously 
% plots the data from both channels to a MATLAB figure.
%
% Installation:
%
% The device communicates via a virtual serial port (USB-CDC). On Windows
% you must use a setup information file or INF file to install it. You can 
% use the file "crsltd_usb_cdc_acm.inf" from Cambridge Research Systems 
% (www.crsltd.com). Plug in the device, go to Device Manager, click 
% "Update Device Software" and direct it to the file. On Mac and Linux no
% driver is needed and the device should be shown in the "/dev" folder when
% plugged in. Take a note of the port address in either the Device Manager
% or /dev folder and specify it below in this script. On Windows it starts
% with "COM" followed by a number, i.e. "COMx" where "x" is the number. On
% Mac and Linux it is typically called "/dev/tty.usbmodemxxx" where "xxx"
% is a number.
%
% If you are not using MATLAB you can use PuTTY 
% (Windows) or screen (Linux and Mac).

% JT 05/2014 created
% JT 07/2014 updated to close serial port when figure is closed, changed
% file name to LM3demo.m

% specify the port address
port = '/dev/tty.usbmodem1421';
%port = 'COM16';

delete(instrfindall);

% create the serial port object and increse buffer to 32 kb
s1 = serial(port);
s1.InputBufferSize = 32768;

% open the port
fopen(s1);

% query for command options
fwrite(s1,['?', 13]);

% wait until return is ready
pause(1);

% read and display in command window
result = fread(s1,s1.BytesAvailable);
disp(char(result)');

% set sweep length (number of samples to take, max: 3999)
%fwrite(s1,['L500', 13]);
fwrite(s1,['L100', 13]);
pause(0.5);
result = fread(s1,s1.BytesAvailable);
disp(char(result)');

% set sample period (in microseconds, min: 5)
% P is for period and the number after it is the microsecconds, achtung not
% less than 5
fwrite(s1,['P1200', 13]);
pause(0.5);
result = fread(s1,s1.BytesAvailable);
disp(char(result)')


f1 = figure; 
title('Close the figure to close the program')

%AsyncFlipTest_M

% loop and get data continuously 
while 1
    % send a command to record data
    fwrite(s1,['A', 13]);
    while s1.BytesAvailable<6
    end
    result = fread(s1,s1.BytesAvailable);
    disp(char(result)');

    % loop until data is ready (S 3 returned)
    while 1
        fwrite(s1,['S', 13]);
        while s1.BytesAvailable<9
        end
        result = fread(s1,s1.BytesAvailable);
        if strfind(char(result)','3'),
            break;
        end
    end

    % get the data
    fwrite(s1,['D', 13]);
    fscanf(s1);
    result = fscanf(s1);
    
    % parse the data string
    C = textscan(char(result)','%d %d','Delimiter',',');
    pause(0.1);
    if ishandle(f1),
        % update the plot
        plot(C{1},'r'); hold on
        plot(C{2},'b'); hold off
        ylim([0 255])
        xlim([0 100])
        title('Close the figure window to stop the program')
    else
        disp('Program stopped by the user');
        break;
    end
    
% %     AssertOpenGL;
% % 
% if nargin < 1 || isempty(screenid)
%     screenid = max(Screen('Screens'));
% end
% %     % Open onscreen window with imaging pipeline enabled:
% PsychImaging('PrepareConfiguration');
% PsychImaging('AddTask', 'General', 'UseVirtualFramebuffer');
% w = PsychImaging('OpenWindow', screenid, 0, [200, 400, 300, 500]);
% ifi = Screen('GetFlipInterval', w);
% 
% % % Sync us to retrace with a conventional flip:
%  Screen('Flip', w);
%     %AsyncFlipTest_M
    
end

% close the serial port
fclose(s1);
