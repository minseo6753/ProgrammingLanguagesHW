sorting(Init,Sorted):-insert_sort(Init,[],Sorted).

insert_sort([H|T],Temp,Sorted):-
        insert(H,Temp,Inserted),
        append(Inserted,T,C),write(C),nl,
        insert_sort(T,Inserted,Sorted).
insert_sort([],Li,Li).

insert(X,[Y|T],[Y|Inserted]):-X>Y,insert(X,T,Inserted).
insert(X,[Y|T],[X,Y|T]):-X=<Y.
insert(X,[],[X]).