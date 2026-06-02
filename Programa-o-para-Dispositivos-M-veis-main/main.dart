import 'package:flutter/material.dart';
import 'task_db.dart'; // arquivo onde está sua classe TaskDb

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController controller = TextEditingController();

  List<Map<String, dynamic>> tarefas = [];

  @override
  void initState() {
    super.initState();
    carregarTarefas();
  }

  Future<void> carregarTarefas() async {
    final dados = await TaskDb.instance.getTasks();

    setState(() {
      tarefas = dados;
    });
  }

  Future<void> adicionarTarefa() async {
    if (controller.text.trim().isEmpty) return;

    await TaskDb.instance.insertTask(controller.text);

    controller.clear();
    await carregarTarefas();
  }

  Future<void> concluirTarefa(int id) async {
    await TaskDb.instance.finishTask(id);
    await carregarTarefas();
  }

  Future<void> excluirTarefa(int id) async {
    await TaskDb.instance.deleteTask(id);
    await carregarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQLite CRUD'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Nova tarefa',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: adicionarTarefa,
                child: const Text('Salvar'),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: tarefas.length,
                itemBuilder: (context, index) {
                  final tarefa = tarefas[index];

                  final concluida = tarefa['done'] == 1;

                  return Card(
                    child: ListTile(
                      title: Text(
                        tarefa['task'],
                        style: TextStyle(
                          decoration: concluida
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${tarefa['id']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            onPressed: () =>
                                concluirTarefa(tarefa['id']),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                excluirTarefa(tarefa['id']),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}