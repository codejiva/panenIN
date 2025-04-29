import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationPressed;
  final VoidCallback? onProfilePressed;

  const SharedAppBar({
    Key? key,
    this.onNotificationPressed,
    this.onProfilePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(15.0),
          ),
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
              height: 30, // Added explicit height for better consistency
            ),
            actions: [
              InkWell(
                  onTap: onNotificationPressed ?? () {
                    debugPrint('Notifikasi ditekan!');
                  },
                  child: const Icon(
                    Icons.notifications,
                    size: 25,
                    color: Colors.black54, // Added color for better visibility
                  )
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: onProfilePressed ?? () {
                  debugPrint('Profile ditekan!');
                },
                child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: const Icon(
                      Icons.account_circle_outlined,
                      size: 25,
                      color: Colors.black54, // Added color for better visibility
                    )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}