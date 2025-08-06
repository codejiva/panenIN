import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:PanenIn/config/constants/colors.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final Color cornerColor;

  const SharedAppBar({
    super.key,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.cornerColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15.0),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: SvgPicture.asset(
              'assets/images/nama_app.svg',
              height: 30,
            ),
            actions: [
              // Notification Button
              _buildActionButton(
                onPressed: onNotificationPressed ?? () {
                  debugPrint('Notifikasi ditekan!');
                },
                svgAsset: 'assets/images/Notifikasi.svg',
                tooltip: 'Notifications',
                context: context,
              ),
              const SizedBox(width: 10),

              // Profile Button
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: _buildActionButton(
                  onPressed: onProfilePressed ?? () {
                    context.pushNamed('profile');
                  },
                  svgAsset: 'assets/images/Profile.svg',
                  tooltip: 'Profile',
                  context: context,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String svgAsset,
    required String tooltip,
    required BuildContext context,
  }) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 100),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          splashColor: AppColors.primary.withOpacity(0.2),
          highlightColor: AppColors.primary.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              child: SvgPicture.asset(
                svgAsset,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Enhanced version with animation effects
class SharedAppBarEnhanced extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;
  final Color cornerColor;

  const SharedAppBarEnhanced({
    super.key,
    this.onNotificationPressed,
    this.onProfilePressed,
    this.cornerColor = Colors.white,
  });

  @override
  State<SharedAppBarEnhanced> createState() => _SharedAppBarEnhancedState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SharedAppBarEnhancedState extends State<SharedAppBarEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _notificationController;
  late AnimationController _profileController;
  late Animation<double> _notificationScale;
  late Animation<double> _profileScale;

  @override
  void initState() {
    super.initState();
    _notificationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _notificationScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _notificationController, curve: Curves.easeInOut),
    );
    _profileScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _notificationController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15.0),
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: SvgPicture.asset(
              'assets/images/nama_app.svg',
              height: 30,
            ),
            actions: [
              // Enhanced Notification Button
              AnimatedBuilder(
                animation: _notificationScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _notificationScale.value,
                    child: _buildEnhancedActionButton(
                      onPressed: widget.onNotificationPressed ?? () {
                        debugPrint('Notifikasi ditekan!');
                      },
                      onTapDown: () => _notificationController.forward(),
                      onTapUp: () => _notificationController.reverse(),
                      onTapCancel: () => _notificationController.reverse(),
                      svgAsset: 'assets/images/Notifikasi.svg',
                      tooltip: 'Notifications',
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),

              // Enhanced Profile Button
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: AnimatedBuilder(
                  animation: _profileScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _profileScale.value,
                      child: _buildEnhancedActionButton(
                        onPressed: widget.onProfilePressed ?? () {
                          context.pushNamed('profile');
                        },
                        onTapDown: () => _profileController.forward(),
                        onTapUp: () => _profileController.reverse(),
                        onTapCancel: () => _profileController.reverse(),
                        svgAsset: 'assets/images/Profile.svg',
                        tooltip: 'Profile',
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required VoidCallback onPressed,
    required VoidCallback onTapDown,
    required VoidCallback onTapUp,
    required VoidCallback onTapCancel,
    required String svgAsset,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onPressed,
          onTapDown: (_) => onTapDown(),
          onTapUp: (_) => onTapUp(),
          onTapCancel: onTapCancel,
          borderRadius: BorderRadius.circular(25),
          splashColor: AppColors.primary.withOpacity(0.3),
          highlightColor: AppColors.primary.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.transparent,
                width: 1,
              ),
            ),
            child: SvgPicture.asset(
              svgAsset,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade700,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}