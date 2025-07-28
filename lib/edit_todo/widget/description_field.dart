import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_todos/edit_todo/edit_todo.dart';
import 'package:flutter_todos/l10n/l10n.dart';

class DescriptionField extends StatelessWidget {
  const DescriptionField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EditTodoBloc, EditTodoState>(
      builder: (context, state) {
        final hintText = state.initialTodo?.description ?? '';

        return TextFormField(
          key: const Key('editTodoView_description_textFormField'),
          initialValue: state.description,
          decoration: InputDecoration(
            enabled: !state.status.isLoadingOrSuccess,
            labelText: l10n.editTodoDescriptionLabel,
            hintText: hintText,
          ),
          maxLength: 300,
          maxLines: 7,
          inputFormatters: [LengthLimitingTextInputFormatter(300)],
          onChanged: (value) {
            context.read<EditTodoBloc>().add(EditTodoDescriptionChanged(value));
          },
        );
      },
    );
  }
}
