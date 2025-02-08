import 'package:flutter/material.dart';
import 'package:notes_app/modals/ModalProvider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

class pruebaModal extends StatefulWidget {
  const pruebaModal({super.key});

  @override
  State<pruebaModal> createState() => _pruebaModalState();
}

class _pruebaModalState extends State<pruebaModal> {
  void _showModal(
      BuildContext context, ModalInfo modal, ModalProvider provider) {
    WoltModalSheet.show(
      context: context,
      pageListBuilder: (context) => [
        WoltModalSheetPage(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (modal.imageAsset.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset(
                    modal.imageAsset,
                    height: 100,
                  ),
                ),
              Text(
                modal.title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(modal.description),
              if (modal.link.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TextButton(
                    onPressed: () => _openLink(modal.link),
                    child:
                        const Text('Saber más', style: TextStyle(fontSize: 16)),
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  provider.markModalAsShown(modal.id);
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print('No se pudo abrir el enlace: $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final modalProvider = Provider.of<ModalProvider>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (modalProvider.activeModals.isNotEmpty) {
        if (ModalRoute.of(context)?.isCurrent ?? true) {
          // Prevenir superposiciones
          _showModal(context, modalProvider.activeModals.first, modalProvider);
        }
      }
    });

    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Material App Bar'),
        ),
        body: const Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}
