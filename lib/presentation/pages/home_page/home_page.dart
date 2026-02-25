import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assesment/presentation/bloc/theme/theme_bloc.dart';
import 'package:flutter_assesment/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:flutter_assesment/presentation/pages/home_page/widgets/action_card_widget.dart';
import 'package:flutter_assesment/presentation/pages/login_page/login_page.dart';
import 'package:flutter_assesment/presentation/pages/profile_page/profile_edit_page.dart';
import 'package:flutter_assesment/presentation/pages/task_page/task_list_page.dart';
import 'package:flutter_assesment/utils/alerts_and_navigators.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // print(user);
      context.read<UserProfileBloc>().add(FetchUserProfileEvent(uid: user.uid));
      context.read<ThemeBloc>().add(LoadThemeEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                tooltip: 'Toggle Theme',
                icon: Icon(
                  state.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {
                  final newMode =
                      state.themeMode == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                  context.read<ThemeBloc>().add(ChangeThemeEvent(newMode));
                },
              );
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout, color: theme.colorScheme.onSurface),
            onPressed: () => _showLogoutConfirmation(context),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<UserProfileBloc, UserProfileState>(
          buildWhen: (previous, current) =>
              current is! UserProfileUpdating &&
              current is! UserProfileUpdateSuccess,
          builder: (context, state) {
            if (state is UserProfileLoading || state is UserProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is UserProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(state.message),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          context.read<UserProfileBloc>().add(
                                FetchUserProfileEvent(uid: user.uid),
                              );
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is UserProfileLoaded) {
              final user = state.user;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Welcome Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              isDark ? 0.3 : 0.08,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: theme.colorScheme.primary,
                            child: Text(
                              user.fullName.isNotEmpty
                                  ? user.fullName[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user.fullName} 👋',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    /// Quick Actions Title
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 16),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        ActionCard(
                          icon: Icons.task_outlined,
                          label: 'My Tasks',
                          color: Colors.deepPurpleAccent,
                          onTap: () => nextScreen(context, const TaskListPage()),
                        ),
                        ActionCard(
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          color: Colors.blueAccent,
                          onTap: () => nextScreen(
                            context,
                            ProfileEditPage(
                              uid: user.uid,
                              currentName: user.fullName,
                              currentEmail: user.email,
                            ),
                          ),
                        ),
                        const ActionCard(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          color: Colors.lightGreen,
                        ),
                        const ActionCard(
                          icon: Icons.help_outline,
                          label: 'Help & Support',
                          color: Colors.purpleAccent,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

Future<void> _showLogoutConfirmation(BuildContext context) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Confirm Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to log out?\nYou will need to sign in again to access your tasks.',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    await FirebaseAuth.instance.signOut();
    nextScreenRemoveUntil(context, const LoginPage());
  }
}
