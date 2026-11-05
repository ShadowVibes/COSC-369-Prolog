:- use_module(library(readutil)).

:- ensure_loaded('constraints.pl').
:- ensure_loaded('jobs.pl').
:- ensure_loaded('scheduler.pl').
:- ensure_loaded('queue.pl').
:- ensure_loaded('assistant.pl').

start :-
    writeln('AI PERSONAL SCHEDULER'),
    menu.

menu :-
    nl,
    writeln('1. View all jobs'),
    writeln('2. Search for a job'),
    writeln('3. Add a job'),
    writeln('4. Remove a job'),
    writeln('5. Find jobs by duration or deadline'),
    writeln('6. Generate daily schedule'),
    writeln('7. Edit an existing job'),
    writeln('8. View current queue and job status'),
    writeln('9. Advance time / complete next task'),
    writeln('10. Manage work hours and breaks'),
    writeln('11. View daily summary'),
    writeln('12. Ask planning assistant'),
    writeln('13. Exit'),
    read_number('Choice', C),
    !,
    dispatch(C).

menu :-
    writeln('Invalid input.'),
    menu.

dispatch(13) :-
    !,
    writeln('Goodbye.').

dispatch(C) :-
    ( C = 1 -> view_jobs
    ; C = 2 -> search_job
    ; C = 3 -> add_job, replan
    ; C = 4 -> remove_job, replan
    ; C = 5 -> find_jobs
    ; C = 6 -> generate_schedule
    ; C = 7 -> edit_job, replan
    ; C = 8 -> show_queue
    ; C = 9 -> advance_time
    ; C = 10 -> manage_constraints
    ; C = 11 -> summary
    ; C = 12 -> assistant
    ; writeln('Unknown option.')
    ),
    menu.