import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShaderSourceViewer extends StatefulWidget {
  final String assetKey;
  final String shaderName;

  const ShaderSourceViewer({
    super.key,
    required this.assetKey,
    required this.shaderName,
  });

  @override
  State<ShaderSourceViewer> createState() => _ShaderSourceViewerState();
}

class _ShaderSourceViewerState extends State<ShaderSourceViewer> {
  String? _sourceCode;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShaderSource();
  }

  Future<void> _loadShaderSource() async {
    try {
      // Convert shader path to asset path
      // e.g., 'shaders/crt_shader.frag' -> 'assets/shaders_text/crt_shader.frag'
      String assetPath = widget.assetKey;
      if (assetPath.startsWith('shaders/')) {
        final basename = assetPath.split('/').last;
        assetPath = 'assets/shaders_text/$basename';
      }
      
      final source = await rootBundle.loadString(assetPath);
      setState(() {
        _sourceCode = source;
        _isLoading = false;
      });
    } catch (e) {
      // Handle loading errors
      String errorMessage;

      if (e is FormatException) {
        errorMessage =
            'Shader file appears to be in binary format. Asset transformation may not be working correctly.';
      } else {
        errorMessage =
            'Failed to load shader source: $e\n\nEnsure shader files are copied to assets directory. Run: dart scripts/copy_shaders.dart';
      }

      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${widget.shaderName} Source Code',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_sourceCode != null)
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _sourceCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Shader source copied to clipboard'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[400]),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[700]!),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: SelectableText(
                          _sourceCode!,
                          style: const TextStyle(
                            fontFamily: 'Roboto Mono',
                            fontFamilyFallback: <String>["Courier"],
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
