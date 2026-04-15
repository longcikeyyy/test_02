import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/auth_provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthCubit>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        final profile = authState.profile;

        return Scaffold(
          appBar: AppBar(title: Center(child: const Text('Tài khoản'))),
          body: authState.isProfileLoading && profile == null
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Thông tin tài khoản',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              label: 'Họ tên',
                              value: profile?.name ?? 'Không xác định',
                            ),
                            const SizedBox(height: 8),
                            _InfoRow(
                              label: 'Số điện thoại',
                              value: profile?.phoneNumber ?? '-',
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: authState.isLoading
                                    ? null
                                    : () async {
                                        await context.read<AuthCubit>().logout();
                                      },
                                icon: const Icon(Icons.logout),
                                label: const Text('Đăng xuất'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: SelectableText(value, textAlign: TextAlign.left)),
      ],
    );
  }
}
