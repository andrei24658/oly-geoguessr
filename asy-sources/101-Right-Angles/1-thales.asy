filldraw(unitcircle, opacity(0.1)+lightblue, blue);
pair A = dir(70);
pair C = -A;
pair B = conj(C);
pair O = (0,0);
draw(A--B--C, blue);

real r = 0.05;
pair X = B+r*dir(0);
pair Y = B+r*dir(270);
draw(X--(X+Y-B)--Y);

dot("$A$", A, A);
dot("$B$", B, B);
dot("$C$", C, C);
dot("$O$", O, dir(-B));

/*
  Source: Thale's Theorem
  Points: A O B C
  Item: A O C
  Text: Assume $\angle ABC = 90^{\circ}$.
*/
