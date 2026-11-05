:- dynamic job/5, completed/4, fixed_time/2.

% job(Name, EarliestStart, Duration, Deadline, Priority).

job(respond_to_emails,none,20,none,2).
job(review_schedules,none,15,630,3).
job(process_payments,none,30,660,4).
job(update_inventory,none,45,none,3).
job(assist_customers,none,30,none,4).
job(prepare_reports,none,60,840,3).
job(organize_supplies,none,15,none,1).
job(prepare_customer_orders,none,25,690,4).
job(train_new_employees,none,45,none,2).
job(restock_shelves,none,20,none,2).
job(deep_cleaning,none,40,none,1).
job(develop_marketing_campaign,none,50,none,2).
job(attend_staff_meeting,none,30,none,5).
job(review_customer_feedback,none,20,none,3).
job(update_employee_records,none,25,none,3).
job(check_equipment,none,15,none,4).
job(prepare_weekly_budget,none,40,960,4).
job(contact_suppliers,none,20,780,3).
job(review_project_progress,none,30,none,4).
job(complete_training_module,none,45,none,2).
job(organize_workspace,none,15,none,1).
job(submit_expense_report,none,20,900,4).
job(schedule_appointments,none,25,none,3).
job(review_upcoming_deadlines,none,15,none,4).
job(update_project_documentation,none,35,none,3).

fixed_time(attend_staff_meeting,750).

read_text(Label, S) :-
    format('~w: ', [Label]),
    read_line_to_string(user_input, S).

read_number(Label, N) :-
    read_text(Label, S),
    catch(number_string(N, S), _, fail),
    integer(N),
    !.

read_number(_, _) :-
    writeln('Please enter a whole number.'),
    fail.

job_name(S, A) :-
    normalize_space(string(T), S),
    T \= "",
    string_lower(T, L),
    split_string(L, ' ', ' ', Parts),
    atomic_list_concat(Parts, '_', A).

name_text(A, S) :-
    atomic_list_concat(P, '_', A),
    atomic_list_concat(P, ' ', S).

time_label(none, 'none') :-
    !.

time_label(T, S) :-
    clock_text(T, S).

job_row(J) :-
    job(J, A, D, Due, P),
    name_text(J, N),
    time_label(A, AS),
    time_label(Due, DS),
    ( fixed_time(J, T) ->
        clock_text(T, TS),
        format(
            '~w | FIXED ~w | ~d min | priority ~d~n',
            [N, TS, D, P]
        )
    ;
        format(
            '~w | ~d min | priority ~d | earliest ~w | deadline ~w~n',
            [N, D, P, AS, DS]
        )
    ).

view_jobs :-
    findall(J, job(J,_,_,_,_), Js),
    length(Js, N),
    format('~d tasks:~n', [N]),
    forall(member(J, Js), job_row(J)).

search_job :-
    read_text('Task name', S),
    ( job_name(S, J), job(J,_,_,_,_) ->
        job_row(J)
    ;
        writeln('Task not found.')
    ).

optional_clock(Label, T) :-
    format('~w (example: 2:30 PM, or blank for none): ', [Label]),
    read_line_to_string(user_input, S),
    normalize_space(string(Clean), S),
    ( Clean = "" ->
        T = none
    ;
        parse_clock(Clean, T)
    ).

input_job(J, A, D, Due, P, Type, Fixed) :-
    read_text('Task name', S),
    job_name(S, J),
    read_number('Duration in minutes', D),
    D > 0,
    read_number('Priority (1 low - 5 high)', P),
    between(1, 5, P),
    writeln('1. Flexible'),
    writeln('2. Deadline-based'),
    writeln('3. Fixed appointment'),
    read_number('Type', Type),
    between(1, 3, Type),
    ( Type = 3 ->
        read_clock('Fixed start', Fixed),
        A = none,
        Due = none
    ;
        Fixed = none,
        optional_clock('Earliest start', A),
        ( Type = 2 ->
            read_clock('Deadline', Due)
        ;
            Due = none
        )
    ),
    ( A == none ; Due == none ; Due > A ).

add_job :-
    ( input_job(J, A, D, Due, P, Type, Fixed) ->
        ( job(J,_,_,_,_) ->
            writeln('That task already exists.')
        ;
            assertz(job(J, A, D, Due, P)),
            ( Type = 3 ->
                assertz(fixed_time(J, Fixed))
            ;
                true
            ),
            writeln('Task added. Re-generate schedule to view changes.')
        )
    ;
        writeln('Invalid task details.')
    ).

remove_job :-
    read_text('Task name to remove', S),
    ( job_name(S, J) ->
        retractall(job(J,_,_,_,_)),
        retractall(fixed_time(J,_)),
        retractall(completed(J,_,_,_)),
        writeln('Task removed if present.')
    ;
        writeln('Invalid name.')
    ).

edit_job :-
    read_text('Task to edit', S),
    ( job_name(S, J), job(J,_,_,_,_) ->
        ( input_job(New, A, D, Due, P, Type, Fixed) ->
            ( New \= J, job(New,_,_,_,_) ->
                writeln('New name already exists.')
            ;
                retractall(job(J,_,_,_,_)),
                retractall(fixed_time(J,_)),
                retractall(completed(J,_,_,_)),
                assertz(job(New, A, D, Due, P)),
                ( Type = 3 ->
                    assertz(fixed_time(New, Fixed))
                ;
                    true
                ),
                writeln('Task updated.')
            )
        ;
            writeln('Invalid details.')
        )
    ;
        writeln('Task not found.')
    ).

find_jobs :-
    writeln('1. Duration at most N'),
    writeln('2. Duration at least N'),
    writeln('3. Due by a specific time'),
    read_number('Choice', C),
    ( C = 1 ->
        read_number('Maximum minutes', N),
        forall(
            (job(J,_,D,_,_), D =< N),
            job_row(J)
        )
    ; C = 2 ->
        read_number('Minimum minutes', N),
        forall(
            (job(J,_,D,_,_), D >= N),
            job_row(J)
        )
    ; C = 3 ->
        ( read_clock('Deadline cutoff', T) ->
            forall(
                (job(J,_,_,Due,_), number(Due), Due =< T),
                job_row(J)
            )
        ;
            true
        )
    ;
        writeln('Invalid choice.')
    ).