
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class FinalStoryScreen extends StatefulWidget {
  final String historiaCompleta;
  final VoidCallback onGenerarPDF;

  const FinalStoryScreen({super.key, required this.historiaCompleta, required this.onGenerarPDF});

  @override
  State<FinalStoryScreen> createState() => _FinalStoryScreenState();
}

class _FinalStoryScreenState extends State<FinalStoryScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
    _reproducirSonido();
  }

  Future<void> _reproducirSonido() async {
    await _audioPlayer.play(AssetSource('sounds/success.mp3'));
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fondo = const LinearGradient(
      begin: Alignment.bottomRight,
      end: Alignment.topLeft,
      colors: [Color(0xFF000428), Color(0xFF004e92)],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎉 Fin del cuento"),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: fondo),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: const Icon(Icons.stars_rounded, size: 64, color: Colors.amberAccent),
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Tu historia mágica ha terminado!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    widget.historiaCompleta,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                widget.onGenerarPDF();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📄 PDF generado. Puedes revisarlo en la carpeta del backend.')),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("Descargar cuento en PDF"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 12,
                shadowColor: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
