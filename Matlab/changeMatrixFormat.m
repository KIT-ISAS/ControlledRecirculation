function [B] = changeMatrixFormat(A)
%changeMatrixFormat Wandelt eine 2x2 Matrix in eine 4x2 Matrix um
B = zeros(4,2);
B(1,1) = A(1,1);
B(2,2) = A(1,2);
B(3,1) = A(2,1);
B(4,2) = A(2,2);
end

