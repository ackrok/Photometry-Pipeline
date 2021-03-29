function data = processReward(data,params)
%Process Reward Delivery
%
%   Usage:
%       data = processReward(data,params);
%
%   Description:
%       This function will pull onset and offset times from reward
%       experiments
%
%   Input:
%       data - TLab data structure
%       params - A structure created from a script that contains parameters
%       for analysis
%
%   Output:
%       data - Updated data structure
%
%   Author: Pratik Mistry, 2020


nAcq = length(data.acq);
dsRate = params.dsRate;
rawFs = data.gen.acqFs;
Fs = rawFs/dsRate;
data.gen.Fs = Fs;
for n = 1:nAcq
    lick = data.acq(n).lick.trace;
    rewDelivery = data.acq(n).rew.trace;
    
    if sigEdge ~= 0 %Remove the beginning and the edge if the setting isn't 0
        lick = lick((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
        rewDelivery = rewDelivery((sigEdge*rawFs)+1:end-(sigEdge*rawFs));
    end
    L = size(lick);
    L = length(1:dsRate:L);
    
    lickOnset = getPulseOnsetOffset(lick, 0.5);
    data.final(n).lick.onset = lickOnset./dsRate;

    rewOnset = getPulseOnsetOffset(rewDelivery, 0.5);
    data.final(n).rew.cue = rewOnset(1:2:end)./dsRate; % Cue is first of two sequential digital inputs to NI board from Arduino
    data.final(n).rew.delivery = rewOnset(2:2:end)./dsRate; % Reward is second of two sequential digital inputs to NI board from Arduino

    data.final(n).lick.trace = lick(1:dsRate:end); % Downsampled lick trace
    data.final(n).rew.trace = rewDelivery(1:dsRate:end); % Downsampled cue/reward trace

    timeVec = [1:L]/Fs;
    data.final(n).time = timeVec';
    %{
    if isfield(data.final(n),'time')
        if isempty(data.final(n).time)
            timeVec = [1:L]/Fs;
            data.final(n).time = timeVec';
        end
    else
        timeVec = [1:L]/Fs;
        data.final(n).time = timeVec';
    end
    %}
end
end
