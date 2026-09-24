import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const NexoLabApp());

class NexoLabApp extends StatefulWidget {
  const NexoLabApp({super.key});
  @override State<NexoLabApp> createState() => _NexoLabAppState();
}

class _NexoLabAppState extends State<NexoLabApp> {
  ThemeMode mode = ThemeMode.dark;
  @override Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'NexoLab',
    themeMode: mode,
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.light),
    darkTheme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.dark),
    home: Home(onTheme: () => setState(() => mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark)),
  );
}

class Home extends StatefulWidget {
  final VoidCallback onTheme;
  const Home({super.key, required this.onTheme});
  @override State<Home> createState() => _HomeState();
}
class _HomeState extends State<Home> {
  int tab = 0;
  final pages = const [CalculatorPage(), ModelsPage(), MonteCarloPage()];
  @override Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('NexoLab'), actions: [IconButton(onPressed: widget.onTheme, icon: const Icon(Icons.brightness_6))]),
    body: pages[tab],
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (i) => setState(() => tab = i), destinations: const [
      NavigationDestination(icon: Icon(Icons.calculate_outlined), selectedIcon: Icon(Icons.calculate), label: 'Calcular'),
      NavigationDestination(icon: Icon(Icons.account_tree_outlined), selectedIcon: Icon(Icons.account_tree), label: 'Modelos'),
      NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Simular'),
    ]),
  );
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override State<CalculatorPage> createState() => _CalculatorPageState();
}
class _CalculatorPageState extends State<CalculatorPage> {
  final input = TextEditingController();
  final vars = <String, double>{};
  String result = '0';
  final history = <String>[];
  void evaluate() {
    final text = input.text.trim();
    if (text.isEmpty) return;
    try {
      final parts = text.split('=');
      final expression = parts.length > 1 ? parts.sublist(1).join('=') : text;
      final value = ExpressionParser(expression, vars).parse();
      if (parts.length > 1 && RegExp(r'^[a-zA-Z_]\w*$').hasMatch(parts.first.trim())) vars[parts.first.trim()] = value;
      setState(() { result = _format(value); history.insert(0, '$text = ${_format(value)}'); });
    } catch (e) { setState(() => result = 'Error: ${e.toString().replaceFirst('Exception: ', '')}'); }
  }
  void key(String value) { input.text += value; input.selection = TextSelection.collapsed(offset: input.text.length); }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    Text('Calculadora científica', style: Theme.of(context).textTheme.headlineSmall),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      TextField(controller: input, textAlign: TextAlign.right, decoration: const InputDecoration(hintText: 'Ej. sin(pi/2) + sqrt(25)', border: InputBorder.none), onSubmitted: (_) => evaluate()),
      const Divider(), Text(result, style: Theme.of(context).textTheme.headlineMedium),
    ]))),
    Wrap(spacing: 8, runSpacing: 8, children: ['sin(', 'cos(', 'tan(', 'sqrt(', 'log(', 'abs(', 'pi', 'e', '^', '(', ')'].map((v) => OutlinedButton(onPressed: () => key(v), child: Text(v))).toList()),
    const SizedBox(height: 12),
    Row(children: [Expanded(child: FilledButton.icon(onPressed: evaluate, icon: const Icon(Icons.play_arrow), label: const Text('Calcular'))), const SizedBox(width: 8), IconButton(onPressed: () => setState(() { input.clear(); result = '0'; }), icon: const Icon(Icons.clear))]),
    if (vars.isNotEmpty) ...[const SizedBox(height: 16), Text('Variables', style: Theme.of(context).textTheme.titleMedium), Wrap(spacing: 8, children: vars.entries.map((e) => Chip(label: Text('${e.key} = ${_format(e.value)}'))).toList())],
    if (history.isNotEmpty) ...[const SizedBox(height: 16), Text('Historial', style: Theme.of(context).textTheme.titleMedium), ...history.take(8).map((h) => ListTile(dense: true, leading: const Icon(Icons.history), title: Text(h), onTap: () => input.text = h.split(' = ').first))],
  ]);
}

class ExpressionParser {
  final String source; final Map<String, double> vars; int pos = 0;
  ExpressionParser(this.source, this.vars);
  double parse() { final v = _add(); _space(); if (pos != source.length) throw Exception('expresión inválida'); return v; }
  void _space() { while (pos < source.length && source[pos].trim().isEmpty) pos++; }
  bool _take(String s) { _space(); if (source.startsWith(s, pos)) { pos += s.length; return true; } return false; }
  double _add() { var v = _mul(); while (true) { if (_take('+')) v += _mul(); else if (_take('-')) v -= _mul(); else return v; } }
  double _mul() { var v = _pow(); while (true) { if (_take('*')) v *= _pow(); else if (_take('/')) v /= _pow(); else return v; } }
  double _pow() { var v = _unary(); if (_take('^')) v = math.pow(v, _pow()).toDouble(); return v; }
  double _unary() { if (_take('-')) return -_unary(); if (_take('+')) return _unary(); return _atom(); }
  double _atom() {
    _space(); if (_take('(')) { final v = _add(); if (!_take(')')) throw Exception('falta )'); return v; }
    final start = pos; while (pos < source.length && RegExp(r'[A-Za-z_]\w*').hasMatch(source.substring(pos, pos + 1))) pos++;
    if (pos > start) { final name = source.substring(start, pos).toLowerCase(); if (_take('(')) { final v = _add(); if (!_take(')')) throw Exception('falta )'); return _function(name, v); } return vars[name] ?? (name == 'pi' ? math.pi : name == 'e' ? math.e : throw Exception('variable $name desconocida')); }
    final number = RegExp(r'(\d+(\.\d*)?|\.\d+)([eE][+-]?\d+)?').matchAsPrefix(source.substring(pos));
    if (number == null) throw Exception('valor esperado'); pos += number.group(0)!.length; return double.parse(number.group(0)!);
  }
  double _function(String n, double x) => switch (n) { 'sin' => math.sin(x), 'cos' => math.cos(x), 'tan' => math.tan(x), 'sqrt' => math.sqrt(x), 'log' => math.log(x), 'abs' => x.abs(), 'exp' => math.exp(x), _ => throw Exception('función $n desconocida') };
}

class ModelsPage extends StatefulWidget { const ModelsPage({super.key}); @override State<ModelsPage> createState() => _ModelsPageState(); }
class _ModelsPageState extends State<ModelsPage> {
  final name = TextEditingController(text: 'Mi modelo'); final formula = TextEditingController(text: 'resultado = (inicio * (1 + tasa)^periodos)'); final values = TextEditingController(text: 'inicio=1000\ntasa=0.05\nperiodos=10');
  List<String> saved = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final p = await SharedPreferences.getInstance(); setState(() => saved = p.getStringList('models') ?? []); }
  Future<void> _save() async { final p = await SharedPreferences.getInstance(); final item = jsonEncode({'name': name.text, 'values': values.text, 'formula': formula.text}); saved = [...saved, item]; await p.setStringList('models', saved); setState(() {}); }
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [Text('Creador de modelos', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 12), TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.label_outline))), const SizedBox(height: 8), TextField(controller: values, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Variables (una por línea)', hintText: 'masa=10\naceleracion=9.81', border: OutlineInputBorder())), const SizedBox(height: 8), TextField(controller: formula, minLines: 2, maxLines: 4, decoration: const InputDecoration(labelText: 'Fórmula', border: OutlineInputBorder())), const SizedBox(height: 12), FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('Guardar modelo')), const SizedBox(height: 20), Text('Modelos guardados', style: Theme.of(context).textTheme.titleMedium), ...saved.reversed.map((s) { final m = jsonDecode(s); return Card(child: ListTile(leading: const Icon(Icons.model_training), title: Text(m['name']), subtitle: Text(m['formula']), onTap: () { name.text = m['name']; values.text = m['values']; formula.text = m['formula']; })); })]);
}

class MonteCarloPage extends StatefulWidget { const MonteCarloPage({super.key}); @override State<MonteCarloPage> createState() => _MonteCarloPageState(); }
class _MonteCarloPageState extends State<MonteCarloPage> {
  final count = TextEditingController(text: '5000'); final mean = TextEditingController(text: '100'); final deviation = TextEditingController(text: '15'); List<double> data = []; bool running = false;
  void run() { setState(() => running = true); Future(() { final n = int.tryParse(count.text) ?? 5000; final mu = double.tryParse(mean.text) ?? 100; final sd = double.tryParse(deviation.text) ?? 15; final r = math.Random(); final out = <double>[]; for (var i = 0; i < n; i++) { final u = 1 - r.nextDouble(); final v = r.nextDouble(); out.add(mu + sd * math.sqrt(-2 * math.log(u)) * math.cos(2 * math.pi * v)); } if (mounted) setState(() { data = out; running = false; }); }); }
  @override Widget build(BuildContext context) { final avg = data.isEmpty ? 0 : data.reduce((a, b) => a + b) / data.length; return ListView(padding: const EdgeInsets.all(16), children: [Text('Simulación Monte Carlo', style: Theme.of(context).textTheme.headlineSmall), const SizedBox(height: 8), const Text('Genera una distribución normal sin conexión y explora su incertidumbre.'), const SizedBox(height: 16), Row(children: [Expanded(child: TextField(controller: count, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Simulaciones'))), const SizedBox(width: 8), Expanded(child: TextField(controller: mean, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Media'))), const SizedBox(width: 8), Expanded(child: TextField(controller: deviation, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Desv.')))]), const SizedBox(height: 12), FilledButton.icon(onPressed: running ? null : run, icon: running ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow), label: Text(running ? 'Simulando...' : 'Ejecutar')), if (data.isNotEmpty) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Media: ${_format(avg)}'), Text('Mínimo: ${_format(data.reduce(math.min))}'), Text('Máximo: ${_format(data.reduce(math.max))}'), const SizedBox(height: 12), SizedBox(height: 220, child: Histogram(data: data))]))])]); }
}

class Histogram extends StatelessWidget { final List<double> data; const Histogram({super.key, required this.data}); @override Widget build(BuildContext context) => CustomPaint(painter: HistogramPainter(data, Theme.of(context).colorScheme.primary)); }
class HistogramPainter extends CustomPainter { final List<double> data; final Color color; HistogramPainter(this.data, this.color); @override void paint(Canvas c, Size s) { final min = data.reduce(math.min), max = data.reduce(math.max); final bars = List.filled(24, 0); for (final x in data) { final i = (((x - min) / (max - min == 0 ? 1 : max - min)) * 23).floor().clamp(0, 23); bars[i]++; } final peak = bars.reduce(math.max).toDouble(); final p = Paint()..color = color; for (var i = 0; i < bars.length; i++) { final h = bars[i] / peak * (s.height - 12); c.drawRect(Rect.fromLTWH(i * s.width / bars.length + 1, s.height - h, s.width / bars.length - 2, h), p); } } @override bool shouldRepaint(covariant HistogramPainter old) => old.data != data; }

String _format(double x) => x.isFinite ? (x.abs() >= 100000 || (x != 0 && x.abs() < 0.0001) ? x.toStringAsExponential(5) : x.toStringAsFixed(6).replaceFirst(RegExp(r'0+ ?$'), '').replaceFirst(RegExp(r'\.$'), '')) : 'NaN';
