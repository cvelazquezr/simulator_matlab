function [ amplitudes, peak_velocities ] = main_sequence_simulator( input_args )

amplitudes = 10:80;
durations = [];

for i=1:length(amplitudes)
    duration_value = 100 + randi([-25, 25], [1, 1]);
    durations(i) = duration_value;
    
    sac = saccade_simulated(amplitudes(i), duration_value, 0, 'right');
    vel = 1000*diff(sac);
    peak_vel = max(vel);
    peak_velocities(i) = peak_vel;
end

end

