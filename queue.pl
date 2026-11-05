:- dynamic current_time/1.

current_time(540).

reset_day :-
    work_hours(W,_),
    retractall(current_time(_)),
    assertz(current_time(W)),
    retractall(completed(_,_,_,_)),
    clear_plan,
    writeln('Day reset.').

show_queue :-
    current_time(T),
    clock_text(T, TS),
    format('Simulated time: ~w~n', [TS]),
    ( planned(_,_,_) ->
        true
    ;
        replan
    ),
    findall(
        slot(J,S,F),
        planned(J,S,F),
        Plan
    ),
    forall(
        member(slot(J,S,F), Plan),
        (
            name_text(J, N),
            clock_text(S, SS),
            clock_text(F, FS),
            Wait is max(0, S - T),
            format(
                '~w | ~w-~w | begins in ~d min~n',
                [N, SS, FS, Wait]
            )
        )
    ),
    findall(
        J,
        completed(J,_,_,_),
        Done
    ),
    length(Done, C),
    format('Completed tasks: ~d~n', [C]).

advance_time :-
    ( planned(_,_,_) ->
        true
    ;
        replan
    ),
    findall(
        S-slot(J,S,F),
        planned(J,S,F),
        Pairs
    ),
    keysort(Pairs, Sorted),
    ( Sorted = [_-slot(J,S,F)|_] ->
        retractall(current_time(_)),
        assertz(current_time(F)),
        assertz(completed(J,S,F,on_time)),
        name_text(J, N),
        clock_text(F, FS),
        format('Finished ~w at ~w.~n', [N, FS]),
        replan
    ;
        writeln('No more scheduled tasks. Generate or adjust your schedule.')
    ).

summary :-
    current_time(T),
    clock_text(T, TS),
    format('Current time: ~w~n', [TS]),
    findall(
        J,
        job(J,_,_,_,_),
        All
    ),
    length(All, N),
    findall(
        J,
        completed(J,_,_,_),
        Done
    ),
    length(Done, C),
    pending_jobs(Pending),
    length(Pending, R),
    findall(
        J,
        planned(J,_,_),
        Scheduled
    ),
    length(Scheduled, S),
    Unscheduled is R - S,
    format(
        'Total ~d | Completed ~d | Pending ~d | Scheduled ~d | Unscheduled ~d~n',
        [N, C, R, S, Unscheduled]
    ),
    findall(
        W,
        (
            completed(J,Start,_,_),
            job(J,A,_,_,_),
            number(A),
            W is max(0, Start - A)
        ),
        Ws
    ),
    ( Ws = [] ->
        Avg = 0
    ;
        sum_list(Ws, Sum),
        length(Ws, L),
        Avg is Sum / L
    ),
    format(
        'Average wait for tasks with release times: ~1f minutes~n',
        [Avg]
    ).