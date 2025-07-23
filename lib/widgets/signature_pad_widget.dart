import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../models/job.dart';
import '../providers/jobs_provider.dart';

class SignaturePadWidget extends StatefulWidget {
  final Job job;
  
  const SignaturePadWidget({
    Key? key,
    required this.job,
  }) : super(key: key);

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  
  bool _isSigningMode = false;
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  Future<void> _saveSignature() async {
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a signature'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      // Convert signature to image
      final ui.Image? image = await _controller.toImage();
      if (image == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving signature'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      
      // Save to file
      final tempDir = await getTemporaryDirectory();
      final signatureDir = await Directory('${tempDir.path}/signatures').create(recursive: true);
      final filePath = path.join(
        signatureDir.path, 
        'signature_${widget.job.id}_${DateTime.now().millisecondsSinceEpoch}.png'
      );
      
      final file = File(filePath);
      await file.writeAsBytes(buffer);
      
      // Update job with signature path
      final jobsProvider = Provider.of<JobsProvider>(context, listen: false);
      jobsProvider.updateCustomerSignature(widget.job.id, filePath);
      
      setState(() {
        _isSigningMode = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Signature saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.job.isSignedOff) {
      return _buildSignedOffView();
    }
    
    if (_isSigningMode) {
      return _buildSignaturePad();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Sign-off',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Request customer signature when the job is complete.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Capture Customer Signature'),
                onPressed: widget.job.status == JobStatus.completed
                    ? () {
                        setState(() {
                          _isSigningMode = true;
                        });
                      }
                    : null,
              ),
            ),
            if (widget.job.status != JobStatus.completed)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Signature capture available once job is marked as Completed',
                    style: TextStyle(
                      color: Colors.orange,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSignaturePad() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customer Signature',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isSigningMode = false;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Please sign below:'),
            const SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  onPressed: () {
                    _controller.clear();
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save Signature'),
                  onPressed: _saveSignature,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSignedOffView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Customer Sign-off Complete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.job.customerSignature != null)
              Center(
                child: Container(
                  height: 150,
                  width: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: widget.job.customerSignature!.startsWith('assets')
                        ? Image.asset(
                            widget.job.customerSignature!,
                            fit: BoxFit.contain,
                          )
                        : Image.file(
                            File(widget.job.customerSignature!),
                            fit: BoxFit.contain,
                          ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'This job has been signed off by the customer',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 