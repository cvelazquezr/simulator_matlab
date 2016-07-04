function [ errors_median, errors_sgo ] = evaluate_filter( clean_record, noise_record )
% Función para evaluar los diferentes métodos de filtrado

% Filtro de mediana
% disp('RMSE respecto a la señal sin ruido');
% disp('**********************************');

for i=1:40
   filt_signal = medfilt1(noise_record, i);
   error = rmse(filt_signal, clean_record);
   errors_median(i) = error;
%    disp(sprintf('Ventana %d: Error = %f', i, error));
end

% Filtro de Savitzky-Golay

f = 21;

for k=1:f-2
   filt_signal = sgolayfilt(noise_record, k, f);
   error = rmse(filt_signal, clean_record);
   errors_sgo(k) = error;
end

end

