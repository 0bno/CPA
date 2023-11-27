% On charge les 3 matrices utiles à l'exécution du code.
load('traces1000x512.mat');
load('SubBytes.mat');
load('Inputs.mat');

% On crée une sous clé composée des valeurs 0 à 255 afin de simuler les
% valeurs possibles de la clé
sub_key = 0:255;

% On créé les matrices vides de 1000 lignes par 256 colonnes à afin de
% stocker les résultats des différentes étapes (addRoundKey & SubBytes) 
mat_addRoundKey = zeros(1000,256);
mat_Hamming = zeros(1000,256);

% On réalise une boucle qui permet de parcourir toutes les cases des
% matrices de 1000 lignes et 256 colones
for i = 1:1000
    for j = 1:256
        
        % On réalise un XOR entre les entrées stockées dans Inputs1 et la sous clé sub_key précédemmet créée
        % grâce à la fonction bitxor, ce qui correspond à une étape de addRoundKey. On stocke le résultat dans la matrice mat_addRoundKey
        mat_addRoundKey(i,j) = bitxor(Inputs1(i), sub_key(j));

        % On effectue ensuite l'opération de SubBytes que l'on stocke dans
        % la variable result_SubBytes. On rajoute le + 1 car l'indice d'une
        % matrice commence à 0 et dans notre cas, les variables utilisées
        % dans les boucles commencent à 1
        result_SubBytes = SubBytes(mat_addRoundKey(i, j) + 1);

        % On calcule ensuite la somme des résultats du subBytes convertis de
        % décimal à binaire sur 8 bits (grâce à la fonction de2bi et son 
        % second paramètre placé à 8 qui sera le poids.
        height = sum(de2bi(result_SubBytes, 8));
        
        % On écrit chaque poids dans la matrice des Poids de Hamming
        mat_Hamming(i, j) = height;
    end
end

% On calcule ensuite les coefficients de corrélation pour chaque valeur possible de
% l'octet de clé et on détermine l'octet de clé correct. Pour celà, on utilise la fonction corrcoef
% de MATLAB pour calculer les coefficients de corrélation, puis on stocke les valeurs maximales
% de corrélation dans une matrice (mat_final).

value_correlation = zeros(256, 512);
mat_final = zeros(1,256);

% Boucle sur chaque valeur possible de l'octet de clé
for i = 1:256
    % Boucle sur chaque colonne des traces 
    for j = 1:512
        % On calcule le coefficient de corrélation entre les trace et les poids de Hamming
        mat_correlation = corrcoef(mat_Hamming(:, i), traces(:, j));

        % On stocke la valeur absolue du coefficient de corrélation dans la matrice value_correlation
        value_correlation(i, j) = abs(mat_correlation(1, 2));
    end

    % On calcule et on stocke la valeur maximale de corrélation dans mat_final
    mat_final(i) = max(value_correlation(i, :));
end

% On calcule la valeur maximale dans mat_final ainsi que sa position
max_correlation = max(mat_final);
key_index = find(mat_final == max_correlation);

% Affichage de la valeur maximale de corrélation et sa position
message_key_index = sprintf("L'indice du premier octet de la clé de chiffrement est de %d.",key_index);
message_max_correlation = sprintf("La valeur maximale de corrélation pour le premier octet de la clé de chiffrement est de %f.",max_correlation);
disp(message_key_index);
disp(message_max_correlation);

% L'octet de clé correct est la position -1 dans la matrice finale car nous
% travaillons avec des indices allant de 1 à 256 mais les indices de la
% matrices vont eux de 0 à 256
correct_key_index = key_index - 1;
message_final = sprintf("Le premier octet de la clé de chiffrement est donc %d.",correct_key_index);
disp(message_final);

% Pour finir, on affiche les graphes 2D et 3D qui représentent la
% correlation entre les poids de Hamming et les traces.

%Affichage des graphes sur un seul onglet
tiledlayout(2,1)

% Création d'un graphique représentant le matrice finale mat_final 
% (valeurs maximales de corrélation pour chaque octet de clé possible)
nexttile
plot(mat_final);
title("Corrélation entre les poids de Hamming et les traces en 2D")
colorbar

% Création d'un graphique en 3D représentant la matrice value_correlation 
% (coefficients de corrélation entre les poids de Hamming et les traces)
nexttile
surf(value_correlation);
title("Corrélation entre les poids de Hamming et les traces en 3D")
colorbar

