import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/task.dart';
import 'package:flutter_pkg/flutter_pkg.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class TaskForm extends StatefulWidget {
  const TaskForm({super.key, required this.actionAddTask});

  final Function(Task) actionAddTask;

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final TextEditingController taskController = TextEditingController();
  LocationData? _locationData;
  bool _isLoading = false;
  String _locationError = '';
  dynamic _weatherData;

  Future<void> getLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionStatus;

    setState(() {
      _isLoading = true;
      _locationError = '';
    });

    try {
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() {
            _locationError = 'Service not enabled';
            _isLoading = false;
          });
          return;
        }
      }

      permissionStatus = await location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          setState(() {
            _locationError = 'Permission not granted';
            _isLoading = false;
          });
          return;
        }
      }

      final locationData = await location.getLocation();
      setState(() {
        _locationData = locationData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationError = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> getWeather() async {
    if (_locationData == null) return;

    String sUri =
        'https://api.openweathermap.org/data/2.5/weather?lat=${_locationData!.latitude}&lon=${_locationData!.longitude}&appid=640336a118cc753e0c1c377c6b461868';
    Uri uri = Uri.parse(sUri);

    var response = await http.get(uri);
    setState(() {
      _weatherData = jsonDecode(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    getLocation().then((_) => getWeather());
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
          onPressed: () async {
            String description = taskController.text;
            String date =
                DateFormat('kk:mm – dd-MM-yyyy').format(DateTime.now());
            final task = Task(description: description, date: date);
            widget.actionAddTask(task);
          },
          child: const Text('Salvar'),
        ),
        _isLoading
            ? const CircularProgressIndicator()
            : _locationError.isNotEmpty
                ? Text('Erro ao obter localização: $_locationError')
                : _locationData == null
                    ? const Text('Localização não disponível')
                    : _weatherData == null
                        ? const CircularProgressIndicator()
                        : Text(
                            'Tempo em ${_weatherData['name']}: ${(kelvinToCelsius(_weatherData!['main']['temp']))}°C'),
      ],
    );
  }
}
