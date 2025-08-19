import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class PWAUpdateChecker extends StatefulWidget {
  final Widget child;

  const PWAUpdateChecker({super.key, required this.child});

  @override
  State<PWAUpdateChecker> createState() => _PWAUpdateCheckerState();
}

class _PWAUpdateCheckerState extends State<PWAUpdateChecker> {
  bool _updateAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  void _checkForUpdates() {
    // Check if service worker is available
    if (js.context.hasProperty('navigator') && 
        js.context['navigator'].hasProperty('serviceWorker')) {
      
      // Listen for service worker updates
      final navigator = js.context['navigator'];
      final serviceWorker = navigator['serviceWorker'];
      
      if (serviceWorker != null) {
        // Register update listener
        serviceWorker.callMethod('addEventListener', ['controllerchange', (event) {
          if (mounted) {
            setState(() {
              _updateAvailable = true;
            });
          }
        }]);
        
        // Check for waiting service worker
        serviceWorker.callMethod('getRegistration').then((registration) {
          if (registration != null && registration.hasProperty('waiting')) {
            final waiting = registration['waiting'];
            if (waiting != null && mounted) {
              setState(() {
                _updateAvailable = true;
              });
            }
          }
        });
      }
    }
  }

  void _reloadApp() {
    html.window.location.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_updateAvailable)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              color: Colors.green.shade600,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.update,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Nueva versión disponible',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _reloadApp,
                      child: const Text(
                        'ACTUALIZAR',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _updateAvailable = false;
                        });
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}