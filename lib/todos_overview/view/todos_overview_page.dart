import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/edit_todo/view/edit_todo_page.dart';
import 'package:flutter_todos/l10n/l10n.dart';
import 'package:flutter_todos/todos_overview/todos_overview.dart';
import 'package:todos_repository/todos_repository.dart';

class TodosOverviewPage extends StatelessWidget {
  const TodosOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TodosOverviewBloc(todosRepository: context.read<TodosRepository>())
            ..add(const TodosOverviewSubscriptionRequested()),
      child: const TodosOverviewView(),
    );
  }
}

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.todosOverviewAppBarTitle),
        actions: const [TodosOverviewFilterButton(), TodosOverviewOptionsButton()],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) {
              if (state.status == TodosOverviewStatus.failure) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(l10n.todosOverviewErrorSnackbarText)));
              }
            },
          ),
          BlocListener<TodosOverviewBloc, TodosOverviewState>(
            listenWhen: (previous, current) =>
                previous.lastDeletedTodo != current.lastDeletedTodo &&
                current.lastDeletedTodo != null,
            listener: (context, state) {
              final deletedTodo = state.lastDeletedTodo!;
              final messenger = ScaffoldMessenger.of(context);
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(l10n.todosOverviewTodoDeletedSnackbarText(deletedTodo.title)),
                    action: SnackBarAction(
                      label: l10n.todosOverviewUndoDeletionButtonText,
                      onPressed: () {
                        messenger.hideCurrentSnackBar();
                        context.read<TodosOverviewBloc>().add(
                          const TodosOverviewUndoDeletionRequested(),
                        );
                      },
                    ),
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<TodosOverviewBloc, TodosOverviewState>(
          builder: (context, state) {
            if (state.todos.isEmpty) {
              // * 기존 코드
              // if (state.status == TodosOverviewStatus.loading) {
              //   return const Center(child: CupertinoActivityIndicator());
              // } else if (state.status != TodosOverviewStatus.success) {
              //   return const SizedBox();
              // } else {
              //   return Center(
              //     child: Text(
              //       l10n.todosOverviewEmptyText,
              //       style: Theme.of(context).textTheme.bodySmall,
              //     ),
              //   );
              // }

              // * switch문으로 리팩토링한 코드
              switch (state.status) {
                case TodosOverviewStatus.initial:
                  // 앱이 시작되고 아직 아무런 데이터도 로딩되지 않은 상태
                  // 보통은 아무것도 보여주지 않거나, Splash/Placeholder 등을 보여줄 수 있습니다.
                  return const SizedBox();

                case TodosOverviewStatus.loading:
                  // 데이터 로딩 중
                  return const Center(child: CupertinoActivityIndicator());

                case TodosOverviewStatus.success:
                  // 데이터는 성공적으로 불러왔으나, 할 일이 없음
                  return Center(
                    child: Text(
                      l10n.todosOverviewEmptyText,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );

                case TodosOverviewStatus.failure:
                  // 데이터 로딩 실패
                  return Center(
                    child: Text(
                      l10n.todosOverviewErrorSnackbarText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
                    ),
                  );
              }
            }

            return CupertinoScrollbar(
              child: ListView.builder(
                itemCount: state.filteredTodos.length,
                itemBuilder: (_, index) {
                  final todo = state.filteredTodos.elementAt(index);
                  return TodoListTile(
                    todo: todo,
                    onToggleCompleted: (isCompleted) {
                      context.read<TodosOverviewBloc>().add(
                        TodosOverviewTodoCompletionToggled(todo: todo, isCompleted: isCompleted),
                      );
                    },
                    onDismissed: (_) {
                      context.read<TodosOverviewBloc>().add(TodosOverviewTodoDeleted(todo));
                    },
                    onTap: () {
                      Navigator.of(context).push(EditTodoPage.route(initialTodo: todo));
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// for commit
