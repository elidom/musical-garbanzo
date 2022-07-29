
clear all;
clc;
sca;

PsychDefaultSetup(2);
topdir = '/home/marcos/Documents/pell_lab/cesc/';
wavpracticedir = '/home/marcos/Documents/pell_lab/cesc/wav_practice/';

InitializePsychSound(1);
PsychPortAudio('Close'); %make sure all audio devices are closed
PsychPortAudio('Verbosity', 12); %how much info to print out

x  = PsychPortAudio('GetDevices'); % run to choose ID - usually many devices
pahandle = PsychPortAudio('Open', 5, 1, 1, 44100, 1); %deviceID, mode, latency mode,  freq, chann, buffersize, suddestedLate, select

PsychPortAudio('RunMode', pahandle, 1);%

wav_list = readlines("/home/marcos/Documents/pell_lab/cesc/wav_list.csv");

    
    for i = 1:length(wav_list)-1
        wavfile = wavpracticedir + wav_list(i);
        [y, freq] = psychwavread(wavfile);
        wavedata = y';
        PsychPortAudio('FillBuffer', pahandle, wavedata);
        t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
        %[audiodata] = PsychPortAudio('GetAudioData', pahandle)
        % status = PsychPortAudio('GetStatus', pahandle);
    
        [startTime, endPositionSecs, xruns, estStopTime] = PsychPortAudio('Stop', pahandle, 1);
        WaitSecs(1);
    end
    PsychPortAudio('Close', pahandle);