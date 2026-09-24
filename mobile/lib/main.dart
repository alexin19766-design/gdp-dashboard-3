import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NexoLabApp());
}

class NexoLabApp extends StatefulWidget {
  const NexoLabApp({super.key});

  @override
  State<NexoLabApp> createState() => _NexoLabAppState();
}

class _NexoLabAppState extends State<NexoLabApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NexoLab',
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6)),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: Home(
        onToggleTheme: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key, required this.onToggleTheme});
  final VoidCallback onToggleTheme;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CalculatorPage(),
    ModelsPage(),
    SimulationPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NexoLab'),
        centerTitle: false,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: const Icon(Icons.dark_mode_outlined),
            tooltip: 'Cambiar tema',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Panel'),
          NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Calcular'),
          NavigationDestination(icon: Icon(Icons.model_training_outlined), selectedIcon: Icon(Icons.model_training), label: 'Modelos'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Monte Carlo'),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cards = [
      DashboardStatCard(
        title: 'Cálculo rápido',
        value: 'sin(pi/2)',
        subtitle: 'Resultado: 1.0000',
        color: const Color(0xFF4F46E5),
      ),
      DashboardStatCard(
        title: 'Modelos',
        value: '12',
        subtitle: 'Guardados localmente',
        color: const Color(0xFF06B6D4),
      ),
      DashboardStatCard(
        title: 'Monte Carlo',
        value: '10k',
        subtitle: 'simulaciones por prueba',
        color: const Color(0xFF10B981),
      ),
      DashboardStatCard(
        title: 'Análisis',
        value: '5',
        subtitle: 'gráficas disponibles',
        color: const Color(0xFFF59E0B),
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        Text(
          'Panel principal',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) => cards[index],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Atajos rápidos'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    QuickChip(label: 'Área círculo', value: 'π * r²'),
                    QuickChip(label: 'Crecimiento', value: 'p0*(1+r)^n'),
                    QuickChip(label: 'Probabilidad', value: 'normal(100,15)'),
                    QuickChip(label: 'Superficie', value: 'sin(x) + cos(y)'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class QuickChip extends StatelessWidget {
  const QuickChip({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _controller = TextEditingController();
  final Map<String, double> _variables = {};
  final List<String> _history = [];
  String _resultText = '0';

  void _insertText(String token) {
    final value = _controller.text;
    final selection = _controller.selection;
    final textBefore = value.substring(0, selection.start);
    final textAfter = value.substring(selection.end, value.length);
    final newText = '$textBefore$token$textAfter';
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: textBefore.length + token.length),
    );
  }

  void _evaluate() {
    final raw = _controller.text.trim();
    if (raw.isEmpty) {
      return;
    }

    try {
      final assignment = raw.split('=');
      final expression = assignment.length > 1 ? assignment.sublist(1).join('=') : raw;
      final parsed = ExpressionParser(expression, _variables).parse();

      if (assignment.length > 1 && RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(assignment.first.trim())) {
        final name = assignment.first.trim();
        _variables[name] = parsed;
      }

      final message = '$raw = ${formatNumber(parsed)}';
      setState(() {
        _resultText = formatNumber(parsed);
        _history.insert(0, message);
      });
    } catch (error) {
      setState(() {
        _resultText = 'Error';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _clear() {
    setState(() {
      _controller.clear();
      _resultText = '0';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Calculadora científica',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.right,
                  maxLines: 3,
                  minLines: 1,
                  style: theme.textTheme.titleLarge,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Ej.: sin(pi/2) + sqrt(25)',
                  ),
                  onSubmitted: (_) => _evaluate(),
                ),
                const Divider(),
                Text(
                  _resultText,
                  style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'sin(', 'cos(', 'tan(', 'sqrt(', 'log(', 'ln(', 'exp(', 'abs(', 'pi', 'e', '^', '(', ')',
          ].map((token) => ActionChip(label: Text(token), onPressed: () => _insertText(token))).toList(),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _evaluate,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Calcular'),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: _clear,
              icon: const Icon(Icons.clear_rounded),
              tooltip: 'Limpiar',
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_variables.isNotEmpty) ...[
          Text('Variables', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _variables.entries
                .map((entry) => Chip(label: Text('${entry.key} = ${formatNumber(entry.value)}')))
                .toList(),
          ),
          const SizedBox(height: 18),
        ],
        if (_history.isNotEmpty) ...[
          Text('Historial', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._history.take(8).map((entry) => ListTile(
                dense: true,
                leading: const Icon(Icons.history_rounded),
                title: Text(entry),
                onTap: () => _controller.text = entry.split('=').first.trim(),
              )),
        ],
      ],
    );
  }
}

class ModelsPage extends StatefulWidget {
  const ModelsPage({super.key});

  @override
  State<ModelsPage> createState() => _ModelsPageState();
}

class _ModelsPageState extends State<ModelsPage> {
  final TextEditingController _nameController = TextEditingController(text: 'Crecimiento');
  final TextEditingController _variablesController = TextEditingController(
    text: 'p0=1000\ntasa=0.05\nperiodos=10',
  );
  final TextEditingController _formulaController = TextEditingController(
    text: 'final = p0 * (1 + tasa)^periodos',
  );
  List<String> _savedModels = [];

  Future<void> _loadModels() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedModels = prefs.getStringList('nexolab_models') ?? [];
    });
  }

  Future<void> _saveModel() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode({
      'name': _nameController.text.trim().isEmpty ? 'Modelo sin nombre' : _nameController.text.trim(),
      'variables': _variablesController.text,
      'formula': _formulaController.text,
    });

    final updated = [..._savedModels, payload];
    await prefs.setStringList('nexolab_models', updated);
    setState(() {
      _savedModels = updated;
    });
  }

  void _applyModel(Map<String, dynamic> model) {
    _nameController.text = model['name'] as String;
    _variablesController.text = model['variables'] as String;
    _formulaController.text = model['formula'] as String;
  }

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Modelos',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Nombre del modelo'),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _variablesController,
          minLines: 4,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Variables',
            hintText: 'p0=1000\ntasa=0.05\nperiodos=10',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _formulaController,
          minLines: 3,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Fórmula',
            hintText: 'final = p0 * (1 + tasa)^periodos',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: _saveModel,
          icon: const Icon(Icons.save_alt_rounded),
          label: const Text('Guardar modelo'),
        ),
        const SizedBox(height: 18),
        Text('Guardados', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_savedModels.isEmpty)
          const Text('Todavía no hay modelos guardados.')
        else
          ..._savedModels.reversed.map((entry) {
            final model = jsonDecode(entry) as Map<String, dynamic>;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.model_training_rounded),
                title: Text(model['name'] as String),
                subtitle: Text(model['formula'] as String),
                onTap: () => _applyModel(model),
              ),
            );
          }),
      ],
    );
  }
}

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  final TextEditingController _nController = TextEditingController(text: '5000');
  final TextEditingController _meanController = TextEditingController(text: '100');
  final TextEditingController _stdDevController = TextEditingController(text: '15');
  final TextEditingController _minController = TextEditingController(text: '20');
  final TextEditingController _maxController = TextEditingController(text: '40');
  final TextEditingController _modeController = TextEditingController(text: '30');

  String _distribution = 'Normal';
  List<double> _samples = const [];
  bool _running = false;

  void _runSimulation() {
    final n = int.tryParse(_nController.text) ?? 5000;
    final rng = math.Random();
    final samples = <double>[];

    setState(() {
      _running = true;
    });

    Future.microtask(() {
      for (var i = 0; i < n; i++) {
        double value;
        switch (_distribution) {
          case 'Normal':
            final mean = double.tryParse(_meanController.text) ?? 100;
            final std = double.tryParse(_stdDevController.text) ?? 15;
            value = _normalSample(mean, std, rng);
            break;
          case 'Uniforme':
            final min = double.tryParse(_minController.text) ?? 0;
            final max = double.tryParse(_maxController.text) ?? 1;
            value = min + (max - min) * rng.nextDouble();
            break;
          case 'Triangular':
            final a = double.tryParse(_minController.text) ?? 0;
            final b = double.tryParse(_maxController.text) ?? 1;
            final c = double.tryParse(_modeController.text) ?? ((a + b) / 2);
            value = _triangularSample(a, b, c, rng);
            break;
          default:
            value = 0;
        }
        samples.add(value);
      }

      if (!mounted) return;
      setState(() {
        _samples = samples;
        _running = false;
      });
    });
  }

  double _normalSample(double mean, double std, math.Random rng) {
    final u1 = 1.0 - rng.nextDouble();
    final u2 = 1.0 - rng.nextDouble();
    final z0 = math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
    return mean + std * z0;
  }

  double _triangularSample(double a, double b, double c, math.Random rng) {
    final u = rng.nextDouble();
    if (u < (c - a) / (b - a)) {
      return a + math.sqrt(u * (b - a) * (c - a));
    }
    return b - math.sqrt((1 - u) * (b - a) * (b - c));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = _sampleStats(_samples);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Monte Carlo',
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _distribution,
          decoration: const InputDecoration(labelText: 'Distribución'),
          items: const [
            DropdownMenuItem(value: 'Normal', child: Text('Normal')),
            DropdownMenuItem(value: 'Uniforme', child: Text('Uniforme')),
            DropdownMenuItem(value: 'Triangular', child: Text('Triangular')),
          ],
          onChanged: (value) => setState(() => _distribution = value ?? 'Normal'),
        ),
        const SizedBox(height: 12),
        if (_distribution == 'Normal') ...[
          Row(
            children: [
              Expanded(child: TextField(controller: _meanController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Media'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _stdDevController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Desv.'))),
            ],
          ),
        ] else ...[
          Row(
            children: [
              Expanded(child: TextField(controller: _minController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mín'))),
              const SizedBox(width: 10),
              Expanded(child: TextField(controller: _maxController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Máx'))),
            ],
          ),
          if (_distribution == 'Triangular') ...[
            const SizedBox(height: 12),
            TextField(controller: _modeController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Moda')),
          ],
        ],
        const SizedBox(height: 12),
        TextField(
          controller: _nController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Número de simulaciones'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _running ? null : _runSimulation,
          icon: _running
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded),
          label: Text(_running ? 'Simulando...' : 'Ejecutar simulación'),
        ),
        const SizedBox(height: 18),
        if (_samples.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resultados', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _StatChip('Media', formatNumber(stats['mean'] as double)),
                      _StatChip('Mediana', formatNumber(stats['median'] as double)),
                      _StatChip('Desv.', formatNumber(stats['std'] as double)),
                      _StatChip('Mín', formatNumber(stats['min'] as double)),
                      _StatChip('Máx', formatNumber(stats['max'] as double)),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 220,
                    child: HistogramChart(samples: _samples),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Map<String, double> _sampleStats(List<double> data) {
  if (data.isEmpty) {
    return {'mean': 0, 'median': 0, 'std': 0, 'min': 0, 'max': 0};
  }

  final sorted = [...data]..sort();
  final mean = data.reduce((a, b) => a + b) / data.length;
  final variance = data.fold<double>(0, (sum, value) => sum + math.pow(value - mean, 2)) / data.length;
  final median = sorted[sorted.length ~/ 2];
  final min = sorted.first;
  final max = sorted.last;

  return {
    'mean': mean,
    'median': median,
    'std': math.sqrt(variance),
    'min': min,
    'max': max,
  };
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}

class HistogramChart extends StatelessWidget {
  const HistogramChart({super.key, required this.samples});

  final List<double> samples;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: HistogramPainter(samples),
      child: Container(),
    );
  }
}

class HistogramPainter extends CustomPainter {
  HistogramPainter(this.samples);

  final List<double> samples;

  @override
  void paint(Canvas canvas, Size size) {
    if (samples.isEmpty) return;

    final min = samples.reduce(math.min);
    final max = samples.reduce(math.max);
    final bars = List<int>.filled(24, 0);

    for (final sample in samples) {
      final ratio = (sample - min) / (max - min == 0 ? 1 : max - min);
      final index = (ratio * 23).round().clamp(0, 23);
      bars[index]++;
    }

    final peak = bars.reduce(math.max).toDouble();
    final barWidth = size.width / bars.length;
    final axisPaint = Paint()..color = Colors.grey.withOpacity(0.5);
    canvas.drawLine(Offset(0, size.height), Offset(size.width, size.height), axisPaint);

    for (var i = 0; i < bars.length; i++) {
      final height = peak == 0 ? 0 : (bars[i] / peak) * (size.height - 16);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barWidth + 2,
          size.height - height,
          barWidth - 4,
          height,
        ),
        const Radius.circular(4),
      );
      final paint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant HistogramPainter oldDelegate) {
    return oldDelegate.samples != samples;
  }
}

class ExpressionParser {
  final String source;
  final Map<String, double> variables;
  int _position = 0;

  ExpressionParser(this.source, this.variables);

  double parse() {
    final value = _parseAdd();
    _skipWhitespace();
    if (_position != source.length) {
      throw Exception('Expresión no válida');
    }
    return value;
  }

  double _parseAdd() {
    double acc = _parseMultiply();
    while (true) {
      _skipWhitespace();
      if (_consume('+')) {
        acc += _parseMultiply();
      } else if (_consume('-')) {
        acc -= _parseMultiply();
      } else {
        return acc;
      }
    }
  }

  double _parseMultiply() {
    double acc = _parsePower();
    while (true) {
      _skipWhitespace();
      if (_consume('*')) {
        acc *= _parsePower();
      } else if (_consume('/')) {
        acc /= _parsePower();
      } else {
        return acc;
      }
    }
  }

  double _parsePower() {
    double acc = _parseUnary();
    _skipWhitespace();
    if (_consume('^')) {
      acc = math.pow(acc, _parsePower()).toDouble();
    }
    return acc;
  }

  double _parseUnary() {
    _skipWhitespace();
    if (_consume('+')) {
      return _parseUnary();
    }
    if (_consume('-')) {
      return -_parseUnary();
    }
    return _parsePrimary();
  }

  double _parsePrimary() {
    _skipWhitespace();
    if (_consume('(')) {
      final value = _parseAdd();
      _skipWhitespace();
      if (!_consume(')')) {
        throw Exception('Falta paréntesis de cierre');
      }
      return value;
    }

    final current = _peek();
    if (current != null && RegExp(r'[0-9.]').hasMatch(current)) {
      final start = _position;
      while (_position < source.length && RegExp(r'[0-9.eE+-]').hasMatch(source[_position])) {
        _position++;
      }
      final number = source.substring(start, _position);
      return double.tryParse(number) ?? (throw Exception('Número no válido'));
    }

    if (current != null && RegExp(r'[A-Za-z_]').hasMatch(current)) {
      final start = _position;
      while (_position < source.length && RegExp(r'[A-Za-z0-9_]').hasMatch(source[_position])) {
        _position++;
      }
      final identifier = source.substring(start, _position).toLowerCase();
      _skipWhitespace();
      if (_consume('(')) {
        final args = <double>[];
        if (!_consume(')')) {
          while (true) {
            args.add(_parseAdd());
            _skipWhitespace();
            if (_consume(')')) {
              break;
            }
            if (_consume(',')) {
              continue;
            }
            throw Exception('Separación de argumentos no válida');
          }
        }
        return _applyFunction(identifier, args);
      }

      if (identifier == 'pi') return math.pi;
      if (identifier == 'e') return math.e;
      if (variables.containsKey(identifier)) {
        return variables[identifier]!;
      }
      throw Exception('Variable desconocida: $identifier');
    }

    throw Exception('Expresión no válida');
  }

  double _applyFunction(String name, List<double> args) {
    switch (name) {
      case 'sin':
        return math.sin(args[0]);
      case 'cos':
        return math.cos(args[0]);
      case 'tan':
        return math.tan(args[0]);
      case 'asin':
        return math.asin(args[0]);
      case 'acos':
        return math.acos(args[0]);
      case 'atan':
        return math.atan(args[0]);
      case 'sqrt':
        return math.sqrt(args[0]);
      case 'log':
        return math.log(args[0]);
      case 'ln':
        return math.log(args[0]);
      case 'exp':
        return math.exp(args[0]);
      case 'abs':
        return args[0].abs();
      case 'pow':
        return math.pow(args[0], args[1]).toDouble();
      case 'min':
        return args.reduce(math.min);
      case 'max':
        return args.reduce(math.max);
      case 'mean':
        return args.reduce((a, b) => a + b) / args.length;
      default:
        throw Exception('Función desconocida: $name');
    }
  }

  String? _peek() {
    if (_position >= source.length) {
      return null;
    }
    return source[_position];
  }

  bool _consume(String expected) {
    _skipWhitespace();
    if (_position < source.length && source.startsWith(expected, _position)) {
      _position += expected.length;
      return true;
    }
    return false;
  }

  void _skipWhitespace() {
    while (_position < source.length && source[_position].trim().isEmpty) {
      _position++;
    }
  }
}

String formatNumber(double value) {
  if (!value.isFinite) {
    return 'NaN';
  }
  if (value.abs() >= 100000 || (value != 0 && value.abs() < 0.0001)) {
    return value.toStringAsExponential(4);
  }
  final fixed = value.toStringAsFixed(6);
  return fixed.replaceFirst(RegExp(r'\.0+$'), '').replaceFirst(RegExp(r'(\.\d*?)0+$'), r'$1');
}

extension on String {
  String toTrimmed() => trim();
}
