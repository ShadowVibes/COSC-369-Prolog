:- dynamic work_hours/2, break_time/2.

work_hours(540,1020).
break_time(720,750).

clock_text(M, Text) :-
    H24 is M // 60,
    N is M mod 60,
    ( H24 < 12 ->
        Period = 'AM'
    ;
        Period = 'PM'
    ),
    H12 is H24 mod 12,
    ( H12 =:= 0 ->
        H = 12
    ;
        H = H12
    ),
    format(
        string(Text),
        '~d:~|~`0t~d~2+ ~w',
        [H, N, Period]
    ).

parse_clock(S, M) :-
    normalize_space(string(Clean), S),
    string_upper(Clean, Upper),
    split_string(Upper, " ", " ", Parts),
    ( Parts = [Time, Period] ->
        member(Period, ["AM", "PM"]),
        split_string(Time, ":", "", [HS, MS]),
        number_string(H, HS),
        number_string(N, MS),
        integer(H),
        integer(N),
        between(1, 12, H),
        between(0, 59, N),
        ( Period = "AM" ->
            H24 is H mod 12
        ;
            H24 is (H mod 12) + 12
        ),
        M is H24 * 60 + N
    ;
        Parts = [Time],
        split_string(Time, ":", "", [HS, MS]),
        number_string(H24, HS),
        number_string(N, MS),
        integer(H24),
        integer(N),
        between(0, 23, H24),
        between(0, 59, N),
        M is H24 * 60 + N
    ).

read_clock(Label, M) :-
    format('~w (example: 2:30 PM): ', [Label]),
    read_line_to_string(user_input, S),
    ( parse_clock(S, M) ->
        true
    ;
        writeln('Invalid time. Use a format like 2:30 PM.'),
        read_clock(Label, M)
    ).

blocked(B, E) :-
    break_time(B, E).

blocked(B, E) :-
    fixed_time(J, B),
    job(J,_,D,_,_),
    E is B + D,
    \+ completed(J,_,_,_).

slot_clear(S, F) :-
    \+ (
        blocked(B, E),
        S < E,
        F > B
    ).

next_slot(T, D, S, F) :-
    work_hours(W, E),
    S0 is max(T, W),
    shift_past_blocks(S0, D, S),
    F is S + D,
    F =< E.

shift_past_blocks(T, D, S) :-
    F is T + D,
    findall(
        E,
        (blocked(B, E), T < E, F > B),
        Ends
    ),
    ( Ends = [] ->
        S = T
    ;
        max_list(Ends, Next),
        shift_past_blocks(Next, D, S)
    ).

show_constraints :-
    work_hours(A, B),
    clock_text(A, AS),
    clock_text(B, BS),
    format('Work hours: ~w - ~w~n', [AS, BS]),
    forall(
        break_time(X, Y),
        (
            clock_text(X, XS),
            clock_text(Y, YS),
            format('Break: ~w - ~w~n', [XS, YS])
        )
    ).

set_hours :-
    read_clock('Start', A),
    read_clock('End', B),
    A < B,
    retractall(work_hours(_,_)),
    assertz(work_hours(A, B)),
    retractall(break_time(_,_)),
    writeln('Hours updated; breaks cleared. Re-add breaks if needed.'),
    !.

set_hours :-
    writeln('Invalid work hours.').

add_break :-
    read_clock('Break start', A),
    read_clock('Break end', B),
    work_hours(W, E),
    W =< A,
    A < B,
    B =< E,
    \+ (
        break_time(X, Y),
        A < Y,
        B > X
    ),
    \+ (
        fixed_time(J, S),
        job(J,_,D,_,_),
        F is S + D,
        A < F,
        B > S
    ),
    assertz(break_time(A, B)),
    writeln('Break added.'),
    !.

add_break :-
    writeln('Invalid or overlapping break.').

manage_constraints :-
    show_constraints,
    writeln('1. Set work hours'),
    writeln('2. Add break'),
    writeln('3. Clear breaks'),
    writeln('4. Back'),
    read_number('Choice', C),
    ( C = 1 ->
        set_hours,
        reconfigure_day
    ; C = 2 ->
        add_break,
        reconfigure_day
    ; C = 3 ->
        retractall(break_time(_,_)),
        writeln('Breaks cleared.'),
        reconfigure_day
    ;
        true
    ).

reconfigure_day :-
    clear_plan,
    work_hours(W,_),
    current_time(T),
    ( T < W ->
        retractall(current_time(_)),
        assertz(current_time(W))
    ;
        true
    ),
    writeln('Schedule cleared. Generate a new schedule.').