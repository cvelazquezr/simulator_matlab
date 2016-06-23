function [s, e] = start_end_points_saccade( saccade )
% Función para determinar los puntos de inicio y fin de las sácadas
% simuladas

velocity = 1000*diff(saccade);

difference = length(saccade) - length(velocity);

[max_y, max_x] = max(velocity);

% Start point
s = 1;
for i=max_x:-1:1
   if velocity(i) < 20
       s = i;
       break;
   end
end

s = s + difference;

% End point
e = length(saccade);
for i=max_x:length(velocity)
    if velocity(i) < 25
       e = i;
       break;
   end
end

end

