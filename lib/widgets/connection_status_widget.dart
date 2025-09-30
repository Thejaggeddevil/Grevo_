import 'package:flutter/material.dart';

class ConnectionStatusWidget extends StatelessWidget {
  final bool isConnected;
  final bool hasError;
  final VoidCallback? onRetry;

  const ConnectionStatusWidget({
    super.key,
    required this.isConnected,
    required this.hasError,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: hasError ? onRetry : null,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getStatusColor(theme).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getStatusColor(theme).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusIcon(theme),
            const SizedBox(width: 6),
            Text(
              _getStatusText(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: _getStatusColor(theme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    if (hasError) {
      return Icon(
        Icons.error_outline,
        size: 16,
        color: _getStatusColor(theme),
      );
    } else if (isConnected) {
      return _buildAnimatedDot(theme);
    } else {
      return _buildPulsingDot(theme);
    }
  }

  Widget _buildAnimatedDot(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(theme).withValues(alpha: value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _getStatusColor(theme).withValues(alpha: 0.3),
                blurRadius: 4,
                spreadRadius: value * 2,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPulsingDot(ThemeData theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.8),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(theme).withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Color _getStatusColor(ThemeData theme) {
    if (hasError) {
      return theme.colorScheme.error;
    } else if (isConnected) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String _getStatusText() {
    if (hasError) {
      return 'Error';
    } else if (isConnected) {
      return 'Live';
    } else {
      return 'Connecting';
    }
  }
}

/// Extended connection status widget with more detailed information
class DetailedConnectionStatusWidget extends StatefulWidget {
  final bool isConnected;
  final bool hasError;
  final String? errorMessage;
  final DateTime? lastUpdate;
  final VoidCallback? onRetry;
  final VoidCallback? onDetails;

  const DetailedConnectionStatusWidget({
    super.key,
    required this.isConnected,
    required this.hasError,
    this.errorMessage,
    this.lastUpdate,
    this.onRetry,
    this.onDetails,
  });

  @override
  State<DetailedConnectionStatusWidget> createState() => 
      _DetailedConnectionStatusWidgetState();
}

class _DetailedConnectionStatusWidgetState 
    extends State<DetailedConnectionStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (!widget.isConnected && !widget.hasError) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DetailedConnectionStatusWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isConnected != oldWidget.isConnected ||
        widget.hasError != oldWidget.hasError) {
      if (!widget.isConnected && !widget.hasError) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: widget.onDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  _buildDetailedStatusIcon(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connection Status',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDetailedStatusText(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(theme),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.hasError && widget.onRetry != null) ...[
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: widget.onRetry,
                      tooltip: 'Retry Connection',
                    ),
                  ],
                ],
              ),
              
              // Additional information
              if (widget.lastUpdate != null || widget.errorMessage != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                
                if (widget.lastUpdate != null) ...[
                  _buildInfoRow(
                    Icons.access_time,
                    'Last Update',
                    _formatLastUpdate(widget.lastUpdate!),
                    theme,
                  ),
                ],
                
                if (widget.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.error_outline,
                    'Error',
                    widget.errorMessage!,
                    theme,
                    isError: true,
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedStatusIcon(ThemeData theme) {
    if (widget.hasError) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.error.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.error_outline,
          color: theme.colorScheme.error,
          size: 24,
        ),
      );
    } else if (widget.isConnected) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.wifi,
          color: Colors.green,
          size: 24,
        ),
      );
    } else {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1 * _pulseAnimation.value),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off,
              color: Colors.orange.withValues(alpha: _pulseAnimation.value),
              size: 24,
            ),
          );
        },
      );
    }
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme, {
    bool isError = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: isError 
              ? theme.colorScheme.error 
              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: isError 
                        ? theme.colorScheme.error 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(ThemeData theme) {
    if (widget.hasError) {
      return theme.colorScheme.error;
    } else if (widget.isConnected) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  String _getDetailedStatusText() {
    if (widget.hasError) {
      return 'Connection Error';
    } else if (widget.isConnected) {
      return 'Connected - Real-time Data';
    } else {
      return 'Connecting to Server';
    }
  }

  String _formatLastUpdate(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

/// Simple connection indicator dot
class ConnectionIndicatorDot extends StatelessWidget {
  final bool isConnected;
  final bool hasError;
  final double size;

  const ConnectionIndicatorDot({
    super.key,
    required this.isConnected,
    required this.hasError,
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(
        begin: hasError || !isConnected ? 0.3 : 0.8,
        end: hasError || !isConnected ? 0.8 : 1.0,
      ),
      duration: Duration(
        milliseconds: hasError || !isConnected ? 1000 : 500,
      ),
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getColor().withValues(alpha: value),
            shape: BoxShape.circle,
            boxShadow: isConnected && !hasError ? [
              BoxShadow(
                color: _getColor().withValues(alpha: 0.3),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ] : null,
          ),
        );
      },
    );
  }

  Color _getColor() {
    if (hasError) {
      return Colors.red;
    } else if (isConnected) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }
}
