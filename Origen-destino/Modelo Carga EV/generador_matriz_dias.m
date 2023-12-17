%Entrega info de cantidad, duración y distancia de viaje del usuario basado
%en los datos de la encuesta de origen destino
function matriz_viaje = generador_matriz_dias(n_viajes,data_viajes)
%% Crear matriz de viaje
matriz_viaje1 = zeros(n_viajes,4);
vector_prohibido = zeros(1,24);
f = 0;
if n_viajes == 1% aplica solo para 1 viajes
    while f == 0
        x = random('Discrete Uniform',size(data_viajes,1)); %selecciona un valor aleatorio de la matriz de datos de viaje 
        inicio = data_viajes(x,1); %inicio de viaje
        duracion = data_viajes(x,3); %duracion de viaje
        %% Intervalo de duración correcto de viaje
        dur = round(duracion);
        if dur >= duracion
            duracion = dur;
        else
            duracion = dur + 1;
        end
        if inicio+duracion <= 24
            matriz_viaje(1,:) = data_viajes(1,:);
            f = 1;
        end
    end
else % aplica para viajes mayores a 1
    x = random('Discrete Uniform',size(data_viajes,1)); %selecciona un valor aleatorio de la matriz de datos de viaje 
    matriz_viaje1(1,:) = data_viajes(x,:);
    inicio = matriz_viaje1(1,1); %inicio de viaje
    duracion = matriz_viaje1(1,3); %duracion de viaje
    %% Intervalo de duración correcto de viaje
    dur = round(duracion);
    if dur >= duracion
        duracion = dur;
    else
        duracion = dur + 1;
    end
    %% Inicio de comprobacion de viajes validos
    if duracion <= 1 %duracion < 1 hora
        vector_prohibido(1,matriz_viaje1(1,1)) = 1;
    else
        vector_prohibido(1,[inicio:inicio+duracion]) = 1;
    end
    %% Asignacion de viajes
    k = 2;
    while k < n_viajes + 1
        flag =0;
        %x = 56019;
        x = random('Discrete Uniform',size(data_viajes,1)); %selecciona un valor aleatorio de la matriz de datos de viaje 
        inicio = data_viajes(x,1); %inicio de viaje
        duracion = data_viajes(x,3); %duracion de viaje
        %% Intervalo de duración correcto de viaje
        dur = round(duracion);
        if dur >= duracion
            duracion = dur;
        else
            duracion = dur + 1;
        end
        %% Condicion de duracion
        if inicio+duracion>24
            flag = 1;
        elseif duracion <= 1 && vector_prohibido(1,inicio) == 0 && flag == 0
            matriz_viaje1(k,:) = data_viajes(x,:);
            vector_prohibido(1,inicio) = 1;
            k = k +1;
        elseif duracion > 1 && flag == 0 && isequal(ones(1,duracion),vector_prohibido(1,[inicio:inicio+duracion]) == 0)
            matriz_viaje1(k,:) = data_viajes(x,:);
            vector_prohibido(1,[inicio:inicio+duracion]) = 1;
            k = k +1;
        end   
    end
    [~,idx] = sort(matriz_viaje1(:,1)); % sort just the first column
    matriz_viaje = matriz_viaje1(idx,:); 
end

