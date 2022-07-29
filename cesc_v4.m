% Initialization
clear;
clc;
sca;

% experimenter should fill this in mannually: 
condition_num = '2';

try
    
    % Setup
    PsychDefaultSetup(2);

    screens = Screen('Screens');
    screenNumber = max(screens);
    white = WhiteIndex(screenNumber);
    black = BlackIndex(screenNumber);

    topdir = '/home/marcos/Documents/pell_lab/cesc/';
    wavpracticedir = '/home/marcos/Documents/pell_lab/cesc/wav_practice/';
    wavmaindir = '/home/marcos/Documents/pell_lab/cesc/wav_main/';
    lists_dir = '/home/marcos/Documents/pell_lab/cesc/stimuli_lists';
    stim_info = readtable([lists_dir filesep 'CESC_List' condition_num '.txt']);
   
    InitializePsychSound(1);
    PsychPortAudio('Close'); %make sure all audio devices are closed
    PsychPortAudio('Verbosity', 12); %how much info to print out

    x  = PsychPortAudio('GetDevices'); % run to choose ID - usually many devices
    pahandle = PsychPortAudio('Open', 5, 1, 1, 44100, 1); %deviceID, mode, latency mode,  freq, chann, buffersize, suddestedLate, select
    PsychPortAudio('RunMode', pahandle, 1);%

    practice_wav_list = readlines("/home/marcos/Documents/pell_lab/cesc/practice_wav_list.csv"); % list audio files

    % Preallocate data space
    trial_code = nan(328,1);
    rts = nan(328,1);
    keys = nan(328,1);
    trial_num = nan(328, 1);

    dx_onset = nan(328, 1);
    dx_off = nan(328, 1);
    real_on = nan(328, 1);

    set_quebec = nan(328, 1);
    content_pain = nan(328, 1);
    pros_complaint = nan(328, 1);
    sex_female = nan(328, 1);

    quebec = 90:10:160; % define code meanings for future table building
    pain = [50:10:80 130:10:160];
    complaint = [30 40 70 80 110 120 150 160];
    female = 20:20:160;
    

    % Run Screen and gather screen information
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black); % open screen
[screenXpixels, screenYpixels] = Screen('WindowSize', window); % count pixels
ifi = Screen('GetFlipInterval', window); % compute IFI
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Aliasing
[xCenter, yCenter] = RectCenter(windowRect); % compute screen center position
Screen('TextSize', window, 40); % define size of upcoming text

    % Load and display instruction Slides
    slideLocation = [topdir 'slides' filesep];
    slide1 = imread([slideLocation 'instructions_1.png']);
    slide2 = imread([slideLocation 'instructions_2.png']);
    slide3 = imread([slideLocation 'instructions_3.png']);
    slide4 = imread([slideLocation 'instructions_4.png']);
    slide5 = imread([slideLocation 'instructions_5.png']);
    slide6 = imread([slideLocation 'instructions_6.png']);
    [s1, s2, s3] = size(slide1); % gather slide size

    imageTexture = Screen('MakeTexture', window, slide1); % actually load texture of first slide
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    KbStrokeWait;

    imageTexture = Screen('MakeTexture', window, slide2); % actually load texture of second slide
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    KbStrokeWait;

    imageTexture = Screen('MakeTexture', window, slide3); % actually load texture of third slide
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    KbStrokeWait;

    imageTexture = Screen('MakeTexture', window, slide4); % actually load texture of third slide
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    KbStrokeWait;

    imageTexture = Screen('MakeTexture', window, slide5); % actually load texture of third slide
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    KbStrokeWait;

    imageTexture = Screen('MakeTexture', window, slide6); % actually load texture of third slide
    Screen('DrawTexture', window, imageTexture, [], [], 0);
    Screen('Flip', window);
    KbStrokeWait;
    

    % KbTriggerWait([KbName('t')]); % this will allow to synchronize EEG
    % recording with this script

    % Practice trials!
    for i = 1:length(practice_wav_list)-1 % loop on all elements of previously defined list of practice trials
        Screen('Flip', window); % blank screen (ISI)
        WaitSecs(2)
    
        % fixation cross
        fixCrossDimPix = 40;
        xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
        yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
        allCoords = [xCoords; yCoords];
        lineWidthPix = 4;
        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2); % cross ready for display
        
        t0 = Screen('Flip', window); % get timestamp at this flip (not useful here tho)
        WaitSecs(1); % practice trials get a one second fixation cross before audio onset
    
    
        % audio stimulus onset
        wavfile = wavpracticedir + practice_wav_list(i);
        [y, freq] = psychwavread(wavfile); % read file
        wavedata = y'; % transpose audio data
        PsychPortAudio('FillBuffer', pahandle, wavedata); % get the audio ready for playback
        t1 = PsychPortAudio('Start', pahandle, 1, 0, 1); % play the audio
    
        [startTime, endPositionSecs, xruns, estStopTime] = PsychPortAudio('Stop', pahandle, 1); 
        %  Stop playback, record playback time, and wait until playback
        %  ends

        WaitSecs(2); % Two seconds after audio offset before task

        % Task
        %keypressed = 0;
        DrawFormattedText(window, 'À quel point cette person', 'center', 100, white); % prepare quesiton
        DrawFormattedText(window, 'se sent-elle blessée?', 'center', 150, white);

        buttons = imread([slideLocation 'buttons.png']); % read buttons png file
        [s1, s2, s3] = size(buttons); % capture png size
        imageTexture = Screen('MakeTexture', window, buttons); % load texture of buttons
        Screen('DrawTexture', window, imageTexture, [], [], 0); % Prepare texture for display
        t1 = Screen('Flip', window); % display task (text + texture together) and get timestamp
        
        [secs, keyCode] = KbWait(1, [], t1 + 5); % wait max. 5 seconds for key stroke, record rt and key
        rts(i) = secs - t1; % get response time in secs
        
        if ~isempty(find(keyCode,1))
            keys(i) = find( keyCode ); % get pressed key identifier
        else
            keys(i) = 0;
        end
        trial_code(i) = 200;
        trial_num(i) = i;

        Screen('Close', imageTexture); % just to release from memory


    end

    DrawFormattedText(window,... % Indicate that practice trials are over; wait for keystroke
        'L''entraînement est terminé. Appuyez sur n''importe quelle touche pour continuer.',...
        'center', 'center', white)
    
    Screen('Flip', window);
    
    KbStrokeWait;

    
blocks = [9:48; 49:88; 89:128; 129:168; 169:208; 209:248; 249:288; 289:328];

% Main trials!

for j = 1:8  % 1- 8 corresponding to the 8 blocks

    for i = blocks(j,:) % 40 columns in each row of 'blocks', i.e. trials in each block

        wav_name = string(stim_info.File(i));
        code = stim_info.Code(i);
        final_word = stim_info.FinalWord(i)/1000;
        final = stim_info.Offset(i)/1000;
        fixation_dur = stim_info.Fixation(i)/1000;

        t00 = Screen('Flip', window); % blank screen (ISI)
        % WaitSecs(2) specified 'when' on the next flip

        Screen('DrawLines', window, allCoords,...
            lineWidthPix, white, [xCenter yCenter], 2); % call fixation cross
        
        t0 = Screen('Flip', window, t00 + 2 - ifi*0.5); % show cross and get timestamp
        disp('trigger: ' + string(code + 9) + ' - time after flip: ' + string(GetSecs - t0)) % replace by trigger
        disp('did two seconds elapse? ' + string(GetSecs - t00)) % delete this line later
        disp('t0 - t00 ' + string(t00 - t0)) % delete this line later
        % fwrite(s1, dist_trig); % this would be a real trigger

        % audio stimulus onset
        wavfile = wavmaindir + wav_name + '.wav';
        [y, freq] = psychwavread(wavfile); % read file
        wavedata = y'; % transpose audio data
        PsychPortAudio('FillBuffer', pahandle, wavedata); % get the audio ready for playback
        t1 = PsychPortAudio('Start', pahandle, 1, t0 + fixation_dur, 1); % play the audio after the indicated time
        disp('trigger: ' + string(code + 0) + ' - time after audio onset: ' + string(GetSecs - t1)) % replace by onset trigger
        disp('was the audio onset accurate? ' + string(t1 - (t0 + fixation_dur))) % delete this line later

        real_on(i) = t1 - t0; 
        dx_onset(i) = real_on(i) - fixation_dur; % gather info to diagnose timing accuracy
        
        WaitSecs('UntilTime', t1 + final_word);
        disp('trigger: ' + string(code + 1) + ' - final word late?: ' + ...
            string((GetSecs - t1) - final_word)) % replace by final word trigger

        [startTime, endPositionSecs, xruns, estStopTime] = PsychPortAudio('Stop', pahandle, 1); 
        %stop audio when playback is over
        
        disp('trigger: ' + string(code + 2) + ' - time after audio offset: ' + string((GetSecs - t1) - final)) % replace by audio end trigger
        dx_off(i) = endPositionSecs - final; % gather diagnostic info

        % WaitSecs(2); % Two seconds after audio ended before task

        % Task
        DrawFormattedText(window, 'À quel point cette person', 'center', 100, white); % prepare quesiton
        DrawFormattedText(window, 'se sent-elle blessée?', 'center', 150, white);

        buttons = imread([slideLocation 'buttons.png']); % read buttons png file
        imageTexture = Screen('MakeTexture', window, buttons); % load texture of buttons
        Screen('DrawTexture', window, imageTexture, [], [], 0); % Prepare texture for display
        t2 = Screen('Flip', window, estStopTime + 2 - ifi*0.5); % display task (text + texture together) and get timestamp

        disp('trigger: ' + string(code + 6) + ' - time after flip: ' + string(GetSecs - t2)) % replace by scale trigger
        disp('task shown time after audio ended: ' + string(GetSecs - estStopTime)) % delete this line later
        
        [secs, keyCode] = KbWait(1, [], t2 + 5); % wait max. 5 seconds for key stroke, record rt and key
        rts(i) = secs - t2; % get response time in secs
        if ~isempty(find(keyCode, 1))
            keys(i) = find( keyCode ); % get pressed key identifier
        else
            keys(i) = 0;
        end
        trial_num(i) = i;
        trial_code(i) = code;

        if ismember(code, quebec); set_quebec(i) = 1; else; set_quebec(i) = 0; end % build behavioral log
        if ismember(code, pain); content_pain(i) = 1; else; content_pain(i) = 0; end
        if ismember(code, complaint); pros_complaint(i) = 1; else; pros_complaint(i) = 0; end
        if ismember(code, female); sex_female(i) = 1; else; sex_female(i) = 0; end

        Screen('Close', imageTexture); % just to release from memory

    end
    
    if j < 8 % display the break or end message
        DrawFormattedText(window,... % Indicate a break starts; wait for keystroke
            'Prenez une courte pause. Appuyez sur n''importe quelle touche lorsque vous êtes prêt à continuer.',...
            'center', 'center', white);
    else
        DrawFormattedText(window,... % Indicate end
        'Merci de votre participation !', ...
            'center', 'center', white)
    end
    Screen('Flip', window);
    [buh, pressed] = KbStrokeWait();
    
    if find(pressed) == 37 % just for debugging, if return is pressed, stop everything
        sca;
        break;
    end

end

    PsychPortAudio('Close', pahandle);


    catch failure

end

sca



T = table(trial_num, trial_code, set_quebec, content_pain, pros_complaint, sex_female, rts, keys, ...
    'VariableNames', {'trial_number', 'tCode', 'set_quebec', 'content_pain',...
    'prosody_complaint', 'sex_female', 'RT', 'keys'});

dxT = table(trial_num, real_on, dx_onset, dx_off,...
    'VariableNames', {'trial_number', 'real_onset', 'on_error', 'off_error'});

%





