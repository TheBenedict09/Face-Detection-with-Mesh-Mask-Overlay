import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Face Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FaceDetectionScreen(),
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _controller;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    try {
      await _controller.initialize();
      setState(() {});
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startStreaming() {
    if (!_controller.value.isInitialized) {
      return;
    }
    setState(() {
      _isStreaming = true;
    });
    // Start the camera feed, but without streaming to WebSocket
  }

  void _stopStreaming() {
    if (!_controller.value.isInitialized) {
      return;
    }
    setState(() {
      _isStreaming = false;
    });
    // Stop the camera feed, but without streaming to WebSocket
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Face Detection App'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _controller.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: CameraPreview(_controller),
                  )
                : Center(child: CircularProgressIndicator()),
          ),
          SizedBox(height: 16),
          ControlPanel(
            isStreaming: _isStreaming,
            onStart: _startStreaming,
            onStop: _stopStreaming,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ControlPanel extends StatelessWidget {
  final bool isStreaming;
  final VoidCallback onStart;
  final VoidCallback onStop;

  ControlPanel({
    required this.isStreaming,
    required this.onStart,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isStreaming ? onStop : onStart,
          child: Text(isStreaming ? 'Stop' : 'Start'),
        ),
      ],
    );
  }
}
