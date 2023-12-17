function PerfilesEV = importar_perfiles(filename)
%% Initialize variables.
delimiter = ',';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, '%f', 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN,  'ReturnOnError', false);
dato = cell2mat(dataArray);
a = contains(filename,'user_EV_Nev');
if a == 1
    PerfilesEV = dato;
else
    PerfilesEV = reshape(dato,8760,[]);
end
fclose(fileID);
end