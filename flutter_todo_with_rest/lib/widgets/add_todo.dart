import 'package:flutter/material.dart';

class AddTodo extends StatefulWidget {
  final Function addTodo;

  AddTodo(this.addTodo, {Key? key}) : super(key: key);

  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Wrap(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: TextField(
              keyboardType: TextInputType.multiline,
              minLines: 2,
              maxLines: null,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(hintText: ' to do item'),
              controller: textController,
            ),
          ),
          ButtonBar(
            children: [
               ElevatedButton(
                child:  Text('Save'),
                onPressed: () async {
                  await widget.addTodo(textController.text);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

}