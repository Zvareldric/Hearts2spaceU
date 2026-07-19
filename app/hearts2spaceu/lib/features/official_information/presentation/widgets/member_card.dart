import 'package:flutter/material.dart';

import '../../domain/member.dart';

/// A single member row in the list.
///
/// Presentation only: it renders a [Member] and reports taps via [onTap]; it
/// does not know *where* a tap leads (the page decides navigation).
class MemberCard extends StatelessWidget {
  const MemberCard({super.key, required this.member, this.onTap});

  final Member member;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final positions = member.positions.join(', ');
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(member.stageName),
      subtitle: positions.isEmpty ? null : Text(positions),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
