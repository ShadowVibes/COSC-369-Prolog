assistant :-
    writeln('Questions:'),
    writeln('what is my longest task'),
    writeln('what is my shortest task'),
    writeln('how many tasks'),
    writeln('what is due next'),
    writeln('show schedule'),
    writeln('back'),
    assistant_loop.

assistant_loop :-
    read_text('Ask', S),
    normalize_space(string(Clean), S),
    string_lower(Clean, Lower),
    normalize_question(Lower, Question),
    ( Question = "back" ->
        true
    ;
        answer_question(Question),
        assistant_loop
    ).

normalize_question(Input, Output) :-
    ( sub_string(Input, Before, 1, 0, "?") ->
        sub_string(Input, 0, Before, _, WithoutMark)
    ;
        WithoutMark = Input
    ),
    normalize_space(string(Output), WithoutMark).

answer_question("how many tasks") :-
    !,
    findall(J, job(J,_,_,_,_), Js),
    length(Js, N),
    format('You have ~d tasks.~n', [N]).

answer_question("show schedule") :-
    !,
    show_plan.

answer_question("what is my longest task") :-
    !,
    findall(
        D-J,
        job(J,_,D,_,_),
        Pairs
    ),
    keysort(Pairs, Sorted),
    ( last(Sorted, D-J) ->
        name_text(J, N),
        format('~w (~d minutes).~n', [N, D])
    ;
        writeln('No tasks.')
    ).

answer_question("what is my shortest task") :-
    !,
    findall(
        D-J,
        job(J,_,D,_,_),
        Pairs
    ),
    keysort(Pairs, Sorted),
    ( Sorted = [D-J|_] ->
        name_text(J, N),
        format('~w (~d minutes).~n', [N, D])
    ;
        writeln('No tasks.')
    ).

answer_question("what is due next") :-
    !,
    findall(
        D-J,
        (
            job(J,_,_,D,_),
            number(D),
            \+ completed(J,_,_,_)
        ),
        Pairs
    ),
    keysort(Pairs, Sorted),
    ( Sorted = [D-J|_] ->
        name_text(J, N),
        clock_text(D, DS),
        format('~w due ~w.~n', [N, DS])
    ;
        writeln('No pending deadlines.')
    ).

answer_question(_) :-
    writeln('Question not recognized. Try one of the examples.').