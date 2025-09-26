import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import '../models/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  const CustomAppBar({super.key}) : preferredSize = const Size.fromHeight(50.0);

  @override
  // ignore: library_private_types_in_public_api
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final _controller = StreamController<AppLogo>();

  fetchMyLogo() async {
    var url = '$BASE_URL/api/app_logo';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var logo = AppLogo.fromJson(jsonDecode(response.body));
        _controller.add(logo);
      }
    } catch (error) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMyLogo();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      iconTheme: IconThemeData(
        color: AppColors.getTextColor(context),
      ),
      leading: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return StreamBuilder<AppLogo>(
            stream: _controller.stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container();
              } else {
                if (snapshot.error != null) {
                  return Text(
                    "Error Occured",
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  );
                } else {
                  // Use darkLogo for light theme and lightLogo for dark theme
                  final logoUrl = themeProvider.isDarkMode 
                      ? snapshot.data!.lightLogo.toString()
                      : snapshot.data!.darkLogo.toString();
                      
                  return Transform.scale(
                    scale: 3.5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: CachedNetworkImage(
                        alignment: Alignment.center,
                        imageUrl: logoUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                }
              }
            },
          );
        },
      ),
      backgroundColor: AppColors.getCardColor(context),
      actions: <Widget>[
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.themeIcon,
                color: AppColors.getTextColor(context),
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },
              tooltip: 'Switch Theme (${themeProvider.themeModeName})',
            );
          },
        ),
      ],
    );
  }
}
