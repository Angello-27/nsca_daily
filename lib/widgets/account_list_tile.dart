import '../providers/auth.dart';
import '../screens/downloaded_course_list.dart';
import '../screens/edit_password_screen.dart';
import '../screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../screens/account_remove_screen.dart';
import './custom_text.dart';

class AccountListTile extends StatefulWidget {
  final String? titleText;
  final IconData? icon;
  final String? actionType;
  final String? courseAccessibility;

  const AccountListTile({
    super.key,
    @required this.titleText,
    @required this.icon,
    @required this.actionType,
    this.courseAccessibility,
  });

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  late NavigatorState navigator;

  void _actionHandler(BuildContext context) async {
    navigator = Navigator.of(context);
    if (widget.actionType == 'logout') {
      await Provider.of<Auth>(context, listen: false).logout();
      if (mounted) {
        if (widget.courseAccessibility == 'publicly') {
          navigator.pushNamedAndRemoveUntil('/home', (r) => false);
        } else {
          navigator.pushNamedAndRemoveUntil('/auth-private', (r) => false);
        }
      }
    } else if (widget.actionType == 'edit') {
      navigator.pushNamed(EditProfileScreen.routeName);
    } else if (widget.actionType == 'change_password') {
      navigator.pushNamed(EditPasswordScreen.routeName);
    } else if (widget.actionType == 'account_delete') {
      navigator.pushNamed(AccountRemoveScreen.routeName);
    } else {
      navigator.pushNamed(DownloadedCourseList.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: kPrimaryColor.withValues(alpha: 0.7),
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: FittedBox(child: Icon(widget.icon, color: Colors.white)),
        ),
      ),
      title: CustomText(
        text: widget.titleText,
        colors: kTextColor,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: InkWell(
          onTap: () => _actionHandler(context),
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            color: iCardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 2,
              ),
              child: ImageIcon(
                const AssetImage("assets/images/long_arrow_right.png"),
                color: kPrimaryColor.withValues(alpha: 0.7),
                size: 25,
              ),
            ),
          ),
        ),
      ),
      // trailing: IconButton(
      //   icon: const Icon(Icons.arrow_forward_ios),
      //   onPressed: () => _actionHandler(context),
      //   color: Colors.grey,
      // ),
    );
  }
}
