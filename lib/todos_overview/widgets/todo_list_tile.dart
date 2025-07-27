import 'package:flutter/material.dart';
import 'package:todos_repository/todos_repository.dart';

class TodoListTile extends StatelessWidget {
  final Todo todo;
  final DismissDirectionCallback? onDismissed;
  final ValueChanged<bool>? onToggleCompleted;
  final VoidCallback? onTap;

  const TodoListTile({
    required this.todo,
    super.key,
    this.onDismissed,
    this.onToggleCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final captionColor = theme.textTheme.bodySmall?.color;

    return Dismissible(
      key: Key('todoListTile_dismissible_${todo.id}'),
      onDismissed: onDismissed,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        color: theme.colorScheme.error,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Color(0xAAFFFFFF)),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          todo.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: !todo.isCompleted
              ? null
              : TextStyle(color: captionColor, decoration: TextDecoration.lineThrough),
        ),
        subtitle: Text(todo.description, maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: Checkbox(
          shape: const ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          value: todo.isCompleted,
          onChanged: onToggleCompleted == null ? null : (value) => onToggleCompleted!(value!),
        ),
        trailing: onTap == null ? null : const Icon(Icons.chevron_right),
      ),
    );
  }
}
