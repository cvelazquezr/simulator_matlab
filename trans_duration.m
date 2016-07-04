function [ params_optimized ] = trans_duration(curr_dur, obj_dur, prms)
% Esta función se encargará de transformar una sácada en otra con una
% duración especificada.

global x;
global obje_dur;

x = 1:150;
obje_dur = obj_dur;

param_dur = int8(obje_dur / 10);
param_dur = double(param_dur);

if curr_dur < obje_dur
    saccade_ideal = prms(7)./(exp((prms(8) - x)/param_dur) + 1);

    options = optimset('MaxIter', 5000, 'MaxFunEvals', 10000, 'Display', 'off', 'OutputFcn', @outfun);
    
    lb = [prms(7)/6; 60; 20; prms(7)/6; 60; 20; prms(7); prms(8); param_dur - 1];
    ub = [prms(7)/2; Inf; Inf; prms(7)/2; Inf; Inf; prms(7) + 3; Inf; Inf];

    a = fminsearchbnd(@(p) mod_duration(p, saccade_ideal), prms, lb, ub, options);

    params_optimized = a;
end

end

function error = mod_duration(p, saccade_ideal)
    global x;
    new_saccade = (p(1).*exp(-(p(2) - x).^2/p(3).^2) + p(4).*exp(-(p(5) - x).^2/p(6).^2)) + p(7)./(exp((p(8) - x)/p(9)) + 1);

    error = rmse(saccade_ideal, new_saccade);
end


function stop = outfun(p, optimValues, state)
    global x;
    global obje_dur;
    stop = false;

    new_saccade = (p(1).*exp(-(p(2) - x).^2/p(3).^2) + p(4).*exp(-(p(5) - x).^2/p(6).^2)) + p(7)./(exp((p(8) - x)/p(9)) + 1);

    [s, e] = start_end_points_saccade(new_saccade);
    dur = e - s;

    error = abs(dur - obje_dur);

    if error <= 2
        stop = true;
    end
end