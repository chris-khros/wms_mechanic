import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePictureWidget extends StatelessWidget {
  final String? profilePicturePath;
  final VoidCallback? onTap;
  final double size;

  const ProfilePictureWidget({
    Key? key,
    this.profilePicturePath,
    this.onTap,
    this.size = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: profilePicturePath != null
              ? Image.file(
                  File(profilePicturePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultAvatar(context);
                  },
                )
              : _buildDefaultAvatar(context),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.white,
      ),
    );
  }
} 