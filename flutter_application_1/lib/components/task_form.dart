import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';

class TaskForm extends StatelessWidget {
  TaskForm({super.key, required this.actionAddTask});

  final taskController = TextEditingController();
  final Function actionAddTask;

  Future<LocationData?> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return null;
    }

    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (!serviceEnabled != PermissionStatus.granted) return null;
    }

    return location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: taskController,
          decoration: const InputDecoration(hintText: 'Descreva sua atividade'),
        ),
        ElevatedButton(
            onPressed: () {
              String description = taskController.text;
              String date =
                  DateFormat('kk:mm – dd-MM-yyyy').format(DateTime.now());
              final task = Task(description, date);
              actionAddTask(task);
            },
            child: const Text('Salvar')),
        FutureBuilder(
          future: getLocation(),
          builder: (context, snapshot) {
            return Text(
                '${snapshot.data?.latitude} ${snapshot.data?.longitude}');
          },
        )
      ],
    );
  }
}
