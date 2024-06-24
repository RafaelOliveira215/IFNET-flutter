import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/task_form.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Task> taskList = [];
  final List<TextEditingController> _controllers = []; // List of controllers

  @override
  void initState() {
    super.initState();
    gettasks();
  }

  Future<void> gettasks() async {
    var dbTaskList = await FirebaseFirestore.instance
        .collection('todo')
        .doc('todolist')
        .get();

    var tasksData = dbTaskList.data()?['tasks'] ?? [];
    setState(() {
      taskList = tasksData
          .map<Task>((task) => Task(
                description: task['description'],
                date: task['date'],
              ))
          .toList();

      _controllers.addAll(taskList
          .map((task) => TextEditingController(text: task.description)));
    });
  }

  void addTask(Task task) {
    var data = <String, dynamic>{
      'tasks': FieldValue.arrayUnion([
        {
          'description': task.description,
          'date': task.date,
        }
      ])
    };

    var insertData = db.collection('todo').doc('todolist').update(data);

    insertData.then((_) => {
          setState(() {
            taskList.add(task);
            _controllers.add(TextEditingController(text: task.description));
          })
        });
  }

  void deleteTask(int index) {
    setState(() {
      taskList.removeAt(index);
      _controllers.removeAt(index);
    });
  }

  void editTask(String value, int index) {
    setState(() {
      taskList[index].description = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      body: Column(
        children: [
          TaskForm(
            actionAddTask: addTask,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                TextEditingController controller = _controllers[index];

                return ListTile(
                  title: EditableText(
                    controller: controller,
                    focusNode: FocusNode(),
                    style: const TextStyle(fontSize: 18),
                    cursorColor: Colors.blue,
                    backgroundCursorColor: Colors.blue,
                    onChanged: (value) {
                      editTask(value, index);
                    },
                  ),
                  subtitle: Text(
                    taskList[index].date,
                  ),
                  leading: const Icon(
                    Icons.circle,
                    size: 8,
                  ),
                  trailing: GestureDetector(
                    onTap: () {
                      deleteTask(index);
                    },
                    child: const Icon(Icons.delete),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
