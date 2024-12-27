import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _cepEC = TextEditingController();
  String _cep = '';
  bool _isLoading = false;

  _recuperarCep() async {
    String cepDigitado = _cepEC.text;

    if (cepDigitado.isEmpty ||
        cepDigitado.length != 8 ||
        int.tryParse(cepDigitado) == null) {
      setState(() {
        _cep = 'Por favor, insira um CEP válido com 8 dígitos, Ex: 12060660';
      });
      return;
    }

    String url = 'https://viacep.com.br/ws/$cepDigitado/json/';

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;

        if (data.containsKey('erro')) {
          setState(() {
            _cep = 'CEP não encontrado.';
          });
        } else {
          setState(() {
            _cep = '${data['logradouro']}, ${data['complemento']}, '
                '${data['bairro']}, ${data['localidade']}, ${data['uf']}, ${data['cep']}';
          });
        }
      } else {
        setState(() {
          _cep = 'Erro: Não foi possível buscar o CEP.';
        });
      }
    } catch (e) {
      setState(() {
        _cep = 'Erro: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }

    _cepEC.clear();
  }

  @override
  void dispose() {
    _cepEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Buscador de CEP'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Digite o CEP (8 dígitos)',
              ),
              style: const TextStyle(fontSize: 20, color: Colors.black),
              keyboardType: TextInputType.number,
              maxLength: 8,
              controller: _cepEC,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _recuperarCep,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Buscar pelo CEP'),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                _cep.isNotEmpty ? 'CEP: $_cep' : '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
