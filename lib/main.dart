import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
      debugShowCheckedModeBanner: false,
    );
  }
}

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  late CameraController _controller;
  late WebSocketChannel _channel;
  bool _isStreaming = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
    // _channel = WebSocketChannel.connect(Uri.parse('wss://example.com/stream'));
    // _channel.stream.listen(
    //   (message) {
    //     setState(
    //       () {
    //         _isConnected = true;
    //       },
    //     );
    //   },
    //   onError: (error) {
    //     setState(
    //       () {
    //         _isConnected = false;

    //       },
    //     );
    //   },
    // );
  }

  @override
  void dispose() {
    _controller.dispose();
    _channel.sink.close();
    super.dispose();
  }

  void _startStreaming() {
    if (!_controller.value.isInitialized) {
      return;
    }
    setState(() {
      _isStreaming = true;
    });
    _controller.startImageStream((CameraImage image) {
      // Convert image to bytes and send to WebSocket
      // Uint8List videoFrame = _convertCameraImageToBytes(image);
      // _channel.sink.add(videoFrame);
    });
  }

  void _stopStreaming() {
    if (!_controller.value.isInitialized) {
      return;
    }
    setState(() {
      _isStreaming = false;
    });
    _controller.stopImageStream();
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
            isConnected: _isConnected,
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
  final bool isConnected;
  final VoidCallback onStart;
  final VoidCallback onStop;

  ControlPanel({
    required this.isStreaming,
    required this.isConnected,
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
        SizedBox(height: 8),
        Text(
          isConnected ? 'Connected' : 'Disconnected',
          style: TextStyle(color: isConnected ? Colors.green : Colors.red),
        ),
      ],
    );
  }
}
