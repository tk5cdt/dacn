import 'dart:js_interop';

import 'package:api_repository/api_repository.dart';
import 'package:conexion/todos/cubit/todos_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TodosPage extends StatelessWidget {
  const TodosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TodosCubit(
        apiRepository: context.read<ApiRepository>(),
      ),
      child: const TodoView(),
    );
  }
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  @override
  void initState() {
    super.initState();
    context.read<TodosCubit>().fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    final todos = context.select((TodosCubit bloc) => bloc.state);
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo),
                );
              },
              itemCount: todos.length,
            ),
          ),
        ],
      ),
    );
  }
}
