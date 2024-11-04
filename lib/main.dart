import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salario App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _salarioBaseController = TextEditingController();
  final _horasTrabajadasController = TextEditingController();
  final _tasaImpuestosController = TextEditingController();
  final _deduccionesController = TextEditingController();

  double? _salarioBruto;
  double? _impuestos;
  double? _deducciones;
  double? _salarioNeto;

  Future<void> _calcularSalario() async {
    final response = await http.post(
      Uri.parse('http://salario-app-latest.onrender.com/calcular'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'salarioBase': double.parse(_salarioBaseController.text),
        'horasTrabajadas': double.parse(_horasTrabajadasController.text),
        'tasaImpuestos': double.parse(_tasaImpuestosController.text),
        'deducciones': double.parse(_deduccionesController.text),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _salarioBruto = data['salarioBruto'];
        _impuestos = data['impuestos'];
        _deducciones = data['deducciones'];
        _salarioNeto = data['salarioNeto'];
      });
    } else {
      throw Exception('Failed to calculate salary');
    }
  }

  @override
  void dispose() {
    _salarioBaseController.dispose();
    _horasTrabajadasController.dispose();
    _tasaImpuestosController.dispose();
    _deduccionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Salario App'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _salarioBaseController,
                decoration: InputDecoration(labelText: 'Salario Base'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese el salario base';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _horasTrabajadasController,
                decoration: InputDecoration(labelText: 'Horas Trabajadas'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese las horas trabajadas';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _tasaImpuestosController,
                decoration: InputDecoration(labelText: 'Tasa de Impuestos'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese la tasa de impuestos';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _deduccionesController,
                decoration: InputDecoration(labelText: 'Deducciones'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese las deducciones';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _calcularSalario();
                  }
                },
                child: Text('Calcular'),
              ),
              SizedBox(height: 20),
              if (_salarioBruto != null) Text('Salario Bruto: $_salarioBruto'),
              if (_impuestos != null) Text('Impuestos: $_impuestos'),
              if (_deducciones != null) Text('Deducciones: $_deducciones'),
              if (_salarioNeto != null) Text('Salario Neto: $_salarioNeto'),
            ],
          ),
        ),
      ),
    );
  }
}
