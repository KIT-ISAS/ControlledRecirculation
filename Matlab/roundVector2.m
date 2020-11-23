function [b] = roundVector2(a)
%roundVector2 Rundet einen 2-Vektor so, dass die Summe des Vektors sich
%nicht ändert. Dabei wird mit Hilfe einer Pseudo-Zufallszahl entschieden ob
%die erste Zahl nach oben oder nach unten gerundet wird. 
%ANMERKUNG: Ist es klug diese Funktion nicht deterministisch zu modellieren?
t = randi(2,1);
b = a;
if t == 1
    b(1) = floor(a(1));
    b(2) = ceil(a(2));
else
    b(1) = ceil(a(1));
    b(2) = floor(a(2));
end
end

