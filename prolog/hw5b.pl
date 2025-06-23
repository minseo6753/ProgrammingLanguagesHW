n_queen(N,X):-insert([],N,1,N,X).

insert(Li,0,_,_,Li).
insert(Li,Row,Col,N,X):-
        Col=<N, !,
        (check(Col,Li,1)->
        Row2 is Row-1, insert([Col|Li],Row2,1,N,X);
        Col2 is Col+1, insert(Li,Row,Col2,N,X)).
insert([H|T],Row,Col,N,X):-
        Col>N,
        Row2 is Row+1, H2 is H+1, insert(T,Row2,H2,N,X).

check(Target,[H|T],Dist):-
        !,Target=\=H,
        abs(Target-H)=\=Dist,
        Dist2 is Dist+1, check(Target,T,Dist2).
check(_,[],_).