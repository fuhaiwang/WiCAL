function isVandermonde = isVandermondeMatrix(A)

    [m, n] = size(A);


    isVandermonde = true;

    for j = 1:n
   
        ratios = A(:,j) ./ A(1,j);


        if ~isequal(ratios, ratios(1) * (1:m-1).')

            isVandermonde = false;
            break;
        end
    end
end
