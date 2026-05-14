import 'package:flutter/material.dart';

import '../models/servico.dart';

class ServicosScreen extends StatelessWidget {
  const ServicosScreen({super.key});

  static const List<Servico> servicos = [
    Servico(
      id: 1,
      titulo: 'Descarga de caminhão',
      cliente: 'João Silva',
      data: 'Hoje',
      status: 'Ativo',
      tipoServico: 'Carga e descarga',
    ),
    Servico(
      id: 2,
      titulo: 'Entrega para comércio',
      cliente: 'Maria Campos',
      data: 'Amanhã',
      status: 'Pendente',
      tipoServico: 'Entrega rápida',
    ),
    Servico(
      id: 3,
      titulo: 'Atendimento recorrente',
      cliente: 'Roberto Pinto',
      data: '12/05',
      status: 'Concluído',
      tipoServico: 'Cliente recorrente',
    ),
    Servico(
      id: 4,
      titulo: 'Novo orçamento',
      cliente: 'Ana Lima',
      data: '13/05',
      status: 'Pendente',
      tipoServico: 'Atendimento comercial',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const laranja = Color(0xFFFF6B1A);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Serviços',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Acompanhe os serviços ativos, pendentes e concluídos.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          ...servicos.map((servico) {
            final cor = _corStatus(servico.status);

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: laranja.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.work_outline,
                          color: laranja,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          servico.titulo,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: cor.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          servico.status,
                          style: TextStyle(
                            color: cor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Cliente: ${servico.cliente}'),
                  const SizedBox(height: 4),
                  Text('Tipo: ${servico.tipoServico}'),
                  const SizedBox(height: 4),
                  Text('Data: ${servico.data}'),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static Color _corStatus(String status) {
    switch (status) {
      case 'Ativo':
        return Colors.green;
      case 'Pendente':
        return Colors.orange;
      case 'Concluído':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}