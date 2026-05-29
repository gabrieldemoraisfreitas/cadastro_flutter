import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../constants/app_colors.dart';

class NivelDigitalPage extends StatefulWidget {
  const NivelDigitalPage({super.key});

  @override
  State<NivelDigitalPage> createState() => _NivelDigitalPageState();
}

class _NivelDigitalPageState extends State<NivelDigitalPage>
    with WidgetsBindingObserver {
  StreamSubscription<AccelerometerEvent>? _subscription;
  double _x = 0;
  double _y = 0;
  double _z = 0;
  bool _isListening = false;
  String _status = 'Aguardando leitura do acelerômetro...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSensor();
  }

  void _startSensor() {
    if (_isListening) return;

    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.normalInterval,
    ).listen(
      (event) {
        if (!mounted) return;
        setState(() {
          _x = event.x;
          _y = event.y;
          _z = event.z;
          _status = _buildStatusMessage(event.x, event.y);
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _status = 'Não foi possível ler o acelerômetro: $error';
        });
      },
    );

    setState(() {
      _isListening = true;
      _status = 'Lendo o acelerômetro...';
    });
  }

  Future<void> _stopSensor() async {
    await _subscription?.cancel();
    _subscription = null;

    if (!mounted) return;

    setState(() {
      _isListening = false;
      _status = 'Leitura pausada.';
    });
  }

  String _buildStatusMessage(double x, double y) {
    if (x.abs() < 1.2 && y.abs() < 1.2) {
      return 'Quase nivelado. Tente manter a bolha no centro.';
    }

    if (x.abs() > y.abs()) {
      return x > 0
          ? 'Inclinado para a esquerda.'
          : 'Inclinado para a direita.';
    }

    return y > 0 ? 'Inclinado para baixo.' : 'Inclinado para cima.';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startSensor();
      return;
    }

    _stopSensor();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Nível Digital'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SensorValuesCard(
                x: _x,
                y: _y,
                z: _z,
                isListening: _isListening,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _BubbleLevel(
                  x: _x,
                  y: _y,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isListening ? _stopSensor : _startSensor,
                icon: Icon(_isListening ? Icons.pause : Icons.play_arrow),
                label:
                    Text(_isListening ? 'Pausar leitura' : 'Retomar leitura'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorValuesCard extends StatelessWidget {
  const _SensorValuesCard({
    required this.x,
    required this.y,
    required this.z,
    required this.isListening,
  });

  final double x;
  final double y;
  final double z;
  final bool isListening;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isListening ? Icons.sensors : Icons.sensors_off,
                  color: isListening ? AppColors.laranja : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  isListening ? 'Sensor ativo' : 'Sensor pausado',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('x: ${x.toStringAsFixed(2)}'),
            Text('y: ${y.toStringAsFixed(2)}'),
            Text('z: ${z.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}

class _BubbleLevel extends StatelessWidget {
  const _BubbleLevel({
    required this.x,
    required this.y,
  });

  final double x;
  final double y;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = math.min(constraints.maxWidth, constraints.maxHeight);
        const bubbleSize = 48.0;
        final limit = (size - bubbleSize) / 2;
        final normalizedX = (x / 9.8).clamp(-1.0, 1.0);
        final normalizedY = (y / 9.8).clamp(-1.0, 1.0);
        final left = limit + normalizedX * limit;
        final top = limit + normalizedY * limit;
        final isNearCenter = x.abs() < 1.2 && y.abs() < 1.2;

        return Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.laranja.withOpacity(0.08),
              border: Border.all(color: AppColors.laranja, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.add,
                    size: 72,
                    color: AppColors.laranja,
                  ),
                ),
                Positioned(
                  left: left,
                  top: top,
                  child: Container(
                    width: bubbleSize,
                    height: bubbleSize,
                    decoration: BoxDecoration(
                      color:
                          isNearCenter ? AppColors.laranja : Colors.orange,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.laranja, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
