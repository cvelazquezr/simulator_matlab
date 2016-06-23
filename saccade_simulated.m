function [ saccade ] = saccade_simulated(amplitude, duration, latency, orientation)

% Sácada Base

x = 1:150;

a1 = amplitude / 4;
a2 = amplitude / 4;
a3 = amplitude;
c1 = 15;
c2 = 14;
b3 = 75;
b1 = 67;
b2 = 67;
c3 = 5;

pulse = a1.*exp(-((x-b1)./c1).^2) + a2.*exp(-((x-b2)./c2).^2);
step = a3 ./ (exp((b3 - x) ./ c3) + 1);
saccade = pulse + step;

[s, e] = start_end_points_saccade(saccade);
dur = e - s;

p = [a1, b1, c1, a2, b2, c2, a3, b3, c3];

% Transformando a la duración deseada
p_optim = trans_duration(dur, duration, p);

pulse = p_optim(1).*exp(-((x-p_optim(2))./p_optim(3)).^2) + p_optim(4).*exp(-((x-p_optim(5))./p_optim(6)).^2);
step = p_optim(7) ./ (exp((p_optim(8) - x) ./ p_optim(9)) + 1);
saccade = pulse + step;

[s, e] = start_end_points_saccade(saccade);
dur = e - s;

% Transformando a la latencia determinada

if s > latency
   delta = s - latency;
   s = s - delta;
   e = e - delta;
   
   saccade = saccade(delta:end);
else
   delta = latency - s;
   s = s + delta;
   e = e + delta;
   
   z = zeros(delta);
   z = z(1, :);
   
   saccade = horzcat(z, saccade);
end

saccade = saccade(1:e);

% Transformando según la orientación de la sácada

if strcmp(orientation, 'left')
   saccade = max(saccade) - saccade; 
end

% disp(s);
% disp(e);
% disp(dur);
% plot(saccade, 'k')
% hold
% plot(pulse, 'r')
% plot(step, 'b')
% plot(s, saccade(s), 'xr', 'MarkerSize', 15)
% plot(e, saccade(e), 'xk', 'MarkerSize', 15)

end

