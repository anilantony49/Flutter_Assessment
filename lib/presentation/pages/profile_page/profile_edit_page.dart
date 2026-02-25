import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_assesment/utils/validations.dart';

class ProfileEditPage extends StatefulWidget {
  final String uid;
  final String currentName;
  final String currentEmail;

  const ProfileEditPage({
    super.key,
    required this.uid,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.08),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<UserProfileBloc, UserProfileState>(
            listener: (context, state) {
              if (state is UserProfileUpdateSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(state.message),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
                Navigator.pop(context);
              } else if (state is UserProfileError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(state.message),
                      ],
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      FadeInDown(
                        duration: const Duration(milliseconds: 500),
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: theme.colorScheme.surface,
                                child: CircleAvatar(
                                  radius: 56,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  child: Text(
                                    widget.currentName.isNotEmpty
                                        ? widget.currentName[0].toUpperCase()
                                        : 'U',
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: theme.colorScheme.surface, width: 3),
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: theme.colorScheme.primary,
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 200),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.05),
                          ),
                          validator: AppValidators.validateFullName,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeInLeft(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 300),
                        child: TextFormField(
                          initialValue: widget.currentEmail,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            prefixIcon: const Icon(Icons.email_outlined),
                            filled: true,
                            fillColor:
                                isDark
                                    ? Colors.white.withOpacity(0.05)
                                    : Colors.grey.withOpacity(0.05),
                          ),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 40),
                      FadeInUp(
                        duration: const Duration(milliseconds: 500),
                        delay: const Duration(milliseconds: 400),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              disabledBackgroundColor:
                                  theme.colorScheme.primary,
                              disabledForegroundColor:
                                  theme.colorScheme.onPrimary,
                            ),
                            onPressed: state is UserProfileUpdating
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<UserProfileBloc>().add(
                                            UpdateUserProfileEvent(
                                              uid: widget.uid,
                                              fullName:
                                                  _nameController.text.trim(),
                                            ),
                                          );
                                    }
                                  },
                            child: state is UserProfileUpdating
                                ? CupertinoActivityIndicator(
                                    color: theme.colorScheme.onPrimary,
                                  )
                                : const Text('Update Profile'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
