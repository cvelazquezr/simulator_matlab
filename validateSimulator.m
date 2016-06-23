function [ saccades ] = validateSimulator

% Se realiza el mismo procedimiento que hizo Fofi en su tesis doctoral para
% obtener las componentes pulso y escalón, pero acá se le realiza a un
% registro simulado para comprobar si el resultado se corresponde con un
% pulso y un escalón.

load('saccades.mat')

max_length = 150;
amplitude = 30;
cant_saccades = 24;

saccades_arr = [];

for i=2:cant_saccades
    saccade = saccades{i, 1};
    
    % Llevando todas las sácadas al mismo tamaño
    if length(saccade) < max_length
       delta = max_length - length(saccade);
       
       zer = zeros(delta);
       zer = zer(1,:);
       zer = zer + saccade(end);
       
       saccade = horzcat(saccade, zer);
    end
    
    % Eliminar sácadas de larga duración
%     if saccade(65) - saccade(60) >= 0.5
%        continue; 
%     end
    
    % Eliminar sácadas de amplitud fuera de std de la media
%     if abs(amplitude - max(saccade)) >= 3
%         continue;
%     end
    
    saccades_arr = [saccades_arr; saccade];
%     plot(saccade)
%     hold('on')
end

% Aplicando InfoMax ICA

[S, A, U, ll, info] = icaML(saccades_arr, 2);

% Haciendo las demás cosas que hace Fofi después de aplicar el algoritmo

PromSac = mean(saccades_arr(:,1:end));

wi0 = EscalarComp(S,saccades_arr(:,1:end));
if wi0(1) < 0; S(1,:) = -1 .* S(1,:); end;
if wi0(2) < 0; S(2,:) = -1 .* S(2,:); end;

wi = EscalarComp(S,saccades_arr(:,1:end));
yICAi(1,:) = wi(1) .* S(1,:);
yICAi(2,:) = wi(2) .* S(2,:);  
yICA.Dif = S(1,:) + S(2,:) - PromSac;
 
yICAi(1,:) = RotarParteInicial(yICAi(1,:));

wi = EscalarComp(yICAi,saccades_arr(:,1:end));
yICAi(1,:) = wi(1) .* yICAi(1,:);
yICAi(2,:) = wi(2) .* yICAi(2,:);

yICA.C1 = yICAi(1,:);yICA.C2 = yICAi(2,:);

plot(yICA.C1)
hold('on')
plot(yICA.C2, 'r')

end

function CompCoef = EscalarComp(diICA,diSac) 
% Esta función debe escalar las 2 componentes que se obtienen con ICA,
% buscando los mejores coeficientes para que la suma de estas dos
% componentes se acerque lo más posible al promedio del ensemble de
% sácadas. si funciona bien de paso debe arreglar las componentes que están
% invertidas.
    PromSac = mean(diSac(:,1:end));
    w1 = diICA(1,:);
    w2 = diICA(2,:);
    CompCoef = fminsearch(@(a) SumComp(a,w1,w2,PromSac),[1 1]); 
%     doICA(1,:) = CompCoef(1) * w1;
%     doICA(2,:) = CompCoef(2) * w2;
end

function f = SumComp(a,x1,x2,x3)
    % Esta función es para minimizar los residuales entre la suma de las
    % dos componentes y el promedio del ensamblaje de sácadas. Es llamada
    % por fminsearch, para determinar los coeficientes de escalado de las
    % componentes que minimizan a estos residuales.

y = a(1).*x1+a(2).*x2-x3;
f = sum(y.^2);
end

function ya = RotarParteInicial(y)
% Esta función toma la parte inicial negativa de la componente de ICA y la
% rota, y desplaza el resto para empalmarlo

x=1:length(y);
yaa = y;
% plot(y);
st = (y<0);
stdif= st(2:end) - st(1:end-1);
ix1 = find(stdif ~= 0); % encontrar los ptos de cambio de signo
if(length(ix1) == 1) % si todos los valores antes del minimo fueron negativos
    ix1(2) = ix1(1); ix1(1) = 1; % pongo el primer cambio de signo en el primer valor
end
[m ixm1] = min(y);
ix2 = find(ix1>ixm1);
if(ix2 == 1); ix2 = 2; end; % para el caso de que llegue hasta el principio
ixi0 = ix1(ix2-1); % primer valor no negativo al arrancar desde el minimo hacia la izquierda
p1 = abs(y(ixm1) - y(ixi0)) / (ixm1-ixi0); % pendiente general desde el ultimo valor positivo hasta el minimo
p2 = abs(y(ixi0+1:ixm1) - y(ixi0:ixm1-1)); % pendientes individuales en ese mismo tramo
ix2 = find(p2>p1/4);
if isempty(ix2); ix2 = 1; end; % para el caso de que llegue hasta el principio
ixi =ixi0+ix2(1) - 1; % para que arranque cuando la pendiente cambie de verdad y no cuando los ptos sean neg
% ixi = ix1(1); %rotar a partir de donde cambió la pendiente fuertemente
% [m ixm1] = min(y(ix1(1):ix1(end))); % rotar hasta el mínimo de los negativos
ixm = ixm1;


y0 = y(ixm);
AnguloRot = atan((y(ixm) - y(ixi))/(x(ixm) - x(ixi))); % angulo que hay que restar


 % aplicar rotación con las x llevadas a cero
MatrizVector = [ x(ixi:ixm) - ixi; y(ixi:ixm); repmat(0,1,ixm-ixi+1)]
MatrizRot = [cos(AnguloRot) sin(AnguloRot) 0; -sin(AnguloRot) cos(AnguloRot) 0; 0 0 1 ]
N = MatrizRot * MatrizVector ;
y(ixi:ixm) = N(2,:); % al hacer esto estoy expandiendo el trozo inicial, que al rotarlo se había encogido
y(ixm+1:end) = y(ixm+1:end) + (y(ixm) - y0);
% plot(x,y);
ya= y;
a=5;
end
