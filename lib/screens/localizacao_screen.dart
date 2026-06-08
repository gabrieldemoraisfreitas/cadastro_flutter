import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../constants/app_colors.dart';

class LocalizacaoPage extends StatefulWidget {
  const LocalizacaoPage({super.key});

  @override
  State<LocalizacaoPage> createState() => _LocalizacaoPageState();
}

class _LocalizacaoPageState extends State<LocalizacaoPage>
    with WidgetsBindingObserver {
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  Position? _lastTrackedPosition;
  double _distanceMeters = 0;
  bool _isLoading = false;
  bool _isTracking = false;
  String _status = 'Toque no botão para obter sua localização.';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  Future<Position> _determinePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'O serviço de localização está desligado. Ligue o GPS nas configurações do aparelho.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Permissão de localização negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Permissão negada para sempre. Altere a permissão nas configurações do sistema.',
      );
    }

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    return Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _status = 'Buscando localização atual...';
    });

    try {
      final position = await _determinePosition();

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _lastTrackedPosition = position;
        _status = 'Localização atual obtida com sucesso.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _status = error.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startTracking() async {
    if (_isTracking) return;

    setState(() {
      _isLoading = true;
      _status = 'Preparando tracking...';
    });

    try {
      final firstPosition = await _determinePosition();

      if (!mounted) return;

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _handleTrackedPosition,
        onError: (error) {
          if (!mounted) return;

          setState(() {
            _status = 'Erro no tracking: $error';
          });
        },
      );

      setState(() {
        _currentPosition = firstPosition;
        _lastTrackedPosition = firstPosition;
        _distanceMeters = 0;
        _isTracking = true;
        _status = 'Tracking ativo. Desloque-se para acumular distância.';
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _status = error.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleTrackedPosition(Position position) {
    if (!mounted) return;

    final previous = _lastTrackedPosition;
    var addedDistance = 0.0;

    if (previous != null) {
      addedDistance = Geolocator.distanceBetween(
        previous.latitude,
        previous.longitude,
        position.latitude,
        position.longitude,
      );
    }

    setState(() {
      _currentPosition = position;
      _lastTrackedPosition = position;
      _distanceMeters += addedDistance;
      _status = 'Tracking ativo. Última atualização recebida.';
    });
  }

  Future<void> _stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    if (!mounted) return;

    setState(() {
      _isTracking = false;
      _status = 'Tracking pausado.';
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed && _isTracking) {
      _stopTracking();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _positionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = _currentPosition;

    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Onde Estou Agora'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _StatusCard(
              status: _status,
              isTracking: _isTracking,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 16),
            _PositionCard(position: position),
            const SizedBox(height: 16),
            _DistanceCard(distanceMeters: _distanceMeters),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isLoading ? null : _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text('Obter posição atual'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _isLoading
                  ? null
                  : _isTracking
                      ? _stopTracking
                      : _startTracking,
              icon: Icon(_isTracking ? Icons.stop : Icons.play_arrow),
              label: Text(_isTracking ? 'Parar tracking' : 'Iniciar tracking'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.status,
    required this.isTracking,
    required this.isLoading,
  });

  final String status;
  final bool isTracking;
  final bool isLoading;

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
            Text('Status', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(status),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isTracking ? Icons.location_on : Icons.location_off,
                  color: isTracking ? AppColors.laranja : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(isTracking ? 'Tracking ativo' : 'Tracking parado'),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.position});

  final Position? position;

  @override
  Widget build(BuildContext context) {
    final position = this.position;

    if (position == null) {
      return const Card(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Nenhuma posição lida ainda.'),
        ),
      );
    }

    final mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';

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
            Text(
              'Posição atual',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _PositionLine(
              label: 'Latitude',
              value: position.latitude.toStringAsFixed(6),
            ),
            _PositionLine(
              label: 'Longitude',
              value: position.longitude.toStringAsFixed(6),
            ),
            _PositionLine(
              label: 'Precisão',
              value: '${position.accuracy.toStringAsFixed(1)} m',
            ),
            _PositionLine(
              label: 'Velocidade',
              value: '${position.speed.toStringAsFixed(1)} m/s',
            ),
            const SizedBox(height: 12),
            const Text('Link para conferir no mapa:'),
            SelectableText(mapsUrl),
          ],
        ),
      ),
    );
  }
}

class _PositionLine extends StatelessWidget {
  const _PositionLine({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _DistanceCard extends StatelessWidget {
  const _DistanceCard({required this.distanceMeters});

  final double distanceMeters;

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
            Text(
              'Distância aproximada',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${distanceMeters.toStringAsFixed(1)} m',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Este valor é uma estimativa calculada entre as posições recebidas durante o tracking.',
            ),
          ],
        ),
      ),
    );
  }
}
