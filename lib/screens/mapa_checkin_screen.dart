import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../constants/app_colors.dart';

class MapaCheckinPage extends StatefulWidget {
  const MapaCheckinPage({super.key});

  @override
  State<MapaCheckinPage> createState() => _MapaCheckinPageState();
}

class _MapaCheckinPageState extends State<MapaCheckinPage> {
  static const LatLng _etec = LatLng(-22.7832, -47.2951);

  GoogleMapController? _mapController;
  LatLng? _minhaPosicao;
  String _status = 'Mapa iniciado. Toque em Minha localização.';

  final Set<Marker> _marcadores = {
    const Marker(
      markerId: MarkerId('etec'),
      position: _etec,
      infoWindow: InfoWindow(
        title: 'ETEC Ferrucio Humberto Gazzetta',
        snippet: 'Ponto fixo da aula',
      ),
    ),
  };

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _centralizarNaEscola() async {
    await _moverCamera(_etec, zoom: 16);

    if (!mounted) return;

    setState(() {
      _status = 'Mapa centralizado na ETEC.';
    });
  }

  Future<void> _centralizarNaMinhaLocalizacao() async {
    setState(() {
      _status = 'Verificando permissão de localização...';
    });

    final position = await _determinarPosicaoAtual();

    if (!mounted || position == null) return;

    final latLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _minhaPosicao = latLng;
      _status =
          'Localização encontrada com precisão de ${position.accuracy.toStringAsFixed(0)} m.';
      _marcadores.removeWhere(
        (marker) => marker.markerId.value == 'minha-posicao',
      );
      _marcadores.add(
        Marker(
          markerId: const MarkerId('minha-posicao'),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: const InfoWindow(
            title: 'Minha localização',
            snippet: 'Posição obtida pelo GPS',
          ),
        ),
      );
    });

    await _moverCamera(latLng, zoom: 17);
  }

  Future<Position?> _determinarPosicaoAtual() async {
    final servicoLigado = await Geolocator.isLocationServiceEnabled();

    if (!mounted) return null;

    if (!servicoLigado) {
      setState(() {
        _status = 'O serviço de localização está desligado.';
      });
      return null;
    }

    var permissao = await Geolocator.checkPermission();

    if (!mounted) return null;

    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }

    if (!mounted) return null;

    if (permissao == LocationPermission.denied) {
      setState(() {
        _status = 'Permissão de localização negada.';
      });
      return null;
    }

    if (permissao == LocationPermission.deniedForever) {
      setState(() {
        _status =
            'Permissão negada para sempre. Abra as configurações do aplicativo.';
      });
      return null;
    }

    try {
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
    } catch (erro) {
      if (!mounted) return null;

      setState(() {
        _status = 'Não foi possível obter a localização: $erro';
      });
      return null;
    }
  }

  Future<void> _moverCamera(LatLng destino, {required double zoom}) async {
    final controller = _mapController;

    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: destino,
          zoom: zoom,
        ),
      ),
    );
  }

  void _adicionarCheckin(LatLng ponto) {
    final numero = _marcadores.where((marker) {
      return marker.markerId.value.startsWith('checkin-');
    }).length + 1;

    final markerId = MarkerId('checkin-$numero');

    setState(() {
      _marcadores.add(
        Marker(
          markerId: markerId,
          position: ponto,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: 'Check-in $numero',
            snippet:
                '${ponto.latitude.toStringAsFixed(5)}, ${ponto.longitude.toStringAsFixed(5)}',
          ),
        ),
      );

      _status = 'Check-in $numero criado com toque longo no mapa.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fundo,
      appBar: AppBar(
        title: const Text('Mapa de Check-in'),
        backgroundColor: AppColors.laranja,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _etec,
              zoom: 16,
            ),
            markers: _marcadores,
            myLocationButtonEnabled: false,
            myLocationEnabled: _minhaPosicao != null,
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onLongPress: _adicionarCheckin,
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Colors.black12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _status,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Check-ins: ${_quantidadeCheckins()}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'minha-localizacao',
            onPressed: _centralizarNaMinhaLocalizacao,
            tooltip: 'Minha localização',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'escola',
            onPressed: _centralizarNaEscola,
            tooltip: 'Escola',
            child: const Icon(Icons.school),
          ),
        ],
      ),
    );
  }

  int _quantidadeCheckins() {
    return _marcadores.where((marker) {
      return marker.markerId.value.startsWith('checkin-');
    }).length;
  }
}
