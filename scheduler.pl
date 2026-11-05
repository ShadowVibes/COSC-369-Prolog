:- use_module(library(lists)).

:- dynamic planned/3, plan_note/1.

pending_jobs(Js) :-
    findall(
        J,
        (job(J,_,_,_,_), \+ completed(J,_,_,_)),
        Js
    ).

flexible_job(J) :-
    job(J,_,_,_,_),
    \+ fixed_time(J,_).

earliest(none, T, T) :-
    !.

earliest(A, T, S) :-
    S is max(A, T).

within_deadline(none, _) :-
    !.

within_deadline(D, F) :-
    F =< D.

feasible(J, T, S, F) :-
    flexible_job(J),
    job(J, A, D, Due, _),
    earliest(A, T, Start),
    next_slot(Start, D, S, F),
    within_deadline(Due, F).

score_job(J, T, Key) :-
    job(J,_,D,Due,P),
    ( number(Due) ->
        Urgency is max(0, Due - T - D)
    ;
        Urgency = 1000
    ),
    Key is Urgency - 120 * P + D.

compare_job(T, Delta, A, B) :-
    score_job(A, T, KA),
    score_job(B, T, KB),
    ( KA =:= KB ->
        compare(Delta, A, B)
    ;
        compare(Delta, KA, KB)
    ).

ordered_feasible(Js, T, Ordered) :-
    include(can_fit(T), Js, Possible),
    predsort(compare_job(T), Possible, Ordered).

can_fit(T, J) :-
    feasible(J, T, _, _).

greedy_plan([], _, []).

greedy_plan(Js, T, [slot(J,S,F)|Rest]) :-
    ordered_feasible(Js, T, [J|_]),
    !,
    feasible(J, T, S, F),
    select(J, Js, Remaining),
    greedy_plan(Remaining, F, Rest).

greedy_plan(_, _, []).

search_plan(Js, T, Limit, Plan) :-
    Limit > 0,
    ordered_feasible(Js, T, Ordered),
    member(J, Ordered),
    feasible(J, T, S, F),
    select(J, Js, Left),
    L is Limit - 1,
    search_plan(Left, F, L, Rest),
    Plan = [slot(J,S,F)|Rest].

search_plan(_, _, _, []).

plan_value(Plan, Value) :-
    findall(
        P,
        (
            member(slot(J,_,_), Plan),
            job(J,_,_,_,P)
        ),
        Ps
    ),
    sum_list(Ps, Total),
    length(Plan, N),
    Value is Total * 100 + N.

better(A, B, A) :-
    plan_value(A, VA),
    plan_value(B, VB),
    VA > VB,
    !.

better(_, B, B).

optimized(Js, T, Plan, Mode) :-
    length(Js, N),
    ( N =< 7 ->
        findall(
            P,
            search_plan(Js, T, N, P),
            Plans
        ),
        foldl(better, Plans, [], Plan),
        Mode = 'exhaustive backtracking'
    ;
        greedy_plan(Js, T, Base),
        ordered_feasible(Js, T, Ordered),
        length(Ordered, Available),
        K is min(5, Available),
        length(Short, K),
        append(Short, _, Ordered),
        findall(
            P,
            (
                member(J, Short),
                feasible(J, T, S, F),
                select(J, Js, Left),
                greedy_plan(Left, F, Tail),
                P = [slot(J,S,F)|Tail]
            ),
            Candidates
        ),
        foldl(better, Candidates, Base, Plan),
        Mode = 'priority-aware greedy with bounded backtracking'
    ).

fixed_plan(Plan) :-
    current_time(T),
    findall(
        slot(J,S,F),
        (
            fixed_time(J, S),
            job(J,_,D,_,_),
            \+ completed(J,_,_,_),
            F is S + D,
            work_hours(W, E),
            S >= W,
            S >= T,
            F =< E,
            slot_clear_except(J, S, F)
        ),
        Plan
    ).

slot_clear_except(J, S, F) :-
    \+ (
        break_time(B, E),
        S < E,
        F > B
    ),
    \+ (
        fixed_time(K, B),
        K \= J,
        job(K,_,D,_,_),
        E is B + D,
        S < E,
        F > B
    ).

clear_plan :-
    retractall(planned(_,_,_)),
    retractall(plan_note(_)).

replan :-
    current_time(T),
    pending_jobs(All),
    include(flexible_job, All, Js),
    optimized(Js, T, Flex, Mode),
    fixed_plan(Fixed),
    append(Flex, Fixed, Combined),
    sort(2, @=<, Combined, Sorted),
    clear_plan,
    forall(
        member(slot(J,S,F), Sorted),
        assertz(planned(J,S,F))
    ),
    assertz(plan_note(Mode)).

generate_schedule :-
    replan,
    show_plan.

show_plan :-
    ( plan_note(Mode) ->
        format('Planning method: ~w~n', [Mode])
    ;
        writeln('No plan yet.')
    ),
    findall(
        slot(J,S,F),
        planned(J,S,F),
        Plan
    ),
    ( Plan = [] ->
        writeln('No feasible remaining tasks.')
    ;
        forall(
            member(slot(J,S,F), Plan),
            (
                clock_text(S, SS),
                clock_text(F, FS),
                name_text(J, N),
                ( fixed_time(J,_) ->
                    Tag = ' [FIXED]'
                ;
                    Tag = ''
                ),
                format(
                    '~w - ~w | ~w~w~n',
                    [SS, FS, N, Tag]
                )
            )
        )
    ),
    pending_jobs(All),
    findall(J, planned(J,_,_), Selected),
    subtract(All, Selected, Unscheduled),
    length(Selected, C),
    length(Unscheduled, U),
    format(
        'Scheduled: ~d | Not scheduled: ~d~n',
        [C, U]
    ),
    forall(
        member(J, Unscheduled),
        (
            name_text(J, N),
            format('  Not scheduled: ~w~n', [N])
        )
    ).