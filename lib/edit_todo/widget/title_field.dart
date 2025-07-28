import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/l10n/l10n.dart';

class TitleField extends StatelessWidget {
  const TitleField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EditTodoBloc, EditTodoState>(
      builder: (context, state) {
        final hintText = state.initialTodo?.title ?? '';

        return TextFormField(
          key: const Key('editTodoView_title_textFormField'),
          initialValue: state.title,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: l10n.editTodoTitleLabel,
            hintText: hintText,
          ),
          maxLength: 50,
          inputFormatters: [
            LengthLimitingTextInputFormatter(50),
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
          ],
          onChanged: (value) {
            context.read<EditTodoBloc>().add(EditTodoTitleChanged(value));
          },
        );
      },
    );
  }
}
