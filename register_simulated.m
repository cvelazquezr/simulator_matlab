function [ register, sp_x, sp_y, ep_x, ep_y ] = register_simulated(number, amplitude)

register = [];
factor = -1;
sp_x = zeros(number); sp_x = sp_x(1, :);
sp_y = zeros(number); sp_y = sp_y(1, :);
ep_x = zeros(number); ep_x = ep_x(1, :);
ep_y = zeros(number); ep_y = ep_y(1, :);

% Generando las sácadas que formarán el registro
for i=1:number
   amplitude_value = amplitude +  randi([-2, 2], [1, 1]);
   duration_value = 100 + randi([-25, 25], [1, 1]);
   latency_value = 0;
   fixation_value = 400 + randi([-80, 80], [1, 1]);
   
   inclination_div = 500;
   div = randi([3, 4], [1, 1]);
   
   if amplitude == 30
       inclination_div = 500;
       div = randi([5, 6], [1, 1]);
   elseif amplitude == 20
       inclination_div = 650;
       div = randi([7, 8], [1, 1]);
   elseif amplitude == 10
       inclination_div = 1000;
       div = randi([10, 12], [1, 1]);
   elseif amplitude == 60
       inclination_div = 250;
       div = randi([3, 4], [1, 1]);
   end
   
   inclination_value = randi([5, 10], [1, 1]) / inclination_div;
   
   if i == 1
      amplitude_value = amplitude_value / 2;
   end
   
   if mod(i, 2) == 0
      orint = 'left';
      inclination_value = inclination_value * factor;
      factor = -1;
   else
      orint = 'right';
      inclination_value = inclination_value * factor;
      factor = 1;
   end
   
   saccade = saccade_simulated(amplitude_value, duration_value, latency_value, orint);
   
   if length(register) > 1
      delta = abs(saccade(1) - register(end));
      if factor == 1
          saccade = saccade - delta;
      else
          saccade = saccade - delta;
      end
   end
   
   fixation = fixation_simulation(inclination_value, fixation_value);
   fixation = fixation + saccade(end);
   
   register = horzcat(register, saccade, fixation);
   
   sp_x(i) = length(register) - (length(saccade) + length(fixation)) + 1;
   ep_x(i) = length(register) - length(fixation) + 1;
   
end

% Añadiendo la fijación inicial
initial_fixation = zeros(400 + randi([-80, 80], [1, 1]));
initial_fixation = initial_fixation(1,:);
initial_fixation = initial_fixation + register(1);

sp_x = sp_x + length(initial_fixation);
ep_x = ep_x + length(initial_fixation);

register = horzcat(initial_fixation, register);

% Añadiendo el ruido
load('noise_mean.mat');
load('noise_std.mat');

noise_register = zeros(719);
noise_register = noise_register(1, :);

for i=1:length(noise_std)
    point_std = noise_std(i);
    
    point_mean_real = real(noise_mean(i));
    point_mean_img = imag(noise_mean(i));
    
    imin = int16(point_mean_real - point_std);
    imin = double(imin);
    imax = int16(point_mean_real + point_std);
    imax = double(imax);
    
    noise_rand = randi([imin, imax], [1, 1]);
    
    new_noise = noise_rand + point_mean_img*sqrt(-1);
    noise_register(i) = new_noise;
end

noise_register = noise_register / div;

fresult = fft(register);
fresult(2641:3360) = noise_register;

register = real(ifft(fresult));

for i=1:length(sp_x)
    sp_y(i) = register(sp_x(i));
    ep_y(i) = register(ep_x(i));
end

end

